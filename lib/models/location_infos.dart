import 'dart:ui';

class LocationInfo {
  final String? id;
  final String? name;
  final String? userID;
  final String? type;
  final int? requireMotionSensorCount;
  final int? detectedMotionSensorCount;
  final int? requireDoorSensorCount;
  final int? detectedDoorSensorCount;
  final String? createdAt;
  final String? updatedAt;

  String? getID() {
    return id;
  }

  String? getName() {
    return name;
  }

  String? getUserID() {
    return userID;
  }

  String? getType() {
    return type;
  }

  int? getRequireMotionSensorCount() {
    return requireMotionSensorCount;
  }

  int? getDetectedMotionSensorCount() {
    return detectedMotionSensorCount;
  }

  int? getRequireDoorSensorCount() {
    return requireDoorSensorCount;
  }

  int? getDetectedDoorSensorCount() {
    return detectedDoorSensorCount;
  }

  String? getCreatedAt() {
    return createdAt;
  }

  String? getUpdatedAt() {
    return updatedAt;
  }

  LocationInfo({
    this.id,
    required this.name,
    required this.userID,
    required this.type,
    required this.requireMotionSensorCount,
    required this.detectedMotionSensorCount,
    required this.requireDoorSensorCount,
    required this.detectedDoorSensorCount,
    this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'name': name ?? '',
      'userID': userID ?? '',
      'type': type ?? '',
      'requireMotionSensorCount': requireMotionSensorCount ?? 0,
      'detectedMotionSensorCount': detectedMotionSensorCount ?? 0,
      'requireDoorSensorCount': requireDoorSensorCount ?? 0,
      'detectedDoorSensorCount': detectedDoorSensorCount ?? 0,
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
    };
  }

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      id: json['id'],
      name: json['name'],
      userID: json['userID'],
      type: json['type'],
      requireMotionSensorCount: json['requireMotionSensorCount'],
      detectedMotionSensorCount: json['detectedMotionSensorCount'],
      requireDoorSensorCount: json['requireDoorSensorCount'],
      detectedDoorSensorCount: json['detectedDoorSensorCount'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  @override
  String toString() {
    return 'LocationInfo {'
        'id: $id, '
        'name: $name, '
        'userID: $userID, '
        'type: $type, '
        'requireMotionSensorCount: $requireMotionSensorCount, '
        'detectedMotionSensorCount: $detectedMotionSensorCount, '
        'requireDoorSensorCount: $requireDoorSensorCount, '
        'detectedDoorSensorCount: $detectedDoorSensorCount, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
      '}';
  }
}
