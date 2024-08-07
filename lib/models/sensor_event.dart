class SensorEvent {
  final String? id;
  final String? deviceType;
  final String? accountID;
  final String? event;
  final String? state;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? userID;
  final String? sensorID;
  final String? locationID;

  String? getID() {
    return id;
  }

  String? getDeviceType() {
    return deviceType;
  }

  String? getAccountID() {
    return accountID;
  }

  String? getState() {
    return state;
  }

  String? getEvent() {
    return event;
  }

  String? getCreatedAt() {
    return createdAt;
  }

  String? getUpdateAt() {
    return updatedAt;
  }

  String? getDeletedAt() {
    return deletedAt;
  }

  String? getUserID() {
    return userID;
  }

  String? getSensorID() {
    return sensorID;
  }

  String? getLocationID() {
    return locationID;
  }


  SensorEvent({
    this.id,
    required this.deviceType,
    required this.accountID,
    required this.event,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.userID,
    required this.sensorID,
    required this.locationID,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'deviceType': deviceType ?? '',
      'accountID': accountID ?? '',
      'event': event ?? '',
      'state': state ?? '',
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
      'deletedAt': deletedAt ?? '',
      'userID': userID ?? '',
      'sensorID': sensorID ?? '',
      'locationID': locationID ?? '',
    };
  }

  factory SensorEvent.fromJson(Map<String, dynamic> json) {
    return SensorEvent(
      id: json['id'],
      deviceType: json['deviceType'],
      accountID: json['accountID'],
      event: json['event'],
      state: json['state'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deletedAt: json['deletedAt'],
      userID: json['userID'],
      sensorID: json['sensorID'],
      locationID: json['locationID'],
    );
  }

  @override
  String toString() {
    return 'SensorEvent {'
        'id: $id, '
        'deviceType: $deviceType, '
        'accountID: $accountID, '
        'event: $event, '
        'state: $state, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'deletedAt: $deletedAt, '
        'userID: $userID, '
        'sensorID: $sensorID, '
        'locationID: $locationID, '
    '}';
  }
}
