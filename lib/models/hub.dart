import 'package:flutter/foundation.dart';

class Hub {
  final String? id;
  final String? hubID;
  final String? name;
  final int? displaySunBun;
  final String? category;
  final String? deviceType;
  final String? locationID;
  final String? locationName;
  final bool? hasSubDevices;
  final String? modelName;
  final bool? online;
  final String? status;
  final int? battery;
  final bool? isUse;
  final String? createdAt;
  final String? updatedAt;

  String? getID() {
    return id;
  }

  String? getHubID() {
    return hubID;
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

  String? getLocationID() {
    return locationID;
  }

  String? getLocationName() {
    return locationName;
  }

  bool? getHasSubDevices() {
    return hasSubDevices;
  }

  String? getModelName() {
    return modelName;
  }

  bool? getOnLine() {
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

  String? getCreatedAt() {
    return createdAt;
  }

  String? getUpdatedAt() {
    return updatedAt;
  }



  Hub({required this.id, required this.hubID, required this.name,
    required this.displaySunBun, required this.category, required this.deviceType,
    required this.locationID, required this.locationName, required this.hasSubDevices,
    required this.modelName, required this.online, required this.status,
    required this.battery, required this.isUse,
    required this.createdAt, required this.updatedAt
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'hubID': hubID ?? '',
      'name': name ?? 0,
      'displaySunBun': displaySunBun ?? '',
      'category': category ?? '',
      'deviceType': deviceType ?? '',
      'locationID': locationID ?? '',
      'locationName': locationName ?? '',
      'hasSubDevices': hasSubDevices ?? '',
      'modelName': modelName ?? '',
      'online': online ?? '',
      'status': status ?? '',
      'battery': battery ?? '',
      'isUse': isUse ?? '',
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
    };
  }

  factory Hub.fromJson(Map<String, dynamic> json) {
    return Hub(
      id: json['id'],
      hubID: json['hubID'],
      name: json['name'],
      displaySunBun: json['displaySunBun'],
      category: json['category'],
      deviceType: json['deviceType'],
      locationID: json['locationID'],
      locationName: json['locationName'],
      hasSubDevices: json['hasSubDevices'],
      modelName: json['modelName'],
      online: json['online'],
      status: json['status'],
      battery: json['battery'],
      isUse: json['isUse'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  @override
  String toString() {
    return 'Hub {'
        'id: $id, '
        'hubID: $hubID, '
        'name: $name, '
        'displaySunBun: $displaySunBun, '
        'category: $category, '
        'deviceType: $deviceType'
        'locationID: $locationID'
        'locationName: $locationName'
        'hasSubDevices: $hasSubDevices'
        'modelName: $modelName'
        'online: $online'
        'status: $status'
        'battery: $battery'
        'isUse: $isUse'
        'createdAt: $createdAt'
        'updatedAt: $updatedAt'
      '}';
  }
}
