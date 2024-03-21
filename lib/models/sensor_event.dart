class SensorEvent {
  final int? id;
  final String? hubID;
  final String? deviceID;
  final String? deviceType;
  final String? event;
  final String? status;
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

  String? getStatus() {
    return status;
  }

  String? getUpdateTime() {
    return updateTime;
  }

  String? getCreateTime() {
    return createTime;
  }

  SensorEvent({this.id, required this.deviceID, required this.hubID, required this.deviceType,
    required this.event, required this.status, required this.updateTime, required this.createTime});

  Map<String, dynamic> toMap() {
    return {
      // 'id': id ?? 0,  => Autoincrement 일때는 있으면 안된다.
      'deviceID': deviceID ?? '',
      'hubID': hubID ?? '',
      'deviceType': deviceType ?? '',
      'event': event ?? '',
      'status': status ?? '',
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
      status: json['status'],
      updateTime: json['updateTime'],
      createTime: json['createTime'],
    );
  }

  @override
  String toString() {
    return 'SensorEvent {'
        'id: $id, '
        'sensorID: $deviceID, '
        'hubID: $hubID, '
        'deviceType: $deviceType, '
        'event: $event, '
        'status: $status, '
        'updateTime: $updateTime, '
        'createTime: $createTime'
    '}';
  }
}
