import 'package:flutter/foundation.dart';

class Location {
  final String? id;
  final String? name;
  final String? createdAt;
  final String? updatedAt;
  final String? sensorID;

  String? getID() {
    return id;
  }

  String? getName() {
    return name;
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

  Location({required this.id, required this.name, this.sensorID,
    required this.createdAt, required this.updatedAt
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'name': name ?? 0,
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
      'sensorID': sensorID ?? '',
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
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
        'sensorID: $sensorID, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
      '}';
  }
}
