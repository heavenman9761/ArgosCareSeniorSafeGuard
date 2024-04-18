import 'package:flutter/foundation.dart';

class Room {
  final String? id;
  final String? name;
  final String? userID;
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

  String? getCreatedAt() {
    return createdAt;
  }

  String? getUpdatedAt() {
    return updatedAt;
  }

  String? getLocationID() {
    return locationID;
  }

  Room({required this.id, required this.name, required this.userID, this.locationID,
    required this.createdAt, required this.updatedAt
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'name': name ?? '',
      'userID': userID ?? '',
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
        'locationID: $locationID, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
      '}';
  }
}
