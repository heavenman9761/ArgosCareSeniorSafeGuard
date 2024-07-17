import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:argoscareseniorsafeguard/models/hub.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';
import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';
import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
import 'package:argoscareseniorsafeguard/models/alarm_infos.dart';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:intl/intl.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/pages/add_hub_page1.dart';
import 'package:argoscareseniorsafeguard/pages/add_sensor_page1.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/pages/home/home_widget.dart';
import 'package:argoscareseniorsafeguard/pages/mydevice/mydevice_widget.dart';
import 'package:argoscareseniorsafeguard/pages/profile/profile_widget.dart';
import 'package:argoscareseniorsafeguard/components/nofify_badge_widget.dart';
import 'package:argoscareseniorsafeguard/models/hub_infos.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:argoscareseniorsafeguard/back_services.dart';
import 'package:argoscareseniorsafeguard/auth/auth_dio.dart';
import 'package:argoscareseniorsafeguard/pages/notice/notice_widget.dart';
import 'package:argoscareseniorsafeguard/foregroundTaskHandler.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title, required this.userName, required this.userID, required this.userMail});

  final String title;
  final String userName;
  final String userID;
  final String userMail;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WidgetsBindingObserver {
  Timer? _timer;
  ReceivePort? _receivePort;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    // Future.delayed(const Duration(seconds: 3), () {
    //   if (gHubList.isNotEmpty) {
    //     _startForegroundTask();
    //   }
    // });

    /*if (widget.requireLogin) {
      asyncInitState();
    } else {
      _appSetting();
    }*/
    _appSetting();
    asyncInitState();
    // listenForNotificationData();
  }

  // void listenForNotificationData() {
  //   final backgroundService = FlutterBackgroundService();
  //   backgroundService.on('startedMqtt').listen((event) {
  //     print('[startedMqtt] received data message in feed: $event');
  //   }, onError: (e, s) {
  //     print('error listening for updates: $e, $s');
  //   }, onDone: () {
  //     print('background listen closed');
  //   });
  //
  //   backgroundService.on('receiveMqtt').listen((event) {
  //     print('[receiveMqtt] received data message in feed: $event');
  //   }, onError: (e, s) {
  //     print('error listening for updates: $e, $s');
  //   }, onDone: () {
  //     print('background listen closed');
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // mqttDisconnect();
    // _closeReceivePort();
    // _stopTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // 앱 상태 변경시 호출
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed: /* 앱이 표시되고 사용자 입력에 응답합니다. (주의!) 최초 앱 실행때는 해당 이벤트가 발생하지 않습니다. */
        print("resume");
        if (ref.watch(mqttCurrentStateProvider) == MqttConnectionState.disconnected) {
          mqttInit(ref, Constants.MQTT_HOST, Constants.MQTT_PORT, Constants.MQTT_ID, Constants.MQTT_PASSWORD);
        }
        break;
      case AppLifecycleState.inactive: /* 앱이 비활성화 상태이고 사용자의 입력을 받지 않습니다. ios에서는 포 그라운드 비활성 상태에서 실행되는 앱 또는 Flutter 호스트 뷰에 해당합니다. 안드로이드에서는 화면 분할 앱, 전화 통화, PIP 앱, 시스템 대화 상자 또는 다른 창과 같은 다른 활동이 집중되면 앱이이 상태로 전환됩니다. inactive가 발생되고 얼마후 pasued가 발생합니다. */
        print("inactive");
        break;
      case AppLifecycleState.paused: /* 앱이 현재 사용자에게 보이지 않고, 사용자의 입력을 받지 않으며, 백그라운드에서 동작 중입니다. 안드로이드의 onPause()와 동일합니다. 응용 프로그램이 이 상태에 있으면 엔진은 Window.onBeginFrame 및 Window.onDrawFrame 콜백을 호출하지 않습니다.*/
        print("paused");
        break;
      case AppLifecycleState.detached: /* 응용 프로그램은 여전히 flutter 엔진에서 호스팅되지만 "호스트 View"에서 분리됩니다. 앱이 이 상태에 있으면 엔진이 "View"없이 실행됩니다. 엔진이 처음 초기화 될 때 "View" 연결 진행 중이거나 네비게이터 팝으로 인해 "View"가 파괴 된 후 일 수 있습니다. */
        print("detached");
        if (ref.watch(mqttCurrentStateProvider) == MqttConnectionState.connected) {
          mqttDisconnect();
        }

        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        break;
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
        print("main connected");
        _mqttStartSubscribeTo();
      } else if (ref.watch(mqttCurrentStateProvider) == MqttConnectionState.disconnected) {
        print("main disconnected");
        mqttInit(ref, Constants.MQTT_HOST, Constants.MQTT_PORT, Constants.MQTT_ID, Constants.MQTT_PASSWORD);
      }
    });

    ref.listen(sensorEventProvider, (previous, next) {
      // _analysisSensorEvent();
    });

    return Scaffold(
        backgroundColor: Constants.scaffoldBackgroundColor,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Constants.primaryColor, width: 1.0)), // 라인효과
          ),
          child: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/images/bottombar_home_unselect.svg'),
                    activeIcon: SvgPicture.asset('assets/images/bottombar_home_select.svg'),
                    label: '홈',
                    backgroundColor: Constants.scaffoldBackgroundColor
                ),
                /*ref.watch(alarmReceivedProvider)
                    ? BottomNavigationBarItem(
                        icon: Badge(label: const Text('0'), child: SvgPicture.asset('assets/images/bottombar_notify_unselect.svg')),
                        activeIcon: Badge(label: const Text('0'), child: SvgPicture.asset('assets/images/bottombar_notify_select.svg')),
                        label: '알림',
                        backgroundColor: Constants.scaffoldBackgroundColor
                    )
                    : */BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/images/bottombar_notify_unselect.svg'),
                    activeIcon: SvgPicture.asset('assets/images/bottombar_notify_select.svg'),
                    label: '알림',
                    backgroundColor: Constants.scaffoldBackgroundColor
                ),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/images/bottombar_device_unselect.svg'),
                    activeIcon: SvgPicture.asset('assets/images/bottombar_device_select.svg'),
                    label: '내기기',
                    backgroundColor: Constants.scaffoldBackgroundColor
                ),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/images/bottombar_profile_unselect.svg'),
                    activeIcon: SvgPicture.asset('assets/images/bottombar_profile_select.svg'),
                    label: '프로필',
                    backgroundColor: Constants.scaffoldBackgroundColor
                ),
              ],
              showSelectedLabels: false,
              showUnselectedLabels: false,
              // selectedItemColor: Constants.primaryColor,
              // unselectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
              // backgroundColor: Theme.of(context).colorScheme.primary,
              currentIndex: ref.watch(homeBottomNavigationProvider),
              onTap: _onItemTapped
          ),
        ),

        body: selectWidget()
    );

  }

  void _onItemTapped(int index) {
    ref.read(homeBottomNavigationProvider.notifier).state = index;
    // FlutterBackgroundService().invoke("startMqtt");
    // mqttDisconnect();
  }

  Widget selectWidget() {
    if (ref.watch(homeBottomNavigationProvider) == 0) {
      return HomeWidget(userName: widget.userName, userID: widget.userID);

    } else if (ref.watch(homeBottomNavigationProvider) == 1) {
      return NoticeWidget(userName: widget.userName, userID: widget.userID);

    } else if (ref.watch(homeBottomNavigationProvider) == 2) {
      return MyDeviceWidget(userName: widget.userName, userID: widget.userID);

    } else if (ref.watch(homeBottomNavigationProvider) == 3) {
      return ProfileWidget(userName: widget.userName, userID: widget.userID, userMail: widget.userMail);

    } else {
      return HomeWidget(userName: widget.userName, userID: widget.userID);
    }
  }

  void _appSetting() {
    getMyDeviceToken();
    _checkPermissions();
    mqttInit(ref, Constants.MQTT_HOST, Constants.MQTT_PORT, Constants.MQTT_ID, Constants.MQTT_PASSWORD);
    _fcmSetListener();
    _getLastAlarm();
    // _getLastSensorEvent();

    // DBHelper sd = DBHelper();
    // sd.dropTable();
    // sd.createDbTable();
    // _getLastEvent();
    // _getHubInfos();
  }


  void asyncInitState() async {
    // _startTimer();
    // _startBackgroundService();


    // DBHelper sd = DBHelper();
    // await sd.emptyTable();
    // await sd.alterDbTable();
  }

  Future<bool> _startForegroundTask() async {
    print("_startForegroundTask()");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);

      }
    });

    await FlutterForegroundTask.saveData(key: 'startMqtt', value: gHubList[0].getHubID()!);

    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = _registerReceivePort(receivePort);
    if (!isRegistered) {
      print('Failed to register receivePort!');
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: '돌봐효 서비스',
        notificationText: '돌봐효 서비스가 시작되었습니다.',
        callback: startCallback,
      );
    }
  }

  Future<bool> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((data) {

      if (data is int) {
        // print('eventCount: $data');
      } else if (data is String) {
        if (data == 'onNotificationPressed') {

        } else {
          if (data != "") {
            // print('foregroundTask: $data');

            Map<String, dynamic> jsonData = json.decode(data);
            if (jsonData['event'] == 'alarm_update') {
              Map<String, dynamic> alarm = jsonData['alarm'];

              String createdAt = convertTimeStringToLocal(alarm['createdAt']);
              String updatedAt = convertTimeStringToLocal(alarm['updatedAt']);

              AlarmInfo alarmInfo = AlarmInfo(
                  id: alarm['id'],
                  alarm: alarm['alarm'],
                  jaeSilStatus: alarm['jaeSilStatus'],
                  createdAt: createdAt,
                  updatedAt: updatedAt,
                  userID: alarm['userID'],
                  locationID: alarm['locationID']
              );

              gLastAlarm = alarmInfo;
              ref.read(alarmProvider.notifier).doChangeState(gLastAlarm);
              ref.read(jaeSilStateProvider.notifier).doChangeState(JaeSilStateEnum.values[gLastAlarm.getJaeSilStatus()!]);

            } else if (jsonData['event'] == 'device_detected') {
              Map<String, dynamic> msg = jsonData['sensorEvent'];

              String createdAt = convertTimeStringToLocal(msg['createdAt']);
              String updatedAt = convertTimeStringToLocal(msg['updatedAt']);

              SensorEvent se = SensorEvent(
                id: msg['id'],
                deviceType: msg['deviceType'],
                accountID: msg['accountID'],
                event: msg['event'],
                state: msg['state'].toString(),
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: msg['deletedAt'],
                userID: msg['userID'],
                sensorID: msg['sensorID'],
                locationID: msg['locationID'],
              );

              //동작센서의 '움직임없음'이 아니면 재실로 표시할 것.
              //ref.read(jaeSilStateProvider.notifier).doChangeState(JaeSilStateEnum.values[gLastAlarm.getJaeSilStatus()!]);

              for (var location in gLocationList) {
                if (location.getID() == se.getLocationID()) {
                  location.getEvents()!.insert(0, se);
                }
              }

              setState(() {
                // _time = mqttMsg['time'];
              });
            }
          }
        }

      } else if (data is DateTime) {
        print('timestamp: ${data.toString()}');
      }
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  void _getLastAlarm() {
    // DBHelper sd = DBHelper();
    // List<AlarmInfo> list = await sd.getLastAlarms();
    // if (list.isNotEmpty) {
    //   ref.read(alarmProvider.notifier).doChangeState(gLastAlarm);
    //   ref.read(jaeSilStateProvider.notifier).doChangeState(JaeSilStateEnum.values[gLastAlarm.getJaeSilStatus()!]);
    // }
  }

  // void _getLastSensorEvent() async {
  //   DBHelper sd = DBHelper();
  //   List<SensorEvent> list = await sd.getLastSensorEvent();
  //
  //   ref.read(sensorEventProvider.notifier).doChangeState(list[0]);
  // }



  /*Future<void> _loginProcess() async {
    dio = await authDio();

    try {
      final loginResponse = await dio.get(
          "/auth/me"
      );

      _userID = loginResponse.data['id'];
      _userName = loginResponse.data['name'];

      saveUserInfo(loginResponse);

    } catch (e) {
      // _isLogin = false;
    }
  }*/

  void _startBackgroundService() async {
    await initializeService();
    /*FlutterBackgroundService().invoke("setAsBackground"); //// Android O 버전 이상부터는 백그라운드 실행이 제한되기 때문에 ForegroundMode로 해야 함.

    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (isRunning) {
      // service.invoke("stopService");
      // service.startService();
    } else {
      service.startService();
    }*/
  }

  /*void _getHubInfos() async {

  }*/

  /*void _getLastEvent() async {
    DBHelper sd = DBHelper();

    List<SensorEvent> es = await sd.findSensorLast(widget.userID, Constants.DEVICE_TYPE_ILLUMINANCE);
    if (es.isNotEmpty) {
      SensorEvent sensorEvent = es[0];
      String description = analysisSensorEvent(sensorEvent);
      ref.read(illuminanceSensorStateProvider.notifier).state = description;
    }

    es = await sd.findSensorLast(widget.userID, Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY);
    if (es.isNotEmpty) {
      SensorEvent sensorEvent = es[0];
      String description = analysisSensorEvent(sensorEvent);
      ref.read(humiditySensorStateProvider.notifier).state = description;
    }

    es = await sd.findSensorLast(widget.userID, Constants.DEVICE_TYPE_SMOKE);
    if (es.isNotEmpty) {
      SensorEvent sensorEvent = es[0];
      String description = analysisSensorEvent(sensorEvent);
      ref.read(smokeSensorStateProvider.notifier).state = description;
    }

    es = await sd.findSensorLast(widget.userID, Constants.DEVICE_TYPE_EMERGENCY);
    if (es.isNotEmpty) {
      SensorEvent sensorEvent = es[0];
      String description = analysisSensorEvent(sensorEvent);
      ref.read(emergencySensorStateProvider.notifier).state = description;
    }

    es = await sd.findSensorLast(widget.userID, Constants.DEVICE_TYPE_MOTION);
    if (es.isNotEmpty) {
      SensorEvent sensorEvent = es[0];
      String description = analysisSensorEvent(sensorEvent);
      ref.read(motionSensorStateProvider.notifier).state = description;
    }

    es = await sd.findSensorLast(widget.userID, Constants.DEVICE_TYPE_DOOR);
    if (es.isNotEmpty) {
      SensorEvent sensorEvent = es[0];
      String description = analysisSensorEvent(sensorEvent);
      ref.read(doorSensorStateProvider.notifier).state = description;
    }

  }*/

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
    /*if (_deviceList.isEmpty) {
      ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.none);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const AddHubPage1();
      }));
    } else {
      String? deviceID = _deviceList[0].getDeviceID();
      ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.none);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AddSensorPage1(deviceID: deviceID!);
      }));
    }*/
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
    if (gHubList.isNotEmpty) {
      ref.read(commandTopicProvider.notifier).state = 'command/${gHubList[0].getHubID()!}';
      ref.read(requestTopicProvider.notifier).state = 'request/${gHubList[0].getHubID()!}';
      ref.read(resultTopicProvider.notifier).state = 'result/${gHubList[0].getHubID()!}';

      print('result/${gHubList[0].getHubID()!}');

      mqttAddSubscribeTo('result/${gHubList[0].getHubID()!}');
    } else {
      print("gHubList is Empty");
    }

    /*DBHelper sd = DBHelper();
    List<Hub> hubList = await sd.getHubs();
    for (var hub in hubList) {
      ref.read(commandTopicProvider.notifier).state = 'command/${hub.getHubID()}';
      ref.read(requestTopicProvider.notifier).state = 'request/${hub.getHubID()}';
      ref.read(resultTopicProvider.notifier).state = 'result/${hub.getHubID()}';

      mqttAddSubscribeTo('result/${hub.getHubID()}');
    }*/

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
    // DBHelper sd = DBHelper();
    // String hubID = '';
    // final mqttMsg = json.decode(message);

    /*List<Device> deviceList = await sd.findDeviceBySensor(_userID, mqttMsg['device_type']);
    if (deviceList.isEmpty) {
      return;
    }

    int humi = 0;
    double temp = 0.0;
    if (mqttMsg['device_type'] == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      humi = mqttMsg['sensorState']['hum'];
      temp = mqttMsg['sensorState']['temp'] / 10;
    }*/

    /*SensorEvent sensorEvent = SensorEvent(
      id: mqttMsg['id'],
      hubID: mqttMsg['hubID'],
      userID: widget.userID,
      deviceID: mqttMsg['deviceID'],
      deviceType: mqttMsg['device_type'],
      event: mqttMsg['event'],
      status: mqttMsg['sensorState'].toString(),
      humi: 0,
      temp: 0,
      shared: 0,
      ownerID: '',
      ownerName: '',
      updatedAt: DateTime.now().toString(),
      createdAt: DateTime.now().toString(),
    );

    await sd.insertSensorEvent(sensorEvent).then((value) {
      ref.read(sensorEventProvider.notifier).doChangeState(sensorEvent);
    });*/

    /*await sd.insertSensorEvent(sensorEvent).then((value) async {
      List<Device> deviceList = await sd.findDeviceBySensor(_userID, mqttMsg['device_type']);

      Device d = Device(
          deviceID: deviceList[0].deviceID,
          deviceType: deviceList[0].deviceType,
          deviceName: deviceList[0].deviceName,
          displaySunBun: deviceList[0].displaySunBun,
          userID: deviceList[0].userID,
          status: mqttMsg['sensorState'].toString(),
          shared: 0,
          ownerID: '',
          ownerName: '',
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
    });*/
  }

  /*void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _analysisSensorEventFromDB();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _analysisSensorEventFromDB() async {
    DBHelper sd = DBHelper();

    for (var locationInfo in gLocationList) {
      List<String> sensorIDs = [];

      List<SensorInfo> sensorList = locationInfo.getSensors()!; //각 장소별 센서 목록을 얻어 온다.
      if (sensorList.isNotEmpty) {
        for (var s in sensorList) {
          sensorIDs.add(s.getSensorID()!);
        }

        List<SensorEvent> eventList = await sd.getEventList5(sensorIDs); //최근 10개의 이벤트를 가져 온다.
        if (eventList.isNotEmpty) {
          if (locationInfo.getType() == 'enterance') {

          } else if (locationInfo.getType() == 'refrigerator' || locationInfo.getType() == 'toilet') { //냉장고와 화장실은 최근 1개의 이벤트만 사용한다.
            _calcEventTime(eventList[0], locationInfo);  //최근 이벤트 시간이 일정 시간이 지나면 푸쉬를 보낸다.

          }
        }
      }
    }
  }

  void _calcEventTime(SensorEvent event, LocationInfo locationInfo) {
    var now = DateTime.now();
    var eventTime = DateTime.parse(event.getCreatedAt()!);
    int difference = int.parse(now.difference(eventTime).inSeconds.toString()); //시간차를 초단위로 구한다.

    int min = (difference / 60).round();

    if (min < 1) {


    } else if (min >= 1 && min < 5) {

      //테스트를 위해 1분으로 한다.
      if (locationInfo.getType() == 'refrigerator' && !gSendPush_After_5H_Refrigerator) {
        gSendPush_After_5H_Refrigerator = true;
        _requestPush(locationInfo.getID()!, locationInfo.getType()!, "마지막 냉장고 사용이 $min 분 전입니다.", JaeSilStateEnum.jsIn);
      }
      if (locationInfo.getType() == 'toilet' && !gSendPush_After_5H_Toilet) {
        gSendPush_After_5H_Toilet = true;
        _requestPush(locationInfo.getID()!, locationInfo.getType()!, "마지막 화장실 사용이 $min 분 전입니다.", JaeSilStateEnum.jsIn);
      }

    } else if (min >= 5 && min < 60) {

    } else if (min >= 60) {
      if (min >= 60 && min < 60 * 24) {
        int hour = (min / 60).round();

        // if (hour >= 5) {
        //   if (locationInfo.getType() == 'refrigerator' && !gSendPush_After_5H_Refrigerator) {
        //     gSendPush_After_5H_Refrigerator = true;
        //     _requestPush(locationInfo.getID()!, locationInfo.getType()!, "마지막 냉장고 사용이 $hour 시간 전입니다.", JaeSilStateEnum.jsIn.index);
        //   }
        //   if (locationInfo.getType() == 'toilet' && !gSendPush_After_5H_Toilet) {
        //     gSendPush_After_5H_Toilet = true;
        //     _requestPush(locationInfo.getID()!, locationInfo.getType()!, "마지막 화장실 사용이 $hour 시간 전입니다.", JaeSilStateEnum.jsIn.index);
        //   }
        // }
      } else {
        int day = (min / 1440).round();
      }
    }
  }*/

  /*void _analysisSensorEvent() {
    SensorEvent sensorEvent = ref.watch(sensorEventProvider)!;

    for (var locationInfo in gLocationList) {
      List<SensorInfo> sensorList = locationInfo.getSensors()!; //각장소별 센서 목록을 얻어온다.
      for (var sensor in sensorList) {
        if (sensor.getSensorID() == sensorEvent.getSensorID()) {
          if (sensor.getDeviceType() == 'emergency_button') {
            _requestPush(locationInfo.getID()!, locationInfo.getType()!, "돌봄콜 호출이 감지되었습니다.", JaeSilStateEnum.jsIn);
          }

          if (locationInfo.getType() == "refrigerator") {
            Map<String, String> data = _analysisStatus(ref.watch(sensorEventProvider)!.getState()!);
            if (data['door_window'] == '1') {
              gSendPush_After_5H_Refrigerator = false;
            }
          }

          if (locationInfo.getType() == "toilet") {
            Map<String, String> data = _analysisStatus(ref.watch(sensorEventProvider)!.getState()!);
            if (data['motion'] == '1') {
              gSendPush_After_5H_Toilet = false;
            }
          }
        }
      }
    }
  }

  Map<String, String> _analysisStatus(String statusMsg) {
    String status = removeJsonAndArray(statusMsg);

    var dataSp = status.split(',');
    Map<String, String> data = {};
    for (var element in dataSp) {
      data[element.split(':')[0].trim()] = element.split(':')[1].trim();
    }

    return data;
  }*/

  void _requestPush(String locationID, String locationType, String message, JaeSilStateEnum jaeSil) async {
    // DBHelper sd = DBHelper();
    //
    // await sd.insertAlarm(locationID, locationType, message, jaeSil.index);
    //
    // List<AlarmInfo> list = await sd.getLastAlarms();
    // ref.read(alarmProvider.notifier).doChangeState(list[0]);
    // ref.read(jaeSilStateProvider.notifier).doChangeState(jaeSil);
    //
    // try {
    //   final response = await dio.post('/users/sendpush',
    //       data: jsonEncode({
    //         "userID": widget.userID,
    //         "message": message,
    //       })
    //   );
    // } catch (e) {
    //   print(e.toString());
    // }
  }

  Future<void> _saveHub(String message) async {
    final mqttMsg = json.decode(message);

    if (gHubList.isEmpty) {
      HubInfo hubInfo = HubInfo(
        id: mqttMsg['id'],
        hubID: mqttMsg['deviceID'],
        name: mqttMsg['name'],
        userID: widget.userID,
        displaySunBun: mqttMsg['displaySunBun'],
        category: mqttMsg['category'],
        deviceType: mqttMsg['deviceType'],
        hasSubDevices: mqttMsg['hasSubDevices'],
        modelName: mqttMsg['modelName'],
        online: mqttMsg['online'],
        status: mqttMsg['status'],
        battery: mqttMsg['battery'],
        isUse: mqttMsg['isUse'],
        shared: false,
        ownerID: '',
        ownerName: '',
        createdAt: mqttMsg['createdAt'],
        updatedAt: mqttMsg['updatedAt'],
      );
      gHubList.add(hubInfo);
      _mqttStartSubscribeTo();
    } else {
      for (HubInfo hub in gHubList) {
        if (hub.getHubID() == mqttMsg['deviceID']) {

        }
      }
    }


    /*DBHelper sd = DBHelper();
    List<Hub> lists = await sd.findHub(_userID, mqttMsg['deviceID']);
    if (lists.isEmpty) {
       Hub hub = Hub(
         id: mqttMsg['id'],
         hubID: mqttMsg['deviceID'],
         name: mqttMsg['name'],
         userID: _userID,
         displaySunBun: mqttMsg['displaySunBun'],
         category: mqttMsg['category'],
         deviceType: mqttMsg['deviceType'],
         hasSubDevices: mqttMsg['hasSubDevices'] ? 1 : 0,
         modelName: mqttMsg['modelName'],
         online: mqttMsg['online'] ? 1 : 0,
         status: mqttMsg['status'],
         battery: mqttMsg['battery'],
         isUse: mqttMsg['isUse'] ? 1 : 0,
         shared: 0,
         ownerID: '',
         ownerName: '',
         updatedAt: DateTime.now().toString(),
         createdAt: DateTime.now().toString(),
       );
       await sd.insertHub(hub);
    } else {
      Hub hub = Hub(
        id: mqttMsg['id'],
        hubID: mqttMsg['deviceID'],
        name: mqttMsg['name'],
        userID: _userID,
        displaySunBun: mqttMsg['displaySunBun'],
        category: mqttMsg['category'],
        deviceType: mqttMsg['deviceType'],
        hasSubDevices: mqttMsg['hasSubDevices'] ? 1 : 0,
        modelName: mqttMsg['modelName'],
        online: mqttMsg['online'] ? 1 : 0,
        status: mqttMsg['status'],
        battery: mqttMsg['battery'],
        isUse: mqttMsg['isUse'] ? 1 : 0,
        shared: 0,
        ownerID: '',
        ownerName: '',
        updatedAt: DateTime.now().toString(),
        // createdAt: DateTime.now().toString(),
      );
      await sd.updateHub(hub);
    }*/
  }

  Future<void> _saveSensor(String message) async {
    final mqttMsg = json.decode(message);

    //센서 이름 재정의
    int nameCount = mqttMsg['nameCount'];
    String sensorName = mqttMsg['name'];
    if (mqttMsg['deviceType'] == 'motion_sensor') {
      sensorName = '움직임 센서 $nameCount (${ref.watch(currentLocationProvider)!.getName()!})';
    } else if (mqttMsg['deviceType'] == 'door_sensor') {
      sensorName = '도어 센서 $nameCount (${ref.watch(currentLocationProvider)!.getName()!})';
    } else if (mqttMsg['deviceType'] == 'emergency_button') {
      sensorName = 'SOS 버튼 $nameCount';
    }

    SensorInfo sensor = SensorInfo(
        id: mqttMsg['id'],
        sensorID: mqttMsg['sensorID'],
        name: sensorName,//mqttMsg['name'],
        userID: widget.userID,//mqttMsg['userID'],
        displaySunBun: mqttMsg['displaySunBun'],
        category: mqttMsg['category'],
        deviceType: mqttMsg['deviceType'],
        modelName: mqttMsg['modelName'],
        online: mqttMsg['online'] ? true : false,
        status: mqttMsg['status'],
        battery: mqttMsg['battery'],
        isUse: mqttMsg['isUse'] ? true : false,
        shared: false,
        ownerID: '',
        ownerName: '',
        updatedAt: DateTime.now().toString(),
        createdAt: DateTime.now().toString(),
        hubID: mqttMsg['hubID'],
        locationID: ref.watch(currentLocationProvider)!.getID()! ?? ''//gCurrentLocation.getID() ?? ''
    );
    gSensorList.add(sensor);

    ref.watch(currentLocationProvider)!.sensors!.add(sensor);

    if (sensor.getLocationID() != '') {
      final res = await dio.put(
        "/devices/setLocation",
        queryParameters: {
          "sensorID": mqttMsg['sensorID'],
          "sensorName": sensorName,
          "locationID": ref.watch(currentLocationProvider)!.getID()!,//gCurrentLocation.getID(),
          "deviceType": mqttMsg['deviceType']
        }
      );

      if (ref.watch(currentLocationProvider)!.getType() != 'emergency' || ref.watch(currentLocationProvider)!.getType() != 'customer') {
        ref.watch(currentLocationProvider)!.setDetectedDoorSensorCount(res.data['detectedDoorSensorCount']);
        ref.watch(currentLocationProvider)!.setDetectedMotionSensorCount(res.data['detectedMotionSensorCount']);
      }
    }

    ref.read(findSensorStateProvider.notifier).doChangeState(FindSensorState.findingSensorDone);


    // Get the current item
    // final currentItem = ref.watch(SensorList.provider.notifier).current;

    // Get the List<Item> from state
    // final itemList = ref.watch(SensorList.provider);

    /*DBHelper sd = DBHelper();
    List<Sensor> lists = await sd.findSensor(_userID, mqttMsg['sensorID']);
    if (lists.isEmpty) {
      Sensor sensor = Sensor(
        id: mqttMsg['id'],
        sensorID: mqttMsg['sensorID'],
        name: mqttMsg['name'],
        userID: _userID,//mqttMsg['userID'],
        displaySunBun: mqttMsg['displaySunBun'],
        category: mqttMsg['category'],
        deviceType: mqttMsg['deviceType'],
        modelName: mqttMsg['modelName'],
        online: mqttMsg['online'] ? 1 : 0,
        status: mqttMsg['status'],
        battery: mqttMsg['battery'],
        isUse: mqttMsg['isUse'] ? 1 : 0,
        shared: 0,
        ownerID: '',
        ownerName: '',
        updatedAt: DateTime.now().toString(),
        createdAt: DateTime.now().toString(),
        hubID: mqttMsg['hubID']
      );
      await sd.insertSensor(sensor);
    } else {
      Sensor sensor = Sensor(
          id: mqttMsg['id'],
          sensorID: mqttMsg['sensorID'],
          name: mqttMsg['name'],
          userID: _userID,//mqttMsg['userID'],
          displaySunBun: mqttMsg['displaySunBun'],
          category: mqttMsg['category'],
          deviceType: mqttMsg['deviceType'],
          modelName: mqttMsg['modelName'],
          online: mqttMsg['online'] ? 1 : 0,
          status: mqttMsg['status'],
          battery: mqttMsg['battery'],
          isUse: mqttMsg['isUse'] ? 1 : 0,
          shared: 0,
          ownerID: '',
          ownerName: '',
          updatedAt: DateTime.now().toString(),
          // createdAt: DateTime.now().toString(),
          hubID: mqttMsg['hubID']
      );
      await sd.updateSensor(sensor);
    }*/
  }

  Future<void> _delSensor(String sensorID) async {
    DBHelper sd = DBHelper();
    await sd.deleteSensor(sensorID);
  }

  /*Future<void> _saveDevice(String deviceID, String deviceType) async {
    DBHelper sd = DBHelper();
    int? count = await sd.getDeviceCountByType(_userID, deviceType);
    count = count! + 1;
    int? displaySunBun = await sd.getDeviceCount(_userID);
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
      userID: _userID,
      status: "",
      shared: 0,
      ownerID: '',
      ownerName: '',
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
  }*/

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
        if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensor) {
          // final topic = ref.watch(commandTopicProvider);
          mqttSendCommand(MqttCommand.mcParing, mqttMsg['deviceID']);
        }
      }

    } else if (topic == ref.watch(resultTopicProvider)) {
      if (mqttMsg['event'] == 'gatewayADD') {
        if (mqttMsg['state'] == 'success') {
          // _saveDevice(mqttMsg['deviceID'], Constants.DEVICE_TYPE_HUB);
          _saveHub(message);
        } else if (mqttMsg['state'] == 'failure') {

        }
        _goHome();
      } else if (mqttMsg['event'] == 'device_add') {
        if (mqttMsg['state'] == 'device add success') {
          // _saveDevice(mqttMsg['deviceID'], mqttMsg['device_type']);
          _saveSensor(message);


        } else if (mqttMsg['state'] == 'device add failure') {

        }

        // _goHome();
      } else if (mqttMsg['event'] == 'device_del') {
        if (mqttMsg['state'] == 'device del success') {
          _delDevice(mqttMsg['deviceID']);
          _delSensor(mqttMsg['deviceID']);
        }
      }

      if (mqttMsg['event'] == 'alarm_update') {
        Map<String, dynamic> alarm = mqttMsg['alarm'];

        String createdAt = convertTimeStringToLocal(alarm['createdAt']);
        String updatedAt = convertTimeStringToLocal(alarm['updatedAt']);

        AlarmInfo alarmInfo = AlarmInfo(
            id: alarm['id'],
            alarm: alarm['alarm'],
            jaeSilStatus: alarm['jaeSilStatus'],
            createdAt: createdAt,
            updatedAt: updatedAt,
            userID: alarm['userID'],
            locationID: alarm['locationID']
        );

        gLastAlarm = alarmInfo;
        ref.read(alarmProvider.notifier).doChangeState(gLastAlarm);
        ref.read(jaeSilStateProvider.notifier).doChangeState(JaeSilStateEnum.values[gLastAlarm.getJaeSilStatus()!]);

      } else if (mqttMsg['event'] == 'device_detected') {
        Map<String, dynamic> msg = mqttMsg['sensorEvent'];

        String createdAt = convertTimeStringToLocal(msg['createdAt']);
        String updatedAt = convertTimeStringToLocal(msg['updatedAt']);

        SensorEvent se = SensorEvent(
          id: msg['id'],
          deviceType: msg['deviceType'],
          accountID: msg['accountID'],
          event: msg['event'],
          state: msg['state'].toString(),
          createdAt: createdAt,
          updatedAt: updatedAt,
          deletedAt: msg['deletedAt'],
          userID: msg['userID'],
          sensorID: msg['sensorID'],
          locationID: msg['locationID'],
        );

        if (msg['deviceType'] != Constants.DEVICE_TYPE_MOTION || !msg['state'].toString().contains('motion: 0')) {
          ref.read(jaeSilStateProvider.notifier).doChangeState(JaeSilStateEnum.jsIn);
        }

        for (var location in gLocationList) {
          if (location.getID() == se.getLocationID()) {
            location.getEvents()!.clear();
            location.getEvents()!.add(se);
          }
        }

        ref.read(sensorEventProvider.notifier).doChangeState(se);
      }
    }
  }


}