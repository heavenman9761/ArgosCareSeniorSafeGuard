import 'dart:async';
import 'dart:convert';

import 'package:argoscareseniorsafeguard/models/hub.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';
import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/pages/add_hub_page1.dart';
import 'package:argoscareseniorsafeguard/pages/add_sensor_page1.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/components/home_widget.dart';
import 'package:argoscareseniorsafeguard/components/mydevice_widget.dart';
import 'package:argoscareseniorsafeguard/components/profile_widget.dart';
import 'package:argoscareseniorsafeguard/components/nofify_badge_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title, required this.userName});

  final String title;
  final String userName;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final List<Device> _deviceList = [];
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    getMyDeviceToken();

    _checkPermissions();

    // _downDeviceListFromServer();

    mqttInit(ref, '14.42.209.174', 6002, 'ArgosCareSeniorSafeGuard', 'mings', 'Sct91234!');

    _fcmSetListener();

    _getLastEvent();

    super.initState();
  }

  @override
  void dispose() {
    mqttDisconnect();
    super.dispose();
  }

  void _getLastEvent() async {
    DBHelper sd = DBHelper();

    List<SensorEvent> es = await sd.findSensorLast(Constants.DEVICE_TYPE_ILLUMINANCE);
    if (es.isNotEmpty) {
      SensorEvent sensorEvent = es[0];
      String description = analysisSensorEvent(sensorEvent);
      ref.read(illuminanceSensorStateProvider.notifier).state = description;
    }

    es = await sd.findSensorLast(Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY);
    if (es.isNotEmpty) {
      SensorEvent sensorEvent = es[0];
      String description = analysisSensorEvent(sensorEvent);
      ref.read(humiditySensorStateProvider.notifier).state = description;
    }

    es = await sd.findSensorLast(Constants.DEVICE_TYPE_SMOKE);
    if (es.isNotEmpty) {
      SensorEvent sensorEvent = es[0];
      String description = analysisSensorEvent(sensorEvent);
      ref.read(smokeSensorStateProvider.notifier).state = description;
    }

    es = await sd.findSensorLast(Constants.DEVICE_TYPE_EMERGENCY);
    if (es.isNotEmpty) {
      SensorEvent sensorEvent = es[0];
      String description = analysisSensorEvent(sensorEvent);
      ref.read(emergencySensorStateProvider.notifier).state = description;
    }

    es = await sd.findSensorLast(Constants.DEVICE_TYPE_MOTION);
    if (es.isNotEmpty) {
      SensorEvent sensorEvent = es[0];
      String description = analysisSensorEvent(sensorEvent);
      ref.read(motionSensorStateProvider.notifier).state = description;
    }

    es = await sd.findSensorLast(Constants.DEVICE_TYPE_DOOR);
    if (es.isNotEmpty) {
      SensorEvent sensorEvent = es[0];
      String description = analysisSensorEvent(sensorEvent);
      ref.read(doorSensorStateProvider.notifier).state = description;
    }

  }

  void _fcmSetListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;

      // if (notification != null) {
      FlutterLocalNotificationsPlugin().show(
        notification.hashCode,
        message.data['title'],
        message.data['body'],
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'high_importance_notification',
            importance: Importance.max,
          ),
        ),
      );


      if (!ref.watch(alarmReceivedProvider.notifier).state) {
        ref
            .read(alarmReceivedProvider.notifier)
            .state = true;
      }

      // logger.i("Foreground 메시지 수신: ${message.notification!.body!}");
    });
  }

  void _addDevice() async {
    if (_deviceList.isEmpty) {
      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.none);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const AddHubPage1();
      }));
    } else {
      String? deviceID = _deviceList[0].getDeviceID();
      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.none);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AddSensorPage1(deviceID: deviceID!);
      }));
    }
  }

  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
    ].request();

    // logger.i('location ${statuses[Permission.location]}');

    if (statuses.values.every((element) => element.isGranted)) {
      return true;
    }
    return false;
  }

  void _mqttStartSubscribeTo() async {
    DBHelper sd = DBHelper();
    List<Hub> hubList = await sd.getHubs();
    for (var hub in hubList) {
      ref.read(commandTopicProvider.notifier).state = 'command/${hub.getHubID()}';
      ref.read(requestTopicProvider.notifier).state = 'request/${hub.getHubID()}';
      ref.read(resultTopicProvider.notifier).state = 'result/${hub.getHubID()}';

      mqttAddSubscribeTo('result/${hub.getHubID()}');
    }
    /*List<Device> hubList = await sd.getDeviceOfHubs();
    for (var hub in hubList) {
      ref.read(commandTopicProvider.notifier).state = 'command/${hub.getDeviceID()}';
      // mqttAddSubscribeTo('command/${hub.getDeviceID()}');

      ref.read(requestTopicProvider.notifier).state = 'request/${hub.getDeviceID()}';
      // mqttAddSubscribeTo('request/${hub.getDeviceID()}');

      ref.read(resultTopicProvider.notifier).state = 'result/${hub.getDeviceID()}';
      mqttAddSubscribeTo('result/${hub.getDeviceID()}');
    }*/
  }

  Future<void> _insertSensorEvent(String message) async {
    DBHelper sd = DBHelper();
    String hubID = '';
    final mqttMsg = json.decode(message);

    List<Device> deviceList = await sd.findDeviceBySensor(mqttMsg['device_type']);
    if (deviceList.isEmpty) {
      return;
    }

    int humi = 0;
    double temp = 0.0;
    if (mqttMsg['device_type'] == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      humi = mqttMsg['sensorState']['hum'];
      temp = mqttMsg['sensorState']['temp'] / 10;
    }

    SensorEvent sensorEvent = SensorEvent(
      id: mqttMsg['id'],
      hubID: mqttMsg['hubID'],
      deviceID: mqttMsg['deviceID'],
      deviceType: mqttMsg['device_type'],
      event: mqttMsg['event'],
      status: mqttMsg['sensorState'].toString(),
      humi: humi,
      temp: temp,
      updatedAt: DateTime.now().toString(),
      createdAt: DateTime.now().toString(),
    );

    await sd.insertSensorEvent(sensorEvent).then((value) async {
      List<Device> deviceList = await sd.findDeviceBySensor(mqttMsg['device_type']);

      Device d = Device(
          deviceID: deviceList[0].deviceID,
          deviceType: deviceList[0].deviceType,
          deviceName: deviceList[0].deviceName,
          displaySunBun: deviceList[0].displaySunBun,
          accountID: deviceList[0].accountID,
          status: mqttMsg['sensorState'].toString(),
          updatedAt: DateTime.now().toString(),
          createdAt: deviceList[0].createdAt
      );

      await sd.updateDevice(d).then((value) {
        final state = mqttMsg['sensorState'];
        var now = DateTime.now();
        String formatDate = DateFormat('dd일 - HH:mm:ss').format(now);

        if (mqttMsg['device_type'] == Constants.DEVICE_TYPE_DOOR) {
          if (state['door_window'] == 0) {
            ref.read(doorSensorStateProvider.notifier).state = "$formatDate 닫힘";

          } else if (state['door_window'] == 1) {
            ref.read(doorSensorStateProvider.notifier).state = "$formatDate 열림";
          }

        } else if (mqttMsg['device_type'] == Constants.DEVICE_TYPE_MOTION) {
          if (state['motion'] == 0) {
            ref.read(motionSensorStateProvider.notifier).state = "$formatDate 움직임 없음";
          } else if (state['motion'] == 1) {
            ref.read(motionSensorStateProvider.notifier).state = "$formatDate 움직임 감지";
          }

        } else if (mqttMsg['device_type'] == Constants.DEVICE_TYPE_ILLUMINANCE) {
          final int illuminance = state['illuminance'];
          final String value = illuminance.toString();
          ref.read(illuminanceSensorStateProvider.notifier).state = '$formatDate $value';

        } else if (mqttMsg['device_type'] == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
          double celsius = state['temp'] / 10;

          NumberFormat format = NumberFormat("#0.0");
          String strCelsius = format.format(celsius);

          ref.read(humiditySensorStateProvider.notifier).state = "$formatDate 온도: $strCelsius° 습도: ${state['hum']}%";

        } else if (mqttMsg['device_type'] == Constants.DEVICE_TYPE_EMERGENCY) {
          ref.read(emergencySensorStateProvider.notifier).state = "$formatDate SOS 호출이 있었습니다.";

        } else if (mqttMsg['device_type'] == Constants.DEVICE_TYPE_SMOKE) {
          ref.read(smokeSensorStateProvider.notifier).state = "$formatDate Fire";

        }
      });
    });
  }

  Future<void> _saveHub(String message) async {
    final mqttMsg = json.decode(message);

    DBHelper sd = DBHelper();
    List<Hub> lists = await sd.findHub(mqttMsg['deviceID']);
    if (lists.isEmpty) {
       Hub hub = Hub(
         id: mqttMsg['id'],
         hubID: mqttMsg['deviceID'],
         name: mqttMsg['name'],
         displaySunBun: mqttMsg['displaySunBun'],
         category: mqttMsg['category'],
         deviceType: mqttMsg['deviceType'],
         hasSubDevices: mqttMsg['hasSubDevices'] ? 1 : 0,
         modelName: mqttMsg['modelName'],
         online: mqttMsg['online'] ? 1 : 0,
         status: mqttMsg['status'],
         battery: mqttMsg['battery'],
         isUse: mqttMsg['isUse'] ? 1 : 0,
         updatedAt: DateTime.now().toString(),
         createdAt: DateTime.now().toString(),
       );
       await sd.insertHub(hub);
    } else {
      Hub hub = Hub(
        id: mqttMsg['id'],
        hubID: mqttMsg['deviceID'],
        name: mqttMsg['name'],
        displaySunBun: mqttMsg['displaySunBun'],
        category: mqttMsg['category'],
        deviceType: mqttMsg['deviceType'],
        hasSubDevices: mqttMsg['hasSubDevices'] ? 1 : 0,
        modelName: mqttMsg['modelName'],
        online: mqttMsg['online'] ? 1 : 0,
        status: mqttMsg['status'],
        battery: mqttMsg['battery'],
        isUse: mqttMsg['isUse'] ? 1 : 0,
        updatedAt: DateTime.now().toString(),
        // createdAt: DateTime.now().toString(),
      );
      await sd.updateHub(hub);
    }
  }

  Future<void> _saveSensor(String message) async {
    final mqttMsg = json.decode(message);

    DBHelper sd = DBHelper();
    List<Sensor> lists = await sd.findSensor(mqttMsg['sensorID']);
    if (lists.isEmpty) {
      Sensor sensor = Sensor(
        id: mqttMsg['id'],
        sensorID: mqttMsg['sensorID'],
        name: mqttMsg['name'],
        displaySunBun: mqttMsg['displaySunBun'],
        category: mqttMsg['category'],
        deviceType: mqttMsg['deviceType'],
        modelName: mqttMsg['modelName'],
        online: mqttMsg['online'] ? 1 : 0,
        status: mqttMsg['status'],
        battery: mqttMsg['battery'],
        isUse: mqttMsg['isUse'] ? 1 : 0,
        updatedAt: DateTime.now().toString(),
        createdAt: DateTime.now().toString(),
        hubID: mqttMsg['hubID']
      );
      await sd.insertSensor(sensor);
      print('sd.insertSensor');
    } else {
      Sensor sensor = Sensor(
          id: mqttMsg['id'],
          sensorID: mqttMsg['sensorID'],
          name: mqttMsg['name'],
          displaySunBun: mqttMsg['displaySunBun'],
          category: mqttMsg['category'],
          deviceType: mqttMsg['deviceType'],
          modelName: mqttMsg['modelName'],
          online: mqttMsg['online'] ? 1 : 0,
          status: mqttMsg['status'],
          battery: mqttMsg['battery'],
          isUse: mqttMsg['isUse'] ? 1 : 0,
          updatedAt: DateTime.now().toString(),
          // createdAt: DateTime.now().toString(),
          hubID: mqttMsg['hubID']
      );
      await sd.updateSensor(sensor);
      print('sd.updateSensor');
    }
  }

  Future<void> _delSensor(String sensorID) async {

    DBHelper sd = DBHelper();
    await sd.deleteSensor(sensorID);

  }

  Future<void> _saveDevice(String deviceID, String deviceType) async {
    DBHelper sd = DBHelper();
    int? count = await sd.getDeviceCountByType(deviceType);
    count = count! + 1;
    int? displaySunBun = await sd.getDeviceCount();
    String deviceName = '';

    if (deviceType == Constants.DEVICE_TYPE_HUB) {
      deviceName = 'hub $count';
    } else if (deviceType == Constants.DEVICE_TYPE_ILLUMINANCE) {
      deviceName = 'illuminance $count';
    } else if (deviceType == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      deviceName = 'temperature_humidity $count';
    } else if (deviceType == Constants.DEVICE_TYPE_SMOKE) {
      deviceName = 'smoke $count';
    } else if (deviceType == Constants.DEVICE_TYPE_EMERGENCY) {
      deviceName = 'emergency $count';
    } else if (deviceType == Constants.DEVICE_TYPE_MOTION) {
      deviceName = 'motion $count';
    } else if (deviceType == Constants.DEVICE_TYPE_DOOR) {
      deviceName = 'door $count';
    }

    const storage = FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final email = await storage.read(key: 'EMAIL');

    Device device = Device(
      deviceID: deviceID,
      deviceType: deviceType,
      deviceName: deviceName,
      displaySunBun: displaySunBun,
      accountID: email,
      status: "",
      updatedAt: DateTime.now().toString(),
      createdAt: DateTime.now().toString(),
    );

    if (deviceType == Constants.DEVICE_TYPE_HUB) {
      _mqttStartSubscribeTo();
    }

    await sd.insertDevice(device).then((value) {
      setState(() {

      });
    });
  }

  Future<void> _delDevice(String deviceID) async {
    DBHelper sd = DBHelper();
    await sd.deleteDevice(deviceID);

  }

  void _goHome() {
    Navigator.popUntil(context, (route) {
      return route.isFirst;
    },
    );
  }

  /*Future<void> _downDeviceListFromServer() async {
    //오류있음 필요하면 나중에 고칠것
    try {
      const storage = FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      aOptions: AndroidOptions(encryptedSharedPreferences: true),);
      final userID = await storage.read(key: 'ID');
      final res = await dio.get(
          "/devices/$userID"
      );
      print(res.data);

      Hub hub = Hub(
        id: res.data['id'],
        hubID: res.data['hubID'],
        name: res.data['name'],
        displaySunBun: res.data['displaySunBun'],
        category: res.data['category'],
        deviceType: res.data['deviceType'],
        locationID: res.data['locationID'],
        locationName: res.data['locationName'],
        hasSubDevices: res.data['hasSubDevices'],
        modelName: res.data['modelName'],
        online: res.data['online'],
        status: res.data['status'],
        battery: res.data['battery'],
        isUse: res.data['isUse'],
        createdAt: res.data['createdAt'].toString(),
        updatedAt: res.data['updatedAt'].toString(),
      );

      DBHelper sd = DBHelper();
      await sd.insertHub(hub);
    } catch (e) {
      debugPrint(e.toString());
    }
  }*/

  void _analysisMqttMsg(String topic, String message) {
    final mqttMsg = json.decode(message);
    if (topic == ref.watch(requestTopicProvider)) {
      if (mqttMsg['order'] == 'device_add' || mqttMsg['order'] == 'pairingEnabled') {

      }

      if (mqttMsg['event'] == 'boot' && mqttMsg['reason'] == 'power reconnect' && mqttMsg['state'] == 'power_on') {
        //paring 명령후 허브에서 가끔씩 재부팅이 된다. 허브 오류인 듯.
        if (ref.watch(findHubStateProvider) == ConfigState.findingSensor) {
          // final topic = ref.watch(commandTopicProvider);
          mqttSendCommand(MqttCommand.mcParing, mqttMsg['deviceID']);
        }
      }

    } else if (topic == ref.watch(resultTopicProvider)) {
      if (mqttMsg['event'] == 'gatewayADD') {
        if (mqttMsg['state'] == 'success') {
          _saveDevice(mqttMsg['deviceID'], Constants.DEVICE_TYPE_HUB);
          _saveHub(message);
        } else if (mqttMsg['state'] == 'failure') {

        }
        _goHome();
      } else if (mqttMsg['event'] == 'device_add') {
        if (mqttMsg['state'] == 'device add success') {
          _saveDevice(mqttMsg['deviceID'], mqttMsg['device_type']);
          _saveSensor(message);
        } else if (mqttMsg['state'] == 'device add failure') {

        }
        _goHome();
      } else if (mqttMsg['event'] == 'device_del') {
        if (mqttMsg['state'] == 'device del success') {
          _delDevice(mqttMsg['deviceID']);
          _delSensor(mqttMsg['deviceID']);
        }
      }

      if (mqttMsg['event'] == 'device_detected' && mqttMsg['state'] == 'device data success') {
        _insertSensorEvent(message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(mqttCurrentMessageProvider, (previous, next) {
      _analysisMqttMsg(
          ref.watch(mqttCurrentTopicProvider.notifier).state,
          ref.watch(mqttCurrentMessageProvider.notifier).state
      );
      logger.i('current msg: ${ref
          .watch(mqttCurrentTopicProvider.notifier)
          .state} / ${ref
          .watch(mqttCurrentMessageProvider.notifier)
          .state}');
    });

    ref.listen(mqttCurrentStateProvider, (previous, next) {
      logger.i('current state: ${ref.watch(mqttCurrentStateProvider)}');
      if (ref.watch(mqttCurrentStateProvider) == MqttConnectionState.connected) {
        _mqttStartSubscribeTo();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Argos Care'),
        centerTitle: true,
        actions: const [
          NotifyBadgeWidget(),
        ],
      ),
      body: selectWidget(),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors),
              label: '내 기기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: '프로필',
            ),
          ],
          selectedItemColor: Colors.lightBlue,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  FloatingActionButton extendButton() {
    return FloatingActionButton.extended(
      foregroundColor: Colors.white60,
      backgroundColor: Colors.lightBlue,
      onPressed: () => _addDevice(),
      label: const Text("기기 등록"),
      isExtended: true,
      // ingEsp32 ? null : _findEsp32,
      icon: const Icon(Icons.add, size: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget selectWidget() {
    if (_selectedIndex == 0) {
      return HomeWidget(userName: widget.userName);

    } else if (_selectedIndex == 1) {
      return const MyDeviceWidget();

    } else if (_selectedIndex == 2) {
      return const ProfileWidget();

    } else {
      return HomeWidget(userName: widget.userName);
    }
  }

}