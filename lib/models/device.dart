class Device {
  final String? deviceID;
  final String? deviceType;
  final String? deviceName;
  final int? displaySunBun;
  final String? userID;
  final String? status;
  final int? shared;
  final String? ownerID;
  final String? ownerName;
  final String? updatedAt;
  final String? createdAt;

  String? getDeviceID() {
    return deviceID;
  }

  String? getDeviceType() {
    return deviceType;
  }

  String? getDeviceName() {
    return deviceName;
  }

  int? getDisplaySunBun() {
    return displaySunBun;
  }

  String? getUserID() {
    return userID;
  }

  String? getStatus() {
    return status;
  }

  int? getShared() {
    return shared;
  }

  String? getOwnerID() {
    return ownerID;
  }

  String? getOwnerName() {
    return ownerName;
  }

  String? getUpdatedAt() {
    return updatedAt;
  }

  String? getCreateAt() {
    return createdAt;
  }

  Device({required this.deviceID,
    required this.deviceType,
    required this.deviceName,
    required this.displaySunBun,
    required this.userID,
    required this.status,
    required this.shared,
    required this.ownerID,
    required this.ownerName,
    required this.updatedAt,
    required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'deviceID': deviceID ?? '',
      'deviceType': deviceType ?? '',
      'deviceName': deviceName ?? '',
      'displaySunBun': displaySunBun ?? 0,
      'userID': userID ?? '',
      'status': status ?? '',
      'shared': shared ?? 0,
      'ownerID': ownerID ?? '',
      'ownerName': ownerName ?? '',
      'updatedAt' : updatedAt ?? '',
      'createdAt': createdAt ?? '',
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceID: json['deviceID'],
      deviceType: json['deviceType'],
      deviceName: json['deviceName'],
      displaySunBun: json['displaySunBun'],
      userID: json['userID'],
      status: json['status'],
      shared: json['shared'],
      ownerID: json['ownerID'],
      ownerName: json['ownerName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  @override
  String toString() {
    return 'Device {'
        'deviceID: $deviceID, '
        'deviceType: $deviceType, '
        'deviceName: $deviceName, '
        'displaySunBun: $displaySunBun, '
        'userID: $userID, '
        'status: $status, '
        'shared: $shared, '
        'ownerID: $ownerID, '
        'ownerName: $ownerName, '
        'updatedAt: $updatedAt, '
        'createdAt: $createdAt, '
      '}';
  }
}
