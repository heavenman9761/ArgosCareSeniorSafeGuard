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
  final List<Sensor> _sensorList = [];

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
      if (_manager.currentState.getReceivedTopic == resultTopic && _manager.currentState.getReceivedText != '') {
        final mqttMsg = json.decode(_manager.currentState.getReceivedText);
        logger.i(mqttMsg);

        if (mqttMsg['event'] == 'gatewayADD') { //gatewayADD는 처음 hub를 찾으면 들어온다.
          logger.i('received event: gatewayADD');
          Navigator.popUntil(context, (route) {
            return route.isFirst;
          },
          );
        }
      } else if (_manager.currentState.getReceivedTopic == requestTopic && _manager.currentState.getReceivedText != '') {
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

      setState(() {

      });
    });
  }

  void mqttCommand(MqttCommand mc, String deviceId) {
    var now = DateTime.now();
    String formatDate = DateFormat('yyyyMMdd_HHmmss').format(now);

    if (mc == MqttCommand.mcSensorList) { //펌웨어 에서 기능 구현 안됨.
      _manager.publishTopic(commandTopic, jsonEncode({
        "order": "sensorList",
        "deviceID": deviceId,
        "time": formatDate
      }));
    } else if (mc == MqttCommand.mcParing) {
      _manager.publishTopic(commandTopic, jsonEncode({
        "order": "pairingEnabled",
        "deviceID": deviceId,
        "time": formatDate
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    _manager = ref.watch(mqttManagerProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Home'),
        // actions: [
        //   Permissions(),
        // ],
      ),
      body: FutureBuilder<List<DeviceList>>(
        future: loadDeviceList(),
        builder: (context, snapshot) {
          final List<DeviceList>? devices = snapshot.data;
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
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        title: Text(device.deviceType),
                        trailing: const Icon(Icons.add),
                        onTap: () {

                          // Get.toNamed("/Setting_Hub", arguments: {"hubName": device});
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return const AddHubPage1();
                              }));
                        },
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
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return const AddHubPage1();
                }));

          },//_findingEsp32 ? null : _findEsp32,
          child: const Icon(Icons.add)),
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

    _manager.initializeMQTTClient(host: '14.42.209.174', identifier: 'SCT Senior Care');
    _manager.connect();

    Future.delayed(const Duration(seconds: 1), () {
      if (_manager.currentState.getAppConnectionState == MQTTAppConnectionState.connected
          || _manager.currentState.getAppConnectionState == MQTTAppConnectionState.connectedSubscribed) {
        logger.i("MQTT Connected!");

        getHubIdToPrefs();
      }
    });
  }

  Widget waitWidget() {
    return loadingDeviceList ? const CircularProgressIndicator(backgroundColor: Colors.blue) : const Text("");
  }
}

