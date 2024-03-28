class Device {
  final String? deviceID;
  final String? deviceType;
  final String? deviceName;
  final int? displaySunBun;
  final String? accountID;
  final String? status;
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

  String? getAccountID() {
    return accountID;
  }

  String? getStatus() {
    return status;
  }

  String? getUpdatedAt() {
    return updatedAt;
  }

  String? getCreateAt() {
    return createdAt;
  }

  Device({required this.deviceID, required this.deviceType, required this.deviceName, required this.displaySunBun, required this.accountID,
    required this.status, required this.updatedAt, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'deviceID': deviceID,
      'deviceType': deviceType,
      'deviceName': deviceName,
      'displaySunBun': displaySunBun ?? '',
      'accountID': accountID,
      'status': status ?? '',
      'updatedAt' : updatedAt,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'Device {'
        'deviceID: $deviceID, '
        'deviceType: $deviceType, '
        'deviceName: $deviceName, '
        'displaySunBun: $displaySunBun, '
        'accountID: $accountID, '
        'status: $status, '
        'updatedAt: $updatedAt, '
        'createdAt: $createdAt, '
      '}';
  }
}
