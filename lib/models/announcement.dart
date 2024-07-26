class AnnouncementInfo {
  final String? id;
  final String? title;
  final String? content;
  final String? writer;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  String? getID() {
    return id;
  }

  String? getTitle() {
    return title;
  }

  String? getContent() {
    return content;
  }

  String? getWriter() {
    return writer;
  }

  String? getCreatedAt() {
    return createdAt;
  }

  String? getUpdatedAt() {
    return updatedAt;
  }

  String? getDeletedAt() {
    return deletedAt;
  }

  AnnouncementInfo({
    required this.id,
    required this.title,
    required this.content,
    required this.writer,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'title': title ?? '',
      'content': content ?? '',
      'writer': writer ?? '',
      'createdAt': createdAt ?? '',
      'updatedAt': updatedAt ?? '',
      'deletedAt': deletedAt ?? '',
    };
  }

  factory AnnouncementInfo.fromJson(Map<String, dynamic> json) {
    return AnnouncementInfo(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      writer: json['writer'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deletedAt: json['deletedAt'],
    );
  }

  @override
  String toString() {
    return 'AnnouncementInfo {'
        'id: $id, '
        'title: $title, '
        'content: $content, '
        'writer: $writer, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'deletedAt: $deletedAt, '
        'deletedAt: $deletedAt, '
    '}';
  }
}