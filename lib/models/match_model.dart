// lib/models/match_model.dart
import 'package:dating_app/models/message_model.dart';

class Match {
  final int id;
  final int user1Id;
  final int user2Id;
  final String status;
  final int? blockedBy;
  final DateTime? lastMessageAt;
  final bool isMuted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserMatch? matchedUser;
  final Message? lastMessage;
  final int unreadCount;

  Match({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.status,
    this.blockedBy,
    this.lastMessageAt,
    this.isMuted = false,
    required this.createdAt,
    this.updatedAt,
    this.matchedUser,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    // ✅ The backend returns user data directly in the match object
    // The user fields are the matched user's data
    // We need to determine which user is the match based on the current user

    // For now, we'll create a UserMatch from the response
    final matchedUser = UserMatch.fromJson(json);

    return Match(
      id: json['id'] as int? ?? 0,
      // These fields might not exist in the response, use 0 as default
      user1Id: json['user1_id'] as int? ?? 0,
      user2Id: json['user2_id'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      blockedBy: json['blocked_by'] as int?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      isMuted: (json['is_muted'] as int? ?? 0) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      matchedUser: matchedUser,
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'status': status,
      'blocked_by': blockedBy,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'is_muted': isMuted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class UserMatch {
  final int id;
  final String name;
  final String? email;
  final int? age;
  final String? gender;
  final String? bio;
  final String? profilePicture;
  final double? latitude;
  final double? longitude;
  final bool isOnline;
  final bool isVerified;
  final bool isBlocked;
  final DateTime? lastActive;
  final bool likedByMe;
  final bool likedMe;

  UserMatch({
    required this.id,
    required this.name,
    this.email,
    this.age,
    this.gender,
    this.bio,
    this.profilePicture,
    this.latitude,
    this.longitude,
    this.isOnline = false,
    this.isVerified = false,
    this.isBlocked = false,
    this.lastActive,
    this.likedByMe = false,
    this.likedMe = false,
  });

  factory UserMatch.fromJson(Map<String, dynamic> json) {
    // ✅ Parse the user data from the response
    return UserMatch(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      profilePicture: json['profile_picture'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      isOnline: json['last_active'] != null
          ? DateTime.parse(json['last_active'] as String)
          .difference(DateTime.now())
          .inMinutes < 5
          : false,
      isVerified: json['is_verified'] == 1,
      isBlocked: json['is_blocked'] == 1,
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'] as String)
          : null,
      likedByMe: json['liked_by_me'] == 1,
      likedMe: json['liked_me'] == 1,
    );
  }
}