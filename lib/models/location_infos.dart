import 'dart:ui';

import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
// import 'package:argoscareseniorsafeguard/models/event_list.dart';
import 'package:argoscareseniorsafeguard/models/alarm_infos.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';

class LocationInfo {
  final String? id;
  late String? name;
  final String? userID;
  final String? type;
  final int? displaySunBun;
  final int? requireMotionSensorCount;
  late int? detectedMotionSensorCount;
  final int? requireDoorSensorCount;
  late int? detectedDoorSensorCount;
  final String? createdAt;
  final String? updatedAt;
  final List<SensorInfo>? sensors;
  final List<SensorEvent>? events;
  final List<AlarmInfo>? alarms;

  String? getID() {
    return id;
  }

  String? getName() {
    return name;
  }

  void setName(String value) {
    name = value;
  }

  String? getUserID() {
    return userID;
  }

  String? getType() {
    return type;
  }

  int? getDisplaySunBun() {
    return displaySunBun;
  }

  int? getRequireMotionSensorCount() {
    return requireMotionSensorCount;
  }

  int? getDetectedMotionSensorCount() {
    return detectedMotionSensorCount;
  }

  int? getRequireDoorSensorCount() {
    return requireDoorSensorCount;
  }

  int? getDetectedDoorSensorCount() {
    return detectedDoorSensorCount;
  }

  String? getCreatedAt() {
    return createdAt;
  }

  String? getUpdatedAt() {
    return updatedAt;
  }

  List<SensorInfo>? getSensors() {
    if (sensors == null) {
      return [];
    } else {
      return sensors;
    }
  }

  List<SensorEvent>? getEvents() {
    if (events == null) {
      return [];
    } else {
      return events;
    }

  }

  List<AlarmInfo>? getAlarms() {
    if (alarms == null) {
      return [];
    } else {
      return alarms;
    }
  }

  void setEvents(List<SensorEvent>? value) {
    events = value;
  }

  set events(List<SensorEvent>? value) {
    events = value;
  }

  void setAlarms(List<AlarmInfo>? value) {
    alarms = value;
  }

  set alarms(List<AlarmInfo>? value) {
    alarms = value;
  }

  void setDetectedMotionSensorCount(int value) {
    detectedMotionSensorCount = value;
  }

  void setDetectedDoorSensorCount(int value) {
    detectedDoorSensorCount = value;
  }

  LocationInfo({
    this.id,
    required this.name,
    required this.userID,
    required this.type,
    required this.displaySunBun,
    required this.requireMotionSensorCount,
    required this.detectedMotionSensorCount,
    required this.requireDoorSensorCount,
    required this.detectedDoorSensorCount,
    this.createdAt,
    required this.updatedAt,
    this.sensors,
    this.events,
    this.alarms
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'name': name ?? '',
      'userID': userID ?? '',
      'type': type ?? '',
      'displaySunBun': displaySunBun ?? 0,
      'requireMotionSensorCount': requireMotionSensorCount ?? 0,
      'detectedMotionSensorCount': detectedMotionSensorCount ?? 0,
      'requireDoorSensorCount': requireDoorSensorCount ?? 0,
      'detectedDoorSensorCount': detectedDoorSensorCount ?? 0,
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
      'sensors': sensors ?? [],
      'events': events ?? [],
      'alarms': alarms ?? [],
    };
  }

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      id: json['id'],
      name: json['name'],
      userID: json['userID'],
      type: json['type'],
      displaySunBun: json['displaySunBun'],
      requireMotionSensorCount: json['requireMotionSensorCount'],
      detectedMotionSensorCount: json['detectedMotionSensorCount'],
      requireDoorSensorCount: json['requireDoorSensorCount'],
      detectedDoorSensorCount: json['detectedDoorSensorCount'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      sensors: json['Sensor_Infos'],
      events: json['Events'],
      alarms: json['alarms'],
    );
  }

  @override
  String toString() {
    return 'LocationInfo {'
        'id: $id, '
        'name: $name, '
        'userID: $userID, '
        'type: $type, '
        'displaySunBun: $displaySunBun, '
        'requireMotionSensorCount: $requireMotionSensorCount, '
        'detectedMotionSensorCount: $detectedMotionSensorCount, '
        'requireDoorSensorCount: $requireDoorSensorCount, '
        'detectedDoorSensorCount: $detectedDoorSensorCount, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'sensors: $sensors, '
        'events: $events, '
        'alarms: $alarms, '
      '}';
  }
}
