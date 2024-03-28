import 'dart:ui';

class Sensor {
  final String? id;
  final String? sensorID;
  final String? name;
  final int? displaySunBun;
  final String? category;
  final String? deviceType;
  final String? modelName;
  final int? online;
  final String? status;
  final int? battery;
  final int? isUse;
  final String? createdAt;
  final String? updatedAt;
  final String? hubID;

  String? getID() {
    return id;
  }

  String? getSensorID() {
    return sensorID;
  }

  String? getName() {
    return name;
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

  int? getOnline() {
    return online;
  }

  String? getStatus() {
    return status;
  }

  int? getBattery() {
    return getBattery();
  }

  int? getIsUse() {
    return isUse;
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

  Sensor({
    this.id, required this.sensorID, required this.name,
    required this.displaySunBun, required this.category, required this.deviceType,
    required this.modelName,
    required this.online, required this.status, required this.battery,
    required this.isUse, this.createdAt, required this.updatedAt,
    required this.hubID
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'sensorID': sensorID ?? '',
      'name': name ?? '',
      'displaySunBun': displaySunBun ?? '',
      'category': category ?? '',
      'deviceType': deviceType ?? '',
      'modelName': modelName ?? '',
      'online': online ?? '',
      'status': status ?? '',
      'battery': battery ?? '',
      'isUse': isUse ?? '',
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
      'hubID': hubID ?? '',

    };
  }

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'],
      sensorID: json['sensorID'],
      name: json['name'],
      displaySunBun: json['displaySunBun'],
      category: json['category'],
      deviceType: json['deviceType'],
      modelName: json['modelName'],
      online: json['online'],
      status: json['status'],
      battery: json['battery'],
      isUse: json['isUse'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      hubID: json['hubID'],
    );
  }

  @override
  String toString() {
    return 'Sensor {'
        'id: $id, '
        'sensorID: $sensorID, '
        'name: $name, '
        'displaySunBun: $displaySunBun, '
        'category: $category, '
        'deviceType: $deviceType, '
        'modelName: $modelName, '
        'online: $online, '
        'status: $status, '
        'battery: $battery, '
        'isUse: $isUse, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'hubID: $hubID, '
    '}';
  }
}
