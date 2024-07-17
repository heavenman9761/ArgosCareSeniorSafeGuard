class AirplaneDay {
  final String? id;
  final String? dayName;
  bool? enable;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? userID;

  String? getID() {
    return id;
  }

  String? getDayName() {
    return dayName;
  }

  bool? getEnable() {
    return enable;
  }

  String? getCreated() {
    return createdAt;
  }

  String? getUpdated() {
    return updatedAt;
  }

  String? getDeleted() {
    return deletedAt;
  }

  String? getUserID() {
    return userID;
  }

  void setEnable(value) {
    enable = value;
  }

  AirplaneDay({
    required this.id,
    required this.dayName,
    required this.enable,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.userID
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'dayName': dayName ?? '',
      'enable': enable ?? false,
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
      'deletedAt': deletedAt ?? '',
      'userID': userID ?? '',
    };
  }

  factory AirplaneDay.fromJson(Map<String, dynamic> json) {
    return AirplaneDay(
      id: json['id'],
      dayName: json['dayName'],
      enable: json['enable'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deletedAt: json['deletedAt'] ?? '',
      userID: json['userID'],
    );
  }

  @override
  String toString() {
    return 'AirPlaneDay {'
        'id: $id, '
        'dayName: $dayName, '
        'enable: $enable, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'deletedAt: $deletedAt, '
        'userID: $userID, '
    '}';
  }
}