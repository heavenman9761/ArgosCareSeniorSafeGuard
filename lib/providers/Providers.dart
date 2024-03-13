import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:argoscareseniorsafeguard/mqtt/MQTTManager.dart';
import 'package:argoscareseniorsafeguard/mqtt/IMQTTController.dart';
import 'package:mqtt_client/mqtt_client.dart';

final mqttManagerProvider = ChangeNotifierProvider<IMQTTController>((ref) {
  return MQTTManager();
});

final hubNameProvider = StateProvider<String>((ref) {
  return "";
});

final resultTopicProvider = StateProvider<String>((ref) {
  return "";
});

final requestTopicProvider = StateProvider<String>((ref) {
  return "";
});

final commandTopicProvider = StateProvider<String>((ref) {
  return "";
});

final mqttReceivedTopic = StateProvider<String>((ref) {
  return "";
});

final mqttReceivedMsg = StateProvider<String>((ref) {
  return "";
});

final mqttCurrentMessageProvier = StateProvider<String>((ref) {
  return "";
});

final mqttCurrentTopicProvider = StateProvider<String>((ref) {
  return "";
});

final mqttCurrentStateProvider = StateNotifierProvider<MqttConnectionStateNotifier, MqttConnectionState>((ref) {
  return MqttConnectionStateNotifier();
});

class MqttConnectionStateNotifier extends StateNotifier<MqttConnectionState> {
  MqttConnectionStateNotifier(): super(MqttConnectionState.disconnected);

  void doChangeState(MqttConnectionState connectionState) {
    state = connectionState;
  }
}
