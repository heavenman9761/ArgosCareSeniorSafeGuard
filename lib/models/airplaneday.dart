class AirplaneDay {
  final String? id;
  final String? dayName;
  int? enable;

  String? getID() {
    return id;
  }

  String? getDayName() {
    return dayName;
  }

  int? getEnable() {
    return enable;
  }

  void setEnable(value) {
    enable = value;
  }

  AirplaneDay({
    required this.id,
    required this.dayName,
    required this.enable
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'dayName': dayName ?? '',
      'enable': enable ?? 0
    };
  }

  factory AirplaneDay.fromJson(Map<String, dynamic> json) {
    return AirplaneDay(
      id: json['id'],
      dayName: json['dayName'],
      enable: json['enable'],
    );
  }

  @override
  String toString() {
    return 'AirPlaneDay {'
        'id: $id, '
        'dayName: $dayName, '
        'enable: $enable, '
    '}';
  }
}