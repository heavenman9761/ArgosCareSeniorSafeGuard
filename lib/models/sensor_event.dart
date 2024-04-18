class SensorEvent {
  final String? id;
  final String? hubID;
  final String? userID;
  final String? deviceID;
  final String? deviceType;
  final String? event;
  final String? status;
  final int? humi;
  final double? temp;
  final String? updatedAt;
  final String? createdAt;

  String? getID() {
    return id;
  }

  String? getHubID() {
    return hubID;
  }

  String? getUserID() {
    return userID;
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

  int? getHumi() {
    return humi;
  }

  double? getTemp() {
    return temp;
  }

  String? getUpdateAt() {
    return updatedAt;
  }

  String? getCreatedAt() {
    return createdAt;
  }

  SensorEvent({this.id, required this.deviceID, required this.hubID, required this.userID, required this.deviceType,
    required this.event, required this.status, required this.humi, required this.temp, required this.updatedAt, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'deviceID': deviceID ?? '',
      'hubID': hubID ?? '',
      'userID': userID ?? '',
      'deviceType': deviceType ?? '',
      'event': event ?? '',
      'status': status ?? '',
      'humi': humi ?? 0,
      'temp': temp ?? 0.0,
      'updatedAt': updatedAt ?? '',
      'createdAt': createdAt ?? '',
    };
  }

  factory SensorEvent.fromJson(Map<String, dynamic> json) {
    return SensorEvent(
      id: json['id'],
      deviceID: json['deviceID'],
      hubID: json['hubID'],
      userID: json['userID'],
      deviceType: json['deviceType'],
      event: json['event'],
      status: json['status'],
      humi: json['humi'],
      temp: json['temp'],
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
        'userID: $userID, '
        'deviceType: $deviceType, '
        'event: $event, '
        'status: $status, '
        'humi: $humi, '
        'temp: $temp, '
        'updatedAt: $updatedAt, '
        'createdAt: $createdAt'
    '}';
  }
}
