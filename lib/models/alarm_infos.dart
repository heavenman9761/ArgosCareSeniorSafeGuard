class AlarmInfo {
  final String? id;
  final String? alarm;
  final int? jaeSilStatus;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? userID;
  final String? locationID;

  String? getID() {
    return id;
  }

  String? getAlarm() {
    return alarm;
  }

  int? getJaeSilStatus() {
    return jaeSilStatus;
  }

  String? getCreatedAt() {
    return createdAt;
  }

  String? getUpdatedAt() {
    return updatedAt;
  }

  String? getDeletedAt() {
    return deletedAt;
  }

  String? getUserID() {
    return userID;
  }

  String? getLocationID() {
    return locationID;
  }

  AlarmInfo({
    required this.id,
    required this.alarm,
    required this.jaeSilStatus,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userID,
    required this.locationID,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'alarm': alarm ?? '',
      'jaeSilStatus': jaeSilStatus ?? 0,
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
      'deletedAt': deletedAt ?? '',
      'userID': userID ?? '',
      'locationID': locationID ?? '',
    };
  }

  factory AlarmInfo.fromJson(Map<String, dynamic> json) {
    return AlarmInfo(
      id: json['id'],
      alarm: json['alarm'],
      jaeSilStatus: json['jaeSilStatus'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deletedAt: json['deletedAt'],
      userID: json['userID'],
      locationID: json['locationID'],
    );
  }

  @override
  String toString() {
    return 'AlarmInfo {'
        'id: $id, '
        'alarm: $alarm, '
        'jaeSilStatus: $jaeSilStatus, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'deletedAt: $deletedAt, '
        'deletedAt: $deletedAt, '
        'userID: $userID, '
        'locationID: $locationID, '
      '}';
  }
}