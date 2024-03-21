class Device {
  late final String deviceID;
  final String deviceType;
  final String deviceName;
  final int? displaySunBun;
  final String accountID;
  final String status;
  final String updateTime;
  final String createTime;

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

  String? getUpdateTime() {
    return updateTime;
  }

  String? getCreateTime() {
    return createTime;
  }

  Device({required this.deviceID, required this.deviceType, required this.deviceName, required this.displaySunBun, required this.accountID,
    required this.status, required this.updateTime, required this.createTime});

  Map<String, dynamic> toMap() {
    return {
      'deviceID': deviceID,
      'deviceType': deviceType,
      'deviceName': deviceName,
      'displaySunBun': displaySunBun ?? '',
      'accountID': accountID,
      'status': status ?? '',
      'updateTime' : updateTime,
      'createTime': createTime,
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
        'updateTime: $updateTime, '
        'createTime: $createTime, '
      '}';
  }
}
