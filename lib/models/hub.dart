class Hub {
  final String? hubID;
  final String? deviceName;
  final int? displaySunBun;
  final String? state;
  final String? updateTime;
  final String? createTime;

  String? getHubID() {
    return hubID;
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

  Hub({required this.hubID, required this.deviceName, required this.displaySunBun,
    required this.state, required this.updateTime, required this.createTime});

  Map<String, dynamic> toMap() {
    return {
      'hubID': hubID ?? '',
      'deviceName': deviceName ?? '',
      'displaySunBun': displaySunBun ?? 0,
      'state': state ?? '',
      'updateTime': updateTime ?? '',
      'createTime': createTime ?? '',
    };
  }

  factory Hub.fromJson(Map<String, dynamic> json) {
    return Hub(
      hubID: json['hubID'],
      deviceName: json['deviceName'],
      displaySunBun: json['displaySunBun'],
      state: json['state'],
      updateTime: json['updateTime'],
      createTime: json['createTime'],
    );
  }

  @override
  String toString() {
    return 'Hub {hubID: $hubID, deviceName: $deviceName, displaySunBun: $displaySunBun, state: $state, updateTime: $updateTime, createTime: $createTime}';
  }
}
