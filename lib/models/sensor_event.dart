class SensorEvent {
  final String? id;
  final String? hubID;
  final String? deviceID;
  final String? deviceType;
  final String? event;
  final String? status;
  final String? updatedAt;
  final String? createdAt;

  String? getID() {
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

  String? getUpdateAt() {
    return updatedAt;
  }

  String? getCreatedAt() {
    return createdAt;
  }

  SensorEvent({this.id, required this.deviceID, required this.hubID, required this.deviceType,
    required this.event, required this.status, required this.updatedAt, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'deviceID': deviceID ?? '',
      'hubID': hubID ?? '',
      'deviceType': deviceType ?? '',
      'event': event ?? '',
      'status': status ?? '',
      'updatedAt': updatedAt ?? '',
      'createdAt': createdAt ?? '',
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
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
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
        'updatedAt: $updatedAt, '
        'createdAt: $createdAt'
    '}';
  }
}
