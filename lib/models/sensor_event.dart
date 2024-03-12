import 'dart:ffi';

class SensorEvent {
  final int? id;
  final String? hubID;
  final String? sensorID;
  final String? deviceType;
  final String? event;
  final String? state;
  final String? updateTime;
  final String? createTime;

  int? getID() {
    return id;
  }

  String? getHubID() {
    return hubID;
  }

  String? getSensorID() {
    return sensorID;
  }

  String? getDeviceType() {
    return deviceType;
  }

  String? getEvent() {
    return event;
  }

  String? getState() {
    return state;
  }

  String? getUpdateTime() {
    return updateTime;
  }

  String? getCreateTime() {
    return createTime;
  }

  SensorEvent({required this.id, required this.sensorID, required this.hubID, required this.deviceType,
    required this.event, required this.state, required this.updateTime, required this.createTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? 0,
      'sensorID': sensorID ?? '',
      'hubID': hubID ?? '',
      'deviceType': deviceType ?? '',
      'event': event ?? '',
      'state': state ?? '',
      'updateTime': updateTime ?? '',
      'createTime': createTime ?? '',
    };
  }

  factory SensorEvent.fromJson(Map<String, dynamic> json) {
    return SensorEvent(
      id: json['id'],
      sensorID: json['sensorID'],
      hubID: json['hubID'],
      deviceType: json['deviceType'],
      event: json['event'],
      state: json['state'],
      updateTime: json['updateTime'],
      createTime: json['createTime'],
    );
  }

  @override
  String toString() {
    return 'SensorEvent {id: $id, sensorID: $sensorID, hubID: $hubID, deviceType: $deviceType, event: $event, state: $state, updateTime: $updateTime, createTime: $createTime}';
  }
}
