// lib/models/user_model.dart
import 'package:dating_app/models/photo_model.dart';
import 'package:dating_app/models/settings_model.dart';
import 'package:dating_app/models/photo_model.dart';
class User {
  final int id;
  final String email;
  final String? phone;
  final String name;
  final String? gender;
  final int? age;
  final String? bio;
  final String? profilePicture;
  final double? latitude;
  final double? longitude;
  final String? lookingFor;
  final String? genderPreference;
  final int? minAgePreference;
  final int? maxAgePreference;
  final int? maxDistanceKm;
  final List<String>? interests;
  final String? occupation;
  final String? education;
  final String? religion;
  final String? smoking;
  final String? drinking;
  final bool hasKids;
  final bool wantsKids;
  final int? heightCm;
  final String? fitnessLevel;
  final String? aboutMe;
  final bool isVerified;
  final bool isPremium;
  final bool isBlocked;
  final DateTime? lastActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Settings? settings;
  final List<Photo>? photos;

  User({
    required this.id,
    required this.email,
    this.phone,
    required this.name,
    this.gender,
    this.age,
    this.bio,
    this.profilePicture,
    this.latitude,
    this.longitude,
    this.lookingFor,
    this.genderPreference,
    this.minAgePreference,
    this.maxAgePreference,
    this.maxDistanceKm,
    this.interests,
    this.occupation,
    this.education,
    this.religion,
    this.smoking,
    this.drinking,
    this.hasKids = false,
    this.wantsKids = false,
    this.heightCm,
    this.fitnessLevel,
    this.aboutMe,
    this.isVerified = false,
    this.isPremium = false,
    this.isBlocked = false,
    this.lastActive,
    required this.createdAt,
    this.updatedAt,
    this.settings,
    this.photos,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      name: json['name'] as String? ?? '',
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      bio: json['bio'] as String?,
      profilePicture: json['profile_picture'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      lookingFor: json['looking_for'] as String?,
      genderPreference: json['gender_preference'] as String?,
      minAgePreference: json['min_age_preference'] as int?,
      maxAgePreference: json['max_age_preference'] as int?,
      maxDistanceKm: json['max_distance_km'] as int?,
      interests: json['interests'] != null
          ? List<String>.from(json['interests'] as List)
          : null,
      occupation: json['occupation'] as String?,
      education: json['education'] as String?,
      religion: json['religion'] as String?,
      smoking: json['smoking'] as String?,
      drinking: json['drinking'] as String?,
      // ✅ Convert int (0/1) to bool
      hasKids: _parseBool(json['has_kids']),
      wantsKids: _parseBool(json['wants_kids']),
      heightCm: json['height_cm'] as int?,
      fitnessLevel: json['fitness_level'] as String?,
      aboutMe: json['about_me'] as String?,
      isVerified: _parseBool(json['is_verified']),
      isPremium: _parseBool(json['is_premium']),
      isBlocked: _parseBool(json['is_blocked']),
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      settings: json['settings'] != null
          ? Settings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      photos: json['photos'] != null
          ? List<Photo>.from((json['photos'] as List).map((p) => Photo.fromJson(p as Map<String, dynamic>)))
          : null,
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'gender': gender,
      'age': age,
      'bio': bio,
      'profile_picture': profilePicture,
      'latitude': latitude,
      'longitude': longitude,
      'looking_for': lookingFor,
      'gender_preference': genderPreference,
      'min_age_preference': minAgePreference,
      'max_age_preference': maxAgePreference,
      'max_distance_km': maxDistanceKm,
      'interests': interests,
      'occupation': occupation,
      'education': education,
      'religion': religion,
      'smoking': smoking,
      'drinking': drinking,
      'has_kids': hasKids ? 1 : 0,
      'wants_kids': wantsKids ? 1 : 0,
      'height_cm': heightCm,
      'fitness_level': fitnessLevel,
      'about_me': aboutMe,
      'is_verified': isVerified ? 1 : 0,
      'is_premium': isPremium ? 1 : 0,
      'is_blocked': isBlocked ? 1 : 0,
      'last_active': lastActive?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  // lib/models/user_model.dart - Add these helper methods at the top

// ✅ Helper function to parse double safely
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

// ✅ Helper function to parse int safely
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return 0;
  }

// ✅ Helper function to parse bool safely
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return false;
  }

// ✅ Helper function to parse DateTime safely
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }
}