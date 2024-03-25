import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:argoscareseniorsafeguard/constants.dart';

final mqttCurrentStateProvider = StateNotifierProvider<MqttConnectionStateNotifier, MqttConnectionState>((ref) {
  return MqttConnectionStateNotifier();
});

final findHubStateProvider = StateNotifierProvider<FindHubStateNotifier, ConfigState>((ref) {
  return FindHubStateNotifier();
});

class MqttConnectionStateNotifier extends StateNotifier<MqttConnectionState> {
  MqttConnectionStateNotifier(): super(MqttConnectionState.disconnected);

  void doChangeState(MqttConnectionState connectionState) {
    state = connectionState;
  }
}

class FindHubStateNotifier extends StateNotifier<ConfigState> {
  FindHubStateNotifier(): super(ConfigState.none);

  void doChangeState(ConfigState findHubState) {
    state = findHubState;
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