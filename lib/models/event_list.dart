class EventList {
  final String? hubID;
  final String? deviceID;
  final String? deviceType;
  final String? event;
  final String? status;
  final String? createdAt;
  final String? name;

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

  String? getCreatedAt() {
    return createdAt;
  }

  String? getName() {
    return name;
  }

  EventList({required this.hubID, required this.deviceID, required this.deviceType,
    required this.event, required this.status, required this.createdAt, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'deviceID': deviceID ?? '',
      'hubID': hubID ?? '',
      'deviceType': deviceType ?? '',
      'event': event ?? '',
      'status': status ?? '',
      'createdAt': createdAt ?? '',
      'name': name ?? ''
    };
  }

  factory EventList.fromJson(Map<String, dynamic> json) {
    return EventList(
      hubID: json['hubID'],
      deviceID: json['deviceID'],
      deviceType: json['deviceType'],
      event: json['event'],
      status: json['status'],
      createdAt: json['createdAt'],
      name: json['name'],
    );
  }

  @override
  String toString() {
    return 'EventList {'
        'hubID: $hubID, '
        'sensorID: $deviceID, '
        'deviceType: $deviceType, '
        'event: $event, '
        'status: $status, '
        'createdAt: $createdAt, '
        'name: $name '
    '}';
  }
}
