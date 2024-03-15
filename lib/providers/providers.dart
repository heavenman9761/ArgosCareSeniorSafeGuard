import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';

final mqttCurrentStateProvider = StateNotifierProvider<MqttConnectionStateNotifier, MqttConnectionState>((ref) {
  return MqttConnectionStateNotifier();
});

class MqttConnectionStateNotifier extends StateNotifier<MqttConnectionState> {
  MqttConnectionStateNotifier(): super(MqttConnectionState.disconnected);

  void doChangeState(MqttConnectionState connectionState) {
    state = connectionState;
  }
}

final mqttCurrentMessageProvider = StateProvider<String>((ref) {
  return "";
});

final mqttCurrentTopicProvider = StateProvider<String>((ref) {
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

final doorSensorStateProvider = StateProvider<String>((ref) {
  return "";
});

final motionSensorStateProvider = StateProvider<String>((ref) {
  return "";
});

final smokeSensorStateProvider = StateProvider<String>((ref) {
  return "";
});

final emergencySensorStateProvider = StateProvider<String>((ref) {
  return "";
});

final humiditySensorStateProvider = StateProvider<String>((ref) {
  return "";
});

final illuminanceSensorStateProvider = StateProvider<String>((ref) {
  return "";
});