// lib/models/message_model.dart

class Message {
  final int id;
  final int matchId;
  final int senderId;
  final String content;
  final String messageType;
  final String? mediaUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final String? senderName;
  final String? senderProfilePicture;

  Message({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.mediaUrl,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    this.deletedAt,
    this.senderName,
    this.senderProfilePicture,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      matchId: json['match_id'] as int,
      senderId: json['sender_id'] as int,
      content: json['content'] as String? ?? '',
      messageType: json['message_type'] as String? ?? 'text',
      mediaUrl: json['media_url'] as String?,
      isRead: (json['is_read'] as int? ?? 0) == 1,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      senderName: json['sender_name'] as String?,
      senderProfilePicture: json['sender_profile_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'media_url': mediaUrl,
      'is_read': isRead ? 1 : 0,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  bool get isMine => false; // Set based on current user ID
}