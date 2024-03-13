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
import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/pages/add_hub_page1.dart';
import 'package:argoscareseniorsafeguard/pages/add_sensor_page1.dart';
import 'package:argoscareseniorsafeguard/Constants.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late List<Device> _deviceList = [];
  late IMQTTController _manager;
  bool loadingDeviceList = false;

  Future<void> getHubIdToPrefs() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();

      final deviceId = pref.getString('deviceID') ?? '';
      if (deviceId != '') {
        ref.read(resultTopicProvider.notifier).state = 'result/$deviceId';
        ref.read(commandTopicProvider.notifier).state = 'command/$deviceId';
        ref.read(requestTopicProvider.notifier).state = 'request/$deviceId';

        _manager.subScribeTo(ref.watch(resultTopicProvider));
        logger.i('subscribed to ${ref.watch(resultTopicProvider)}');

        _manager.subScribeTo(ref.watch(requestTopicProvider));
        logger.i('subscribed to ${ref.watch(requestTopicProvider)}');
      } else {
        logger.i('not hubID');
      }
    } catch (e) {
      logger.e(e);
    }
  }

  void _mqttStartSubscribeTo() async {
    DBHelper sd = DBHelper();
    List<Device> hubList = await sd.getDeviceOfHubs();
    for (var hub in hubList) {
      ref.read(resultTopicProvider.notifier).state = 'result/${hub.getDeviceID()}';
      ref.read(commandTopicProvider.notifier).state = 'command/${hub.getDeviceID()}';
      ref.read(requestTopicProvider.notifier).state = 'request/${hub.getDeviceID()}';

      _manager.subScribeTo(ref.watch(resultTopicProvider));
      logger.i('subscribed to ${ref.watch(resultTopicProvider)}');

      _manager.subScribeTo(ref.watch(requestTopicProvider));
      logger.i('subscribed to ${ref.watch(requestTopicProvider)}');
    }
  }

  Future<void> saveHub(String deviceID) async {
    DBHelper sd = DBHelper();
    int? count = await sd.getDeviceCount();

    Device device = Device(
      deviceID: deviceID,
      deviceType: Constants.DEVICE_TYPE_HUB,
      deviceName: 'hub1',
      displaySunBun: count,
      accountID: 'dn9318dn@naver.com',
      state: " ",
      updateTime: DateTime.now().toString(),
      createTime: DateTime.now().toString(),
    );

    await sd.insertDevice(device).then((value) {
      setState(() {

      });
    });
  }

  void _mqttGetMessageTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_manager.currentState.getReceivedTopic != '' && _manager.currentState.getReceivedText != '') {

        final mqttMsg = json.decode(_manager.currentState.getReceivedText);
        //
        logger.w(_manager.currentState.getReceivedTopic);
        logger.w(mqttMsg);

        if (_manager.currentState.getReceivedTopic == ref.watch(requestTopicProvider)) {
          logger.w('request - $mqttMsg');
          if (mqttMsg['order'] == 'device_add' || mqttMsg['order'] == 'pairingEnabled') {
            // Navigator.popUntil(
            //   context,
            //       (route) {
            //     return route.isFirst;
            //   },
            // );
          }
        } else if (_manager.currentState.getReceivedTopic == ref.watch(resultTopicProvider)) {
          logger.i('result - $mqttMsg');
          if (mqttMsg['event'] == 'gatewayADD') {
            Navigator.popUntil(
              context,
                  (route) {
                return route.isFirst;
              },
            );
            if (mqttMsg['state'] == 'success') {
              saveHub(mqttMsg['deviceID']);

            } else if (mqttMsg['state'] == 'failure') {

            }
            //gatewayADD는 처음 hub를 찾으면 들어온다.
            // Navigator.popUntil(context, (route) {
            //     return route.isFirst;
            //   },
            // );

          } else if (mqttMsg['event'] == 'device_add') {
            if (mqttMsg['state'] == 'device add success') {

            } else if (mqttMsg['state'] == 'device add failure') {

            }
          }
        }
        _manager.currentState.setReceivedText('');
        _manager.currentState.setReceivedTopic('');

        // setState(() {
        //
        // });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(_manager, (previous, next) {
      print('result ---------------------------------');
    });

    ref.listen(_manager as ProviderListenable<Object>, (previous, next) {
      print('request --------------------------------');
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
                                              Text(device.getDeviceName()!,
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
      onPressed: () => addDevice(),
      label: const Text("기기 등록"),
      isExtended: true, // ingEsp32 ? null : _findEsp32,
      icon: const Icon(Icons.add, size: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void addDevice() {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initMqtt();
  }

  @override
  void initState() {
    getMyDeviceToken();

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
        _mqttStartSubscribeTo();
        _mqttGetMessageTimer();
      }
    });
  }

  Widget waitWidget() {
    return loadingDeviceList
        ? const CircularProgressIndicator(backgroundColor: Colors.blue)
        : const Text("");
  }
}
