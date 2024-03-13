import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:argoscareseniorsafeguard/Constants.dart';

import 'package:argoscareseniorsafeguard/providers/Providers.dart';

late MqttServerClient client;
late WidgetRef _ref;

void mqttAddSubscribeTo(String topic) {
  client.subscribe(topic, MqttQos.atMostOnce);
}

void mqttDeleteSubscribe(String topic) {
  client.unsubscribe(topic);
}

void mqttPublish(String topic, String msg) {
  final builder = MqttClientPayloadBuilder();
  builder.addString(msg);

  client.subscribe(topic, MqttQos.exactlyOnce);
  client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
}

void mqttDisconnect() {
  client.disconnect();
}

void mqttInit(WidgetRef ref, String host, int port, String identifier, String id, String password) async {
  _ref = ref;
  client = MqttServerClient(host, identifier);

  client.logging(on: false);
  client.setProtocolV311();
  client.port = port;
  client.keepAlivePeriod = 20;
  client.connectTimeoutPeriod = 2000; // milliseconds
  client.onDisconnected = onDisconnected;
  client.onConnected = onConnected;
  client.onSubscribed = onSubscribed;

  final connMess = MqttConnectMessage()
      .withClientIdentifier(identifier)
      .withWillTopic('will-topic') // If you set this you must set a will message
      .withWillMessage('My Will message')
      .startClean() // Non persistent session for testing
      .authenticateAs(id, password)
      .withWillQos(MqttQos.atLeastOnce);

  client.connectionMessage = connMess;

  try {
    await client.connect();
  } on NoConnectionException catch (e) {
    // Raised by the client when connection fails.
    logger.e('EXAMPLE::client exception - $e');
    client.disconnect();
  } on SocketException catch (e) {
    // Raised by the socket layer
    logger.e('EXAMPLE::socket exception - $e');
    client.disconnect();
  }

  if (client.connectionStatus!.state == MqttConnectionState.connected) {
  } else {
    logger.e('EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
  }

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    ref.read(mqttCurrentTopicProvider.notifier).state = c[0].topic;
    ref.read(mqttCurrentMessageProvier.notifier).state = pt;
  });

  client.published!.listen((MqttPublishMessage message) {
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
}

/// The unsolicited disconnect callback
void onDisconnected() {
  if (client.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
    print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
  } else {
    print('EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
  }

  _ref.read(mqttCurrentStateProvider.notifier).doChangeState(MqttConnectionState.disconnected);
}

/// The successful connect callback
void onConnected() {
  print('EXAMPLE::OnConnected client callback - Client connection was successful');
  _ref.read(mqttCurrentStateProvider.notifier).doChangeState(MqttConnectionState.connected);
}

/// Pong callback
void pong() {
  print('EXAMPLE::Ping response client callback invoked');
}