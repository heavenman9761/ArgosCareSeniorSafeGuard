import 'package:flutter/foundation.dart';

class Room {
  final String? id;
  final String? name;
  final String? userID;
  final int? shared;
  final String? ownerID;
  final String? ownerName;
  final String? createdAt;
  final String? updatedAt;
  final String? locationID;

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

  String? getCreatedAt() {
    return createdAt;
  }

  String? getUpdatedAt() {
    return updatedAt;
  }

  String? getLocationID() {
    return locationID;
  }

  Room({
    required this.id,
    required this.name,
    required this.userID,
    required this.shared,
    required this.ownerID,
    required this.ownerName,
    this.locationID,
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
      'locationID': locationID ?? '',
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      userID: json['userID'],
      shared: json['shared'],
      ownerID: json['ownerID'],
      ownerName: json['ownerName'],
      locationID: json['locationID'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  @override
  String toString() {
    return 'Room {'
        'id: $id, '
        'name: $name, '
        'userID: $userID, '
        'shared: $shared, '
        'ownerID: $ownerID, '
        'ownerName: $ownerName, '
        'locationID: $locationID, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
      '}';
  }
}
