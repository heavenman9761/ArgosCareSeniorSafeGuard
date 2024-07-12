import 'dart:io';
import 'dart:isolate';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'package:argoscareseniorsafeguard/constants.dart';

class ForegroundTaskService{
  static init(){
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: '돌봐효 서비스',
        channelDescription: '돌봐효 서비스가 시작되었습니다.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        enableVibration: true,
        playSound: true,
        isSticky: true, //서비스가 중단되었을 때 재시작
        visibility: NotificationVisibility.VISIBILITY_PUBLIC, //VISIBILITY_PUBLIC -> 제목/내용이 잠금화면에서 보임, VISIBILITY_PRIVATE -> 잠금화면에서 제목만 보임, VISIBILITY_SECRET -> 잠금화면에서 보이지 않음.
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.orange,
        ),
        /*buttons: [
          const NotificationButton(
            id: 'sendButton',
            text: 'Send',
            textColor: Colors.orange,
          ),
          const NotificationButton(
            id: 'testButton',
            text: 'Test',
            textColor: Colors.grey,
          ),
        ],*/
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 1000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }
}

class ForegroundTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  late MqttServerClient mqttClient;
  String _mqttMsg = '';
  String _hubID = '';

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    print("ForegroundTaskHandler - onStart()");
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final hubID = await FlutterForegroundTask.getData<String>(key: 'startMqtt');
    print('ForegroundTaskHandler - hubID: $hubID');
    if (hubID != null) {
      _hubID = hubID;

      foregroundMqttInit(Constants.MQTT_HOST, Constants.MQTT_PORT, Constants.MQTT_ID, Constants.MQTT_PASSWORD);
    }
  }

  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    // Send data to the main isolate.
    if (_mqttMsg != "") {
      String now = DateFormat("MM-dd HH:mm").format(DateTime.now());
      /*FlutterForegroundTask.updateService(
        notificationTitle: '돌봐효 서비스',
        notificationText: '[$now] 새로운 알림이 도착했습니다.',
      );*/

      Vibrate.vibrate();

      sendPort?.send(_mqttMsg);
      _mqttMsg = "";
    }
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('ForegroundTaskHandler - onDestroy()');
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('ForegroundTaskHandler - onNotificationButtonPressed >> $id');
  }

  // Called when the notification itself on the Android platform is pressed.
  //
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // this function to be called.
  @override
  void onNotificationPressed() {
    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }

  void foregroundMqttInit(String host, int port, String id, String password) async {
    var uuid = const Uuid();
    String uuid_v4 = uuid.v4();
    mqttClient = MqttServerClient(host, uuid_v4);

    mqttClient.logging(on: false);
    mqttClient.setProtocolV311();
    mqttClient.port = port;
    mqttClient.keepAlivePeriod = 20;
    mqttClient.connectTimeoutPeriod = 2000; // milliseconds
    mqttClient.onDisconnected = onDisconnected;
    mqttClient.onConnected = onConnected;
    mqttClient.onSubscribed = onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(uuid_v4)
        .withWillTopic('will-topic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .authenticateAs(id, password)
        .withWillQos(MqttQos.exactlyOnce);

    mqttClient.connectionMessage = connMess;

    try {
      await mqttClient.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('ForegroundTaskHandler::Mqtt client exception - $e');
      mqttClient.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('ForegroundTaskHandler::Mqtt socket exception - $e');
      mqttClient.disconnect();
    }

    if (mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
    } else {
      print('ForegroundTaskHandler::ERROR Mosquitto client connection failed - disconnecting, status is ${mqttClient.connectionStatus}');
      mqttClient.disconnect();
    }

    mqttClient.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      String message = utf8.decode(pt.runes.toList());

      _mqttMsg = message ?? '';

    });

    mqttClient.published!.listen((MqttPublishMessage message) {
      // logger.i('EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    });
  }

  void onDisconnected() {
    print("ForegroundTaskHandler - mqtt disconnected(), try connect again!!!");
    foregroundMqttInit(Constants.MQTT_HOST, Constants.MQTT_PORT, Constants.MQTT_ID, Constants.MQTT_PASSWORD);
  }

  /// The successful connect callback
  void onConnected() {
    debugPrint('ForegroundTaskHandler - MqttClient connection was successful');
    mqttClient.subscribe('result/$_hubID', MqttQos.atMostOnce);
  }

  void onSubscribed(String topic) {
    debugPrint("ForegroundTaskHandler - onSubscribed() - $topic");
  }
}