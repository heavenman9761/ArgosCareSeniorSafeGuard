import 'package:flutter/foundation.dart';

class Location {
  final String? id;
  final String? name;
  final String? userID;
  final int? shared;
  final String? ownerID;
  final String? ownerName;
  final String? createdAt;
  final String? updatedAt;
  final String? sensorID;

  String? getID() {
    return id;
  }

  String? getName() {
    return name;
  }

  String? getUserID() {
    return userID;
  }

  int? getShared() {
    return shared;
  }

  String? getOwnerID() {
    return ownerID;
  }

  String? getOwnerName() {
    return ownerName;
  }

  String? getCreatedTime() {
    return createdAt;
  }

  String? getUpdatedAt() {
    return updatedAt;
  }

  String? getSensorID() {
    return sensorID;
  }

  Location({
    required this.id,
    required this.name,
    required this.userID,
    required this.shared,
    required this.ownerID,
    required this.ownerName,
    this.sensorID,
    required this.createdAt,
    required this.updatedAt
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'name': name ?? '',
      'userID': userID ?? '',
      'shared': shared ?? 0,
      'ownerID': ownerID ?? '',
      'ownerName': ownerName ?? '',
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
      'sensorID': sensorID ?? '',
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      userID: json['userID'],
      shared: json['shared'],
      ownerID: json['ownerID'],
      ownerName: json['ownerName'],
      sensorID: json['sensorID'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  @override
  String toString() {
    return 'Location {'
        'id: $id, '
        'name: $name, '
        'userID: $userID, '
        'shared: $shared, '
        'ownerID: $ownerID, '
        'ownerName: $ownerName, '
        'sensorID: $sensorID, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
      '}';
  }
}
