import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:argoscareseniorsafeguard/mqtt/MQTTAppState.dart';
import 'package:argoscareseniorsafeguard/mqtt/IMQTTController.dart';
import 'package:argoscareseniorsafeguard/providers/Providers.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';
import 'package:argoscareseniorsafeguard/pages/add_hub_page1.dart';
import 'package:argoscareseniorsafeguard/Constants.dart';
import 'package:argoscareseniorsafeguard/models/devicelist.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  //final List<Sensor> _sensorList = [];
  final List<String> _sensorList = [
    "허브",
    '문열림 센서',
    '동작감지센서',
    '화재센서',
    '온습도센서',
    '조도센서',
    '응급벨'
  ];

  late IMQTTController _manager;
  bool loadingDeviceList = false;

  String resultTopic = '';
  String commandTopic = '';
  String requestTopic = '';

  Future<List<DeviceList>> loadDeviceList() async {
    DBHelper db = DBHelper();
    return await db.deviceLists();
  }

  Future<void> getHubIdToPrefs() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();

      final deviceId = pref.getString('deviceID') ?? '';
      if (deviceId != '') {
        resultTopic = 'result/$deviceId';
        commandTopic = 'command/$deviceId';
        requestTopic = 'request/$deviceId';

        _manager.subScribeTo(resultTopic);
        logger.i('subscribed to $resultTopic');

        _manager.subScribeTo(requestTopic);
        logger.i('subscribed to $requestTopic');

        // mqttCommand(MqttCommand.mcSensorList, deviceId);
      } else {
        logger.i('not hubID');
      }
    } catch (e) {
      logger.e(e);
    }
  }

  void _mqttGetMessageTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_manager.currentState.getReceivedTopic != '') {
        logger.w(_manager.currentState.getReceivedTopic);
      }
      if (_manager.currentState.getReceivedTopic == resultTopic &&
          _manager.currentState.getReceivedText != '') {
        final mqttMsg = json.decode(_manager.currentState.getReceivedText);
        logger.i(mqttMsg);

        if (mqttMsg['event'] == 'gatewayADD') {
          //gatewayADD는 처음 hub를 찾으면 들어온다.
          logger.i('received event: gatewayADD');
          Navigator.popUntil(
            context,
            (route) {
              return route.isFirst;
            },
          );
        }
      } else if (_manager.currentState.getReceivedTopic == requestTopic &&
          _manager.currentState.getReceivedText != '') {
        final mqttMsg = json.decode(_manager.currentState.getReceivedText);
        logger.i(mqttMsg);

        if (mqttMsg['order'] == 'sensorList') {
          logger.i('received event: sensorList');
        } else if (mqttMsg['order'] == 'device_add') {
          logger.i('received event: device_add');
        }

        if (mqttMsg['event'] == 'device_detected') {
          logger.i('received event: device_detected');
        }
      }
      _manager.currentState.setReceivedText('');
      _manager.currentState.setReceivedTopic('');

      // setState(() {
      //
      // });
    });
  }

  void mqttCommand(MqttCommand mc, String deviceId) {
    var now = DateTime.now();
    String formatDate = DateFormat('yyyyMMdd_HHmmss').format(now);

    if (mc == MqttCommand.mcSensorList) {
      //펌웨어 에서 기능 구현 안됨.
      _manager.publishTopic(
          commandTopic,
          jsonEncode({
            "order": "sensorList",
            "deviceID": deviceId,
            "time": formatDate
          }));
    } else if (mc == MqttCommand.mcParing) {
      _manager.publishTopic(
          commandTopic,
          jsonEncode({
            "order": "pairingEnabled",
            "deviceID": deviceId,
            "time": formatDate
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // onPressed handler
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
                    print('icon press');
                  },
                ),
              ]
            )
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _loadDeviceList(),
              builder: (context, snapshot) {
                final List<String>? devices = snapshot.data;
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
                          final device = devices[index];
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Card(
                              color: Colors.white,
                              surfaceTintColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.0),
                                onTap: () {
                                  debugPrint('card press');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    color: Colors.transparent,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(device,
                                                  style: const TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.grey)),
                                              IconButton(
                                                icon: const Icon(Icons.more_horiz),
                                                tooltip: "Menu",
                                                color: Colors.grey,
                                                onPressed: () {
                                                  debugPrint('icon press');
                                                },
                                              ),
                                            ]
                                        ),
                                        const Text(
                                          "상태",
                                          style:
                                          TextStyle(fontSize: 12.0, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
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
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const AddHubPage1();
        }));
      }, //_find
      label: const Text("기기등록"),
      isExtended: true, // ingEsp32 ? null : _findEsp32,
      icon: const Icon(Icons.add, size: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initMqtt();
  }

  @override
  void initState() {
    getMyDeviceToken();

    _mqttGetMessageTimer();

    _checkPermissions();

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

  Future<List<String>> _loadDeviceList() async {
    return _sensorList;
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

  void initMqtt() {
    _manager = ref.watch(mqttManagerProvider);

    _manager.initializeMQTTClient(
        host: '14.42.209.174', identifier: 'SCT Senior Care');
    _manager.connect();

    Future.delayed(const Duration(seconds: 1), () {
      if (_manager.currentState.getAppConnectionState ==
              MQTTAppConnectionState.connected ||
          _manager.currentState.getAppConnectionState ==
              MQTTAppConnectionState.connectedSubscribed) {
        logger.i("MQTT Connected!");

        getHubIdToPrefs();
      }
    });
  }

  Widget waitWidget() {
    return loadingDeviceList
        ? const CircularProgressIndicator(backgroundColor: Colors.blue)
        : const Text("");
  }
}
