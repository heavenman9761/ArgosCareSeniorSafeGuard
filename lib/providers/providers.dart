import 'package:argoscareseniorsafeguard/pages/home/jaesil_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';
import 'package:argoscareseniorsafeguard/models/alarm_infos.dart';

class MqttConnectionStateNotifier extends StateNotifier<MqttConnectionState> {
  MqttConnectionStateNotifier(): super(MqttConnectionState.disconnected);

  void doChangeState(MqttConnectionState connectionState) {
    state = connectionState;
  }
}

final mqttCurrentStateProvider = StateNotifierProvider<MqttConnectionStateNotifier, MqttConnectionState>((ref) {
  return MqttConnectionStateNotifier();
});

class FindHubStateNotifier extends StateNotifier<FindHubState> {
  FindHubStateNotifier(): super(FindHubState.none);

  void doChangeState(FindHubState findHubState) {
    state = findHubState;
  }
}

final findHubStateProvider = StateNotifierProvider<FindHubStateNotifier, FindHubState>((ref) {
  return FindHubStateNotifier();
});

//--------- 센서 검색 Provider ---------------------------------------------------
class FindSensorStateNotifier extends StateNotifier<FindSensorState> {
  FindSensorStateNotifier(): super(FindSensorState.none);

  void doChangeState(FindSensorState findSensorState) {
    state = findSensorState;
  }
}

final findSensorStateProvider = StateNotifierProvider<FindSensorStateNotifier, FindSensorState>((ref) {
  return FindSensorStateNotifier();
});

//--------- 재실 상태 Provider ---------------------------------------------------
class JaeSilStateNotifier extends StateNotifier<JaeSilStateEnum> {
  JaeSilStateNotifier() : super(JaeSilStateEnum.jsNone);

  void doChangeState(JaeSilStateEnum jaeSilState) {
    state = jaeSilState;
  }
}

final jaeSilStateProvider = StateNotifierProvider<JaeSilStateNotifier, JaeSilStateEnum>((ref) {
  return JaeSilStateNotifier();
});


//--------- CurrentLocation을 셋팅할 때 사용하는 Provider ---------------------------------------------------
class CurrentLocationNotifier extends StateNotifier<LocationInfo?> {
  CurrentLocationNotifier() : super(null);

  void doChangeState(LocationInfo location) {
    state = location;
  }
}

final currentLocationProvider = StateNotifierProvider<CurrentLocationNotifier, LocationInfo?>((ref) {
  return CurrentLocationNotifier();
});

//--------- 새로운 이벤트를 받을 때 사용하는 Provider ---------------------------------------------------
class SensorEventNotifier extends StateNotifier<SensorEvent?> {
  SensorEventNotifier() : super(null);

  void doChangeState(SensorEvent sensorEvent) {
    state = sensorEvent;
  }
}

final sensorEventProvider = StateNotifierProvider<SensorEventNotifier, SensorEvent?>((ref) {
  return SensorEventNotifier();
});


//--------- 새로운 알림이 저장될 때사용하는 Provider ---------------------------------------------------
class AlarmNotifier extends StateNotifier<AlarmInfo?> {
  AlarmNotifier() : super(null);

  void doChangeState(AlarmInfo alarmInfo) {
    state = alarmInfo;
  }
}

final alarmProvider = StateNotifierProvider<AlarmNotifier, AlarmInfo?>((ref) {
  return AlarmNotifier();
});

//-------------------------------------------------------------------------------------------

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

//------------------------------------------------------------------

final alarmEntireEnableProvider = StateProvider<bool>((ref) {
  return true;
});

//------------------------------------------------------------------

final alarmHumidityEnableProvider = StateProvider<bool>((ref) {
  return true;
});

final alarmHumidityStartTimeProvider = StateProvider<String>((ref) {
  return "00:00";
});

final alarmHumidityEndTimeProvider = StateProvider<String>((ref) {
  return "23:59";
});

final alarmHumidityStartValueProvider = StateProvider<int>((ref) {
  return 0;
});

final alarmHumidityEndValueProvider = StateProvider<int>((ref) {
  return 100;
});

final alarmTemperatureStartValueProvider = StateProvider<int>((ref) {
  return -10;
});

final alarmTemperatureEndValueProvider = StateProvider<int>((ref) {
  return 50;
});

//------------------------------------------------------------------

final alarmEmergencyEnableProvider = StateProvider<bool>((ref) {
  return true;
});

final alarmEmergencyStartTimeProvider = StateProvider<String>((ref) {
  return "00:00";
});

final alarmEmergencyEndTimeProvider = StateProvider<String>((ref) {
  return "23:59";
});

//------------------------------------------------------------------

final alarmMotionEnableProvider = StateProvider<bool>((ref) {
  return true;
});

final alarmMotionStartTimeProvider = StateProvider<String>((ref) {
  return "00:00";
});

final alarmMotionEndTimeProvider = StateProvider<String>((ref) {
  return "23:59";
});

//------------------------------------------------------------------

final alarmSmokeEnableProvider = StateProvider<bool>((ref) {
  return true;
});

final alarmSmokeStartTimeProvider = StateProvider<String>((ref) {
  return "00:00";
});

final alarmSmokeEndTimeProvider = StateProvider<String>((ref) {
  return "23:59";
});

//------------------------------------------------------------------

final alarmIlluminanceEnableProvider = StateProvider<bool>((ref) {
  return true;
});

final alarmIlluminanceStartTimeProvider = StateProvider<String>((ref) {
  return "00:00";
});

final alarmIlluminanceEndTimeProvider = StateProvider<String>((ref) {
  return "23:59";
});

final alarmIlluminanceStartValueProvider = StateProvider<int>((ref) {
  return 1;
});

final alarmIlluminanceEndValueProvider = StateProvider<int>((ref) {
  return 10;
});

//------------------------------------------------------------------

final alarmDoorEnableProvider = StateProvider<bool>((ref) {
  return true;
});

final alarmDoorStartTimeProvider = StateProvider<String>((ref) {
  return "00:00";
});

final alarmDoorEndTimeProvider = StateProvider<String>((ref) {
  return "23:59";
});

//------------------------------------------------------------------

final alarmReceivedProvider = StateProvider<int>((ref) {
  return 0;
});

//------------------------------------------------------------------

final phoneCertificationProvider = StateProvider<bool>((ref) {
  return false;
});

final requestShareListProviderCount = StateProvider<int>((ref) {
  return 0;
});

final homeBottomNavigationProvider = StateProvider<int>((ref) {
  return 0;
});