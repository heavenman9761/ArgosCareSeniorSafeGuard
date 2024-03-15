import 'dart:async';
import 'dart:convert';

import 'package:argoscareseniorsafeguard/models/sensor_event.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:intl/intl.dart';
//import 'package:argoscareseniorsafeguard/mqtt/IMQTT/Controller.dart';
import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/pages/add_hub_page1.dart';
import 'package:argoscareseniorsafeguard/pages/add_sensor_page1.dart';
import 'package:argoscareseniorsafeguard/pages/alarms_view.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/components/door_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/motion_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/illuminance_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/humidity_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/smoke_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/emergency_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/card_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late List<Device> _deviceList = [];
  bool loadingDeviceList = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    getMyDeviceToken();
    _checkPermissions();
    mqttInit(ref, '14.42.209.174', 6002, 'ArgosCareSeniorSafeGuard', 'mings', 'Sct91234!');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        FlutterLocalNotificationsPlugin().show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'high_importance_notification',
              importance: Importance.max,
            ),
          ),
        );

        setState(() {
          logger.i("Foreground 메시지 수신: ${message.notification!.body!}");
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    mqttDisconnect();
    super.dispose();
  }

  void _addDevice() {
    if (_deviceList.isEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const AddHubPage1();
      }));
    } else {
      String? deviceID = _deviceList[0].getDeviceID();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AddSensorPage1(deviceID: deviceID!);
      }));
    }
  }

  Future<List<Device>> _getDeviceList() async {
    DBHelper sd = DBHelper();
    _deviceList = await sd.getDevices();
    return _deviceList;
  }

  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
    ].request();

    logger.i('location ${statuses[Permission.location]}');

    if (statuses.values.every((element) => element.isGranted)) {
      return true;
    }
    return false;
  }

  /*Future<void> getHubIdToPrefs() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();

      final deviceId = pref.getString('deviceID') ?? '';
      if (deviceId != '') {
        ref.read(resultTopicProvider.notifier).state = 'result/$deviceId';
        ref.read(commandTopicProvider.notifier).state = 'command/$deviceId';
        ref.read(requestTopicProvider.notifier).state = 'request/$deviceId';

        // _manager.subScribeTo(ref.watch(resultTopicProvider));
        // logger.i('subscribed to ${ref.watch(resultTopicProvider)}');
        //
        // _manager.subScribeTo(ref.watch(requestTopicProvider));
        // logger.i('subscribed to ${ref.watch(requestTopicProvider)}');
      } else {
        logger.i('not hubID');
      }
    } catch (e) {
      logger.e(e);
    }
  }*/

  void _mqttStartSubscribeTo() async {
    DBHelper sd = DBHelper();
    List<Device> hubList = await sd.getDeviceOfHubs();
    for (var hub in hubList) {
      ref.read(resultTopicProvider.notifier).state = 'result/${hub.getDeviceID()}';
      mqttAddSubscribeTo('result/${hub.getDeviceID()}');

      ref.read(commandTopicProvider.notifier).state = 'command/${hub.getDeviceID()}';
      mqttAddSubscribeTo('command/${hub.getDeviceID()}');

      ref.read(requestTopicProvider.notifier).state = 'request/${hub.getDeviceID()}';
      mqttAddSubscribeTo('request/${hub.getDeviceID()}');
    }
  }

  Future<void> _insertSensorEvent(String message) async {
    DBHelper sd = DBHelper();
    String hubID = '';
    final mqttMsg = json.decode(message);

    SensorEvent sensorEvent = SensorEvent(
      hubID: hubID,
      deviceID: mqttMsg['deviceID'],
      deviceType: mqttMsg['device_type'],
      event: mqttMsg['event'],
      state: mqttMsg['state'].toString(),
      updateTime: DateTime.now().toString(),
      createTime: DateTime.now().toString(),
    );

    await sd.insertSensorEvent(sensorEvent).then((value) async {
      List<Device> deviceList = await sd.findDeviceBySensor(mqttMsg['device_type']);
      Device d = Device(
        deviceID: deviceList[0].deviceID,
        deviceType: deviceList[0].deviceType,
        deviceName: deviceList[0].deviceName,
        displaySunBun: deviceList[0].displaySunBun,
        accountID: deviceList[0].accountID,
        state: mqttMsg['state'].toString(),
        updateTime: DateTime.now().toString(),
        createTime: deviceList[0].createTime
      );
      await sd.updateDevice(d).then((value) {
        final state = mqttMsg['state'];
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
            ref.read(motionSensorStateProvider.notifier).state = "$formatDate 감지";
          }

        } else if (mqttMsg['device_type'] == Constants.DEVICE_TYPE_ILLUMINANCE) {
            ref.read(illuminanceSensorStateProvider.notifier).state = '$formatDate ${state['illuminance']}';

        } else if (mqttMsg['device_type'] == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
          ref.read(humiditySensorStateProvider.notifier).state = "$formatDate 온도: ${state['temp']} 습도${state['hum']}";

        } else if (mqttMsg['device_type'] == Constants.DEVICE_TYPE_EMERGENCY) {
          ref.read(emergencySensorStateProvider.notifier).state = "$formatDate Emergency";

        } else if (mqttMsg['device_type'] == Constants.DEVICE_TYPE_SMOKE) {
          ref.read(smokeSensorStateProvider.notifier).state = "$formatDate Fire";
        }
      });
    });
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

    Device device = Device(
      deviceID: deviceID,
      deviceType: deviceType,
      deviceName: deviceName,
      displaySunBun: displaySunBun,
      accountID: Constants.ACCOUNT_ID,
      state: "",
      updateTime: DateTime.now().toString(),
      createTime: DateTime.now().toString(),
    );

    if (deviceType == Constants.DEVICE_TYPE_HUB) {
      _mqttStartSubscribeTo();
    }

    await sd.insertDevice(device).then((value) {
      setState(() {

      });
    });
  }

  void _goHome() {
    Navigator.popUntil(context, (route) {
      return route.isFirst;
    },
    );
  }

  void _analysisMqttMsg(String topic, String message) {
    final mqttMsg = json.decode(message);
    if (topic == ref.watch(requestTopicProvider)) {
      if (mqttMsg['order'] == 'device_add' || mqttMsg['order'] == 'pairingEnabled') {

      }

      if (mqttMsg['event'] == 'device_detected') {
        _insertSensorEvent(message);
      }
    } else if (topic == ref.watch(resultTopicProvider)) {
      if (mqttMsg['event'] == 'gatewayADD') {
        _goHome();

        if (mqttMsg['state'] == 'success') {
          _saveDevice(mqttMsg['deviceID'], Constants.DEVICE_TYPE_HUB);
        } else if (mqttMsg['state'] == 'failure') {

        }
      } else if (mqttMsg['event'] == 'device_add') {
        _goHome();

        if (mqttMsg['state'] == 'device add success') {
          _saveDevice(mqttMsg['deviceID'], mqttMsg['deviceType']);
        } else if (mqttMsg['state'] == 'device add failure') {

        }
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
      logger.i('current msg: ${ref.watch(mqttCurrentTopicProvider.notifier).state} / ${ref.watch(mqttCurrentMessageProvider.notifier).state}');
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            tooltip: "Menu",
            color: Colors.grey,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const AlarmsView();
              }));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("안녕하세요 홍 보호님,\n"
                    "홍길동님은 현재 외출중입니다.",
                style: TextStyle(fontSize: 16.0),),
                IconButton(
                  icon: const Icon(Icons.account_circle, size: 48.0),
                  tooltip: "Menu",
                  color: Colors.grey,
                  onPressed: () {
                    debugPrint('icon press');
                  },
                ),
              ]
            )
          ),
          Expanded(
            child: FutureBuilder<List<Device>>(
              future: _getDeviceList(),
              builder: (context, snapshot) {
                final List<Device>? devices = snapshot.data;
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(
                    child: waitWidget(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                if (snapshot.hasData) {
                  if (devices != null) {
                    if (devices.isEmpty) {
                      return Center(
                        child: waitWidget(),
                      );
                    }
                    return ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          if (devices[index].deviceType == Constants.DEVICE_TYPE_HUB) {
                            return CardWidget(deviceName: devices[index].getDeviceName()!);
                          } else if (devices[index].deviceType == Constants.DEVICE_TYPE_DOOR) {
                            return DoorCardWidget(deviceName: devices[index].getDeviceName()!);
                          } else if (devices[index].deviceType == Constants.DEVICE_TYPE_ILLUMINANCE) {
                            return IlluminanceCardWidget(deviceName: devices[index].getDeviceName()!);
                          } else if (devices[index].deviceType == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
                            return HumidityCardWidget(deviceName: devices[index].getDeviceName()!);
                          } else if (devices[index].deviceType == Constants.DEVICE_TYPE_SMOKE) {
                            return SmokeCardWidget(deviceName: devices[index].getDeviceName()!);
                          } else if (devices[index].deviceType == Constants.DEVICE_TYPE_EMERGENCY) {
                            return EmergencyCardWidget(deviceName: devices[index].getDeviceName()!);
                          } else if (devices[index].deviceType == Constants.DEVICE_TYPE_MOTION) {
                            return MotionCardWidget(deviceName: devices[index].getDeviceName()!);
                          } else {
                            return null;
                          }
                        },
                      );

                  } else {
                    return Center(
                      child: waitWidget(),
                    );
                  }
                } else {
                  return Center(
                    child: waitWidget(),
                  );
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: SizedBox(
        height: 50,
        width: 120,
        child: extendButton(),
      ),
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
      ),
    );
  }

  FloatingActionButton extendButton() {
    return FloatingActionButton.extended(
      foregroundColor: Colors.white60,
      backgroundColor: Colors.lightBlue,
      onPressed: () => _addDevice(),
      label: const Text("기기 등록"),
      isExtended: true, // ingEsp32 ? null : _findEsp32,
      icon: const Icon(Icons.add, size: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget waitWidget() {
    return loadingDeviceList
        ? const CircularProgressIndicator(backgroundColor: Colors.blue)
        : const Text("");
  }
}
