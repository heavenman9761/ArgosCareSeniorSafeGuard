class AirplaneTime {
  final String? id;
  final String? startTime;
  final String? endTime;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? userID;

  String? getID() {
    return id;
  }

  String? getStartTime() {
    return startTime;
  }

  String? getEndTime() {
    return endTime;
  }

  String? getCreatedAt() {
    return createdAt;
  }

  String? getUpdatedAt() {
    return createdAt;
  }

  String? getDeletedAt() {
    return deletedAt;
  }

  String? getUserID() {
    return userID;
  }

  AirplaneTime({
    this.id,
    required this.startTime,
    required this.endTime,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.userID
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'startTime': startTime ?? '',
      'endTime': endTime ?? '',
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
      'deletedAt': deletedAt ?? '',
      'userID': userID ?? '',
    };
  }

  factory AirplaneTime.fromJson(Map<String, dynamic> json) {
    return AirplaneTime(
      id: json['id'],
      startTime: json['startTime'],
      endTime: json['endTime'],
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
        'startTime: $startTime, '
        'endTime: $endTime, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'deletedAt: $deletedAt, '
        'userID: $userID, '
    '}';
  }


}