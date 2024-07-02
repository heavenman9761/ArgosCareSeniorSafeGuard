class AirplaneTime {
  final String? id;
  final String? startTime;
  final String? endTime;
  final String? createdAt;

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

  AirplaneTime({
    this.id,
    required this.startTime,
    required this.endTime,
    this.createdAt
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'startTime': startTime ?? '',
      'endTime': endTime ?? '',
      'createdAt': createdAt ?? '',
    };
  }

  factory AirplaneTime.fromJson(Map<String, dynamic> json) {
    return AirplaneTime(
      id: json['id'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      createdAt: json['createdAt'],
    );
  }

  @override
  String toString() {
    return 'AirPlaneDay {'
        'id: $id, '
        'startTime: $startTime, '
        'endTime: $endTime, '
        'createdAt: $createdAt, '
    '}';
  }


}