import 'dart:ui';

class SensorInfo {
  final String? id;
  final String? sensorID;
  final String? name;
  final String? userID;
  final int? displaySunBun;
  final String? category;
  final String? deviceType;
  final String? modelName;
  final bool? online;
  final String? status;
  final int? battery;
  final bool? isUse;
  final bool? shared;
  final String? ownerID;
  final String? ownerName;
  final String? createdAt;
  final String? updatedAt;
  final String? hubID;
  final String? locationID;

  String? getID() {
    return id;
  }

  String? getSensorID() {
    return sensorID;
  }

  String? getName() {
    return name;
  }

  String? getUserID() {
    return userID;
  }

  int? getDisplaySunBun() {
    return displaySunBun;
  }

  String? getCategory() {
    return category;
  }

  String? getDeviceType() {
    return deviceType;
  }

  String? getModelName() {
    return modelName;
  }

  bool? getOnline() {
    return online;
  }

  String? getStatus() {
    return status;
  }

  int? getBattery() {
    return battery;
  }

  bool? getIsUse() {
    return isUse;
  }

  bool? getShared() {
    return shared;
  }

  String? getOwnerID() {
    return ownerID;
  }

  String? getOwnerName() {
    return ownerName;
  }

  String? getCreatedAt() {
    return createdAt;
  }

  String? getUpdatedAt() {
    return updatedAt;
  }

  String? getHubID() {
    return hubID;
  }

  String? getLocationID() {
    return locationID;
  }

  SensorInfo({
    required this.id,
    required this.sensorID,
    required this.name,
    required this.userID,
    required this.displaySunBun,
    required this.category,
    required this.deviceType,
    required this.modelName,
    required this.online,
    required this.status,
    required this.battery,
    required this.isUse,
    required this.shared,
    required this.ownerID,
    required this.ownerName,
    required this.createdAt,
    required this.updatedAt,
    required this.hubID,
    required this.locationID,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'sensorID': sensorID ?? '',
      'name': name ?? '',
      'userID': userID ?? '',
      'displaySunBun': displaySunBun ?? 0,
      'category': category ?? '',
      'deviceType': deviceType ?? '',
      'modelName': modelName ?? '',
      'online': online,
      'status': status ?? '',
      'battery': battery ?? 0,
      'isUse': isUse,
      'shared': shared,
      'ownerID': ownerID ?? '',
      'ownerName': ownerName ?? '',
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
      'hubID': hubID ?? '',
      'locationID': locationID ?? '',

    };
  }

  factory SensorInfo.fromJson(Map<String, dynamic> json) {
    return SensorInfo(
      id: json['id'],
      sensorID: json['sensorID'],
      name: json['name'],
      userID: json['userID'],
      displaySunBun: json['displaySunBun'],
      category: json['category'],
      deviceType: json['deviceType'],
      modelName: json['modelName'],
      online: json['online'],
      status: json['status'],
      battery: json['battery'],
      isUse: json['isUse'],
      shared: json['shared'],
      ownerID: json['ownerID'],
      ownerName: json['ownerName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      hubID: json['hubID'],
      locationID: json['locationID'],
    );
  }

  @override
  String toString() {
    return 'SensorInfo {'
        'id: $id, '
        'sensorID: $sensorID, '
        'name: $name, '
        'userID: $userID, '
        'displaySunBun: $displaySunBun, '
        'category: $category, '
        'deviceType: $deviceType, '
        'modelName: $modelName, '
        'online: $online, '
        'status: $status, '
        'battery: $battery, '
        'isUse: $isUse, '
        'status: $status, '
        'shared: $shared, '
        'ownerID: $ownerID, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'hubID: $hubID, '
        'locationID: $locationID, '
        '}';
  }
}
