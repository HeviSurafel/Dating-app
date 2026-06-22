// lib/models/photo_model.dart

class Photo {
  final int id;
  final int userId;
  final String url;
  final bool isMain;
  final int order;
  final DateTime createdAt;

  Photo({
    required this.id,
    required this.userId,
    required this.url,
    this.isMain = false,
    this.order = 0,
    required this.createdAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      url: json['url'] as String? ?? '',
      isMain: _parseBool(json['is_main']),
      order: json['order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'url': url,
      'is_main': isMain ? 1 : 0,
      'order': order,
      'created_at': createdAt.toIso8601String(),
    };
  }
}