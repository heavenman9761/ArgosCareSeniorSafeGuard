import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';

enum MqttCommand {mcSensorList, mcParing}

late MqttServerClient mqttClient;
late WidgetRef _ref;

void mqttSendCommand(String topic, MqttCommand mc, String deviceID) {
  var now = DateTime.now();
  String formatDate = DateFormat('yyyyMMdd_HHmmss').format(now);

  if (mc == MqttCommand.mcSensorList) {
    //펌웨어 에서 기능 구현 안됨.
    mqttPublish(
        topic,
        jsonEncode({
          "order": "sensorList",
          "deviceID": deviceID,
          "time": formatDate
        }));
  } else if (mc == MqttCommand.mcParing) {
    mqttPublish(
        topic,
        jsonEncode({
          "order": "pairingEnabled",
          "deviceID": deviceID,
          "time": formatDate
        }));
  }
}

void mqttAddSubscribeTo(String topic) {
  mqttClient.subscribe(topic, MqttQos.atMostOnce);
}

void mqttDeleteSubscribe(String topic) {
  mqttClient.unsubscribe(topic);
}

void mqttPublish(String topic, String msg) {
  final builder = MqttClientPayloadBuilder();
  builder.addString(msg);

  mqttClient.subscribe(topic, MqttQos.exactlyOnce);
  mqttClient.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
}

void mqttDisconnect() {
  mqttClient.disconnect();
}

void mqttInit(WidgetRef ref, String host, int port, String identifier, String id, String password) async {
  _ref = ref;
  mqttClient = MqttServerClient(host, identifier);

  mqttClient.logging(on: false);
  mqttClient.setProtocolV311();
  mqttClient.port = port;
  mqttClient.keepAlivePeriod = 20;
  mqttClient.connectTimeoutPeriod = 2000; // milliseconds
  mqttClient.onDisconnected = onDisconnected;
  mqttClient.onConnected = onConnected;
  mqttClient.onSubscribed = onSubscribed;

  final connMess = MqttConnectMessage()
      .withClientIdentifier(identifier)
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
    logger.e('EXAMPLE::client exception - $e');
    mqttClient.disconnect();
  } on SocketException catch (e) {
    // Raised by the socket layer
    logger.e('EXAMPLE::socket exception - $e');
    mqttClient.disconnect();
  }

  if (mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
  } else {
    logger.e('EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${mqttClient.connectionStatus}');
    mqttClient.disconnect();
  }

  mqttClient.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    // print('${c[0].topic} / $pt');

    ref.read(mqttCurrentTopicProvider.notifier).state = c[0].topic;
    ref.read(mqttCurrentMessageProvider.notifier).state = pt;
  });

  mqttClient.published!.listen((MqttPublishMessage message) {
    // logger.i('EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
  });

  // const pubTopic = 'result/00003494543ebb58';
  // final builder = MqttClientPayloadBuilder();
  // builder.addString('Hello from mqtt_client');
  //
  // client.subscribe(pubTopic, MqttQos.exactlyOnce);
  // client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);

  //logger.i('EXAMPLE::Sleeping....');
  // await MqttUtilities.asyncSleep(60);
  //
  // //logger.i('EXAMPLE::Unsubscribing');
  // client.unsubscribe(topic);
  //
  // await MqttUtilities.asyncSleep(2);
  // logger.i('EXAMPLE::Disconnecting');
  // client.disconnect();
  // logger.i('EXAMPLE::Exiting normally');
}

void onSubscribed(String topic) {
  debugPrint("onSubscribed() - $topic");
}

/// The unsolicited disconnect callback
void onDisconnected() {
  if (mqttClient.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
    debugPrint('EXAMPLE::OnDisconnected callback is solicited, this is correct');
  } else {
    debugPrint('EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
  }

  _ref.read(mqttCurrentStateProvider.notifier).doChangeState(MqttConnectionState.disconnected);
}

/// The successful connect callback
void onConnected() {
  debugPrint('EXAMPLE::OnConnected client callback - Client connection was successful');
  _ref.read(mqttCurrentStateProvider.notifier).doChangeState(MqttConnectionState.connected);

  // mqttPublish('request/00003494543ebb58', jsonEncode({
  //   "order": "device_add",
  //   "deviceID": "aabbccdd11223344",
  //   "accountID": "dn9318dn@gmail.com",
  //   "device_type": "door_sensor",
  //   "time": "20240321_175100"
  // }));
}

/// Pong callback
void pong() {
  debugPrint('EXAMPLE::Ping response client callback invoked');
}