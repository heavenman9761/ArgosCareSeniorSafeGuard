class RequestShareInfo {
  final String? id;
  final String? name;
  final String? createdAt;

  String? getID() {
    return id;
  }

  String? getName() {
    return name;
  }

  String? getCreatedAt() {
    return createdAt;
  }

  RequestShareInfo({
    required this.id,
    required this.name,
    required this.createdAt
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'name': name ?? '',
      'createdAt': createdAt ?? '',
    };
  }

  factory RequestShareInfo.fromJson(Map<String, dynamic> json) {
    return RequestShareInfo(
      id: json['id'],
      name: json['name'],
      createdAt: json['createdAt'],
    );
  }

  @override
  String toString() {
    return 'RequestShareInfo {'
      'id: $id, '
      'name: $name, '
      'createdAt: $createdAt, '
    '}';
  }
}