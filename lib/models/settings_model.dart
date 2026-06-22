// lib/models/settings_model.dart

class Settings {
  final int userId;
  final bool showAge;
  final bool showDistance;
  final bool showOnlineStatus;
  final bool receivePushNotifications;
  final bool receiveMatchEmails;
  final bool receiveMarketingEmails;
  final String language;
  final String theme;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Settings({
    required this.userId,
    this.showAge = true,
    this.showDistance = true,
    this.showOnlineStatus = true,
    this.receivePushNotifications = true,
    this.receiveMatchEmails = true,
    this.receiveMarketingEmails = false,
    this.language = 'en',
    this.theme = 'system',
    required this.createdAt,
    this.updatedAt,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      userId: json['user_id'] as int? ?? 0,
      showAge: _parseBool(json['show_age']),
      showDistance: _parseBool(json['show_distance']),
      showOnlineStatus: _parseBool(json['show_online_status']),
      receivePushNotifications: _parseBool(json['receive_push_notifications']),
      receiveMatchEmails: _parseBool(json['receive_match_emails']),
      receiveMarketingEmails: _parseBool(json['receive_marketing_emails']),
      language: json['language'] as String? ?? 'en',
      theme: json['theme'] as String? ?? 'system',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
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
      'user_id': userId,
      'show_age': showAge ? 1 : 0,
      'show_distance': showDistance ? 1 : 0,
      'show_online_status': showOnlineStatus ? 1 : 0,
      'receive_push_notifications': receivePushNotifications ? 1 : 0,
      'receive_match_emails': receiveMatchEmails ? 1 : 0,
      'receive_marketing_emails': receiveMarketingEmails ? 1 : 0,
      'language': language,
      'theme': theme,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}