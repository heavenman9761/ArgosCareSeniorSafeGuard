class ShareInfo {
  final String? id;
  final String? shareKey;
  final String? ownerID;
  final String? ownerMail;
  final String? ownerName;
  final String? protectPeople;
  final bool? state;
  final String? createdAt;
  final String? updatedAt;

  String? getID() {
    return id;
  }

  String? getShareKey() {
    return shareKey;
  }

  String? getOwnerID() {
    return ownerID;
  }

  String? getOwnerMail() {
    return ownerMail;
  }

  String? getOwnerName() {
    return ownerName;
  }

  String? getProtectPeople() {
    return protectPeople;
  }

  bool? getState() {
    return state;
  }

  String? getCreatedAt() {
    return createdAt;
  }

  String? getUpdatedAt() {
    return updatedAt;
  }

  ShareInfo({
    required this.id,
    required this.shareKey,
    required this.ownerID,
    required this.ownerMail,
    required this.ownerName,
    required this.protectPeople,
    required this.state,
    required this.createdAt,
    required this.updatedAt
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'shareKey': shareKey ?? '',
      'ownerID': ownerID ?? '',
      'ownerMail': ownerMail ?? '',
      'ownerName': ownerName ?? '',
      'protectPeople': protectPeople ?? '',
      'state': state ?? false,
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
    };
  }

  factory ShareInfo.fromJson(Map<String, dynamic> json) {
    return ShareInfo(
      id: json['id'],
      shareKey: json['shareKey'],
      ownerID: json['ownerID'],
      ownerMail: json['ownerMail'],
      ownerName: json['ownerName'],
      protectPeople: json['protectPeople'],
      state: json['state'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  @override
  String toString() {
    return 'ShareInfo {'
        'id: $id, '
        'shareKey: $shareKey, '
        'ownerID: $ownerID, '
        'ownerMail: $ownerMail, '
        'ownerName: $ownerName, '
        'protectPeople: $protectPeople, '
        'state: $state, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
      '}';
  }

}