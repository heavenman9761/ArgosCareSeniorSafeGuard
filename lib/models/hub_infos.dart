import 'package:flutter/foundation.dart';

class HubInfo {
  final String? id;
  final String? hubID;
  final String? name;
  final String? userID;
  final int? displaySunBun;
  final String? category;
  final String? deviceType;
  final bool? hasSubDevices;
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

  String? getID() {
    return id;
  }

  String? getHubID() {
    return hubID;
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

  HubInfo({
    this.id,
    this.hubID,
    required this.name,
    required this.userID,
    required this.displaySunBun,
    required this.category,
    required this.deviceType,
    required this.hasSubDevices,
    required this.modelName,
    required this.online,
    required this.status,
    required this.battery,
    required this.isUse,
    required this.shared,
    required this.ownerID,
    required this.ownerName,
    required this.createdAt,
    required this.updatedAt
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'hubID': hubID ?? '',
      'name': name ?? '',
      'userID': userID ?? '',
      'displaySunBun': displaySunBun ?? 0,
      'category': category ?? '',
      'deviceType': deviceType ?? '',
      'hasSubDevices': hasSubDevices,
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
    };
  }

  factory HubInfo.fromJson(Map<String, dynamic> json) {
    return HubInfo(
      id: json['id'],
      hubID: json['hubID'],
      name: json['name'],
      userID: json['userID'],
      displaySunBun: json['displaySunBun'],
      category: json['category'],
      deviceType: json['deviceType'],
      hasSubDevices: json['hasSubDevices'],
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
    );
  }

  @override
  String toString() {
    return 'HubInfo {'
      'id: $id, '
      'hubID: $hubID, '
      'name: $name, '
      'userID: $userID, '
      'displaySunBun: $displaySunBun, '
      'category: $category, '
      'deviceType: $deviceType, '
      'hasSubDevices: $hasSubDevices, '
      'modelName: $modelName, '
      'online: $online, '
      'status: $status, '
      'battery: $battery, '
      'isUse: $isUse, '
      'shared: $shared, '
      'ownerID: $ownerID, '
      'ownerName: $ownerName, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
    '}';
  }
}
