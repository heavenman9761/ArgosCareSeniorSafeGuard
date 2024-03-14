import 'dart:ffi';

class SensorEvent {
  final int? id;
  final String? hubID;
  final String? deviceID;
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

  String? getDeviceID() {
    return deviceID;
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

  SensorEvent({this.id, required this.deviceID, required this.hubID, required this.deviceType,
    required this.event, required this.state, required this.updateTime, required this.createTime});

  Map<String, dynamic> toMap() {
    return {
      // 'id': id ?? 0,  => Autoincrement 일때는 있으면 안된다.
      'deviceID': deviceID ?? '',
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
      deviceID: json['deviceID'],
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
    return 'SensorEvent {id: $id, sensorID: $deviceID, hubID: $hubID, deviceType: $deviceType, event: $event, state: $state, updateTime: $updateTime, createTime: $createTime}';
  }
}
