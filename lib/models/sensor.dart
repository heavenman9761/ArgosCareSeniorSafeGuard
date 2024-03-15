class Sensor {
  final String? sensorID;
  final String? hubID;
  final String? deviceType;
  final String? deviceName;
  final int? displaySunBun;
  final String? state;
  final String? updateTime;
  final String? createTime;

  String? getSensorID() {
    return sensorID;
  }

  String? getHubID() {
    return hubID;
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

  String? getState() {
    return state;
  }

  String? getUpdateTime() {
    return updateTime;
  }

  String? getCreateTime() {
    return createTime;
  }

  Sensor({required this.sensorID, required this.hubID, required this.deviceType, required this.deviceName, required this.displaySunBun,
    required this.state, required this.updateTime, required this.createTime});

  Map<String, dynamic> toMap() {
    return {
      'sensorID': sensorID ?? '',
      'hubID': hubID ?? '',
      'deviceType': deviceType ?? '',
      'deviceName': deviceName ?? '',
      'displaySunBun': displaySunBun ?? '',
      'state': state ?? '',
      'updateTime': updateTime ?? '',
      'createTime': createTime ?? '',
    };
  }

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      sensorID: json['sensorID'],
      hubID: json['hubID'],
      deviceType: json['deviceType'],
      deviceName: json['deviceName'],
      displaySunBun: json['displaySunBun'],
      state: json['state'],
      updateTime: json['updateTime'],
      createTime: json['createTime'],
    );
  }

  @override
  String toString() {
    return 'Sensor {sensorID: $sensorID, deviceType: $deviceType, deviceName: $deviceName, displaySunBun: $displaySunBun, state: $state, updateTime: $updateTime, createTime: $createTime}';
  }
}
