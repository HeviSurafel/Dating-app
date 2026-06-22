// lib/models/profile_model.dart
import 'package:dating_app/models/user_model.dart';

class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}

class Profile {
  final int userId;
  final User? user;
  final String? name;
  final int? age;
  final String? gender;
  final String? bio;
  final String? profilePicture;
  final Location? location;
  final List<String>? photos;
  final List<String>? interests;
  final String? lookingFor;
  final String? genderPreference;
  final int? minAgePreference;
  final int? maxAgePreference;
  final int? maxDistanceKm;
  final int? heightCm;
  final String? fitnessLevel;
  final String? occupation;
  final String? education;
  final String? religion;
  final String? smoking;
  final String? drinking;
  final bool hasKids;
  final bool wantsKids;
  final bool isVerified;
  final bool isPremium;
  final DateTime? lastActive;
  final double? distance;

  Profile({
    required this.userId,
    this.user,
    this.name,
    this.age,
    this.gender,
    this.bio,
    this.profilePicture,
    this.location,
    this.photos,
    this.interests,
    this.lookingFor,
    this.genderPreference,
    this.minAgePreference,
    this.maxAgePreference,
    this.maxDistanceKm,
    this.heightCm,
    this.fitnessLevel,
    this.occupation,
    this.education,
    this.religion,
    this.smoking,
    this.drinking,
    this.hasKids = false,
    this.wantsKids = false,
    this.isVerified = false,
    this.isPremium = false,
    this.lastActive,
    this.distance,
  });

  // ✅ Helper function to parse double safely from any type
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  // ✅ Helper function to parse int safely from any type
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

  factory Profile.fromJson(Map<String, dynamic> json) {
    // Handle both formats: direct user data or nested user object
    final hasUserData = json['name'] != null || json['email'] != null;

    // Parse distance safely
    double? distance;
    if (json['distance'] != null) {
      distance = _parseDouble(json['distance']);
    }

    if (hasUserData) {
      // Direct user data from nearby users endpoint
      return Profile(
        userId: _parseInt(json['id']),
        name: json['name'] as String?,
        age: json['age'] != null ? _parseInt(json['age']) : null,
        gender: json['gender'] as String?,
        bio: json['bio'] as String?,
        profilePicture: json['profile_picture'] as String?,
        location: json['latitude'] != null && json['longitude'] != null
            ? Location(
          latitude: _parseDouble(json['latitude']),
          longitude: _parseDouble(json['longitude']),
        )
            : null,
        photos: json['photos'] != null
            ? List<String>.from(json['photos'] as List)
            : [],
        isVerified: _parseBool(json['is_verified']),
        isPremium: _parseBool(json['is_premium']),
        lastActive: _parseDateTime(json['last_active']),
        distance: distance,
        lookingFor: json['looking_for'] as String?,
        genderPreference: json['gender_preference'] as String?,
        minAgePreference: json['min_age_preference'] != null ? _parseInt(json['min_age_preference']) : null,
        maxAgePreference: json['max_age_preference'] != null ? _parseInt(json['max_age_preference']) : null,
        maxDistanceKm: json['max_distance_km'] != null ? _parseInt(json['max_distance_km']) : null,
        heightCm: json['height_cm'] != null ? _parseInt(json['height_cm']) : null,
        fitnessLevel: json['fitness_level'] as String?,
        occupation: json['occupation'] as String?,
        education: json['education'] as String?,
        religion: json['religion'] as String?,
        smoking: json['smoking'] as String?,
        drinking: json['drinking'] as String?,
        hasKids: _parseBool(json['has_kids']),
        wantsKids: _parseBool(json['wants_kids']),
        user: User(
          id: _parseInt(json['id']),
          email: json['email'] as String? ?? '',
          phone: json['phone'] as String?,
          name: json['name'] as String? ?? 'Unknown',
          gender: json['gender'] as String?,
          age: json['age'] != null ? _parseInt(json['age']) : null,
          bio: json['bio'] as String?,
          profilePicture: json['profile_picture'] as String?,
          latitude: json['latitude'] != null ? _parseDouble(json['latitude']) : null,
          longitude: json['longitude'] != null ? _parseDouble(json['longitude']) : null,
          isVerified: _parseBool(json['is_verified']),
          isPremium: _parseBool(json['is_premium']),
          isBlocked: _parseBool(json['is_blocked']),
          lastActive: _parseDateTime(json['last_active']),
          createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
          updatedAt: _parseDateTime(json['updated_at']),
          genderPreference: json['gender_preference'] as String?,
          lookingFor: json['looking_for'] as String?,
          minAgePreference: json['min_age_preference'] != null ? _parseInt(json['min_age_preference']) : null,
          maxAgePreference: json['max_age_preference'] != null ? _parseInt(json['max_age_preference']) : null,
          maxDistanceKm: json['max_distance_km'] != null ? _parseInt(json['max_distance_km']) : null,
          interests: json['interests'] != null
              ? List<String>.from(json['interests'] as List)
              : null,
          occupation: json['occupation'] as String?,
          education: json['education'] as String?,
          religion: json['religion'] as String?,
          smoking: json['smoking'] as String?,
          drinking: json['drinking'] as String?,
          hasKids: _parseBool(json['has_kids']),
          wantsKids: _parseBool(json['wants_kids']),
          heightCm: json['height_cm'] != null ? _parseInt(json['height_cm']) : null,
          fitnessLevel: json['fitness_level'] as String?,
          aboutMe: json['about_me'] as String?,
          settings: null,
          photos: null,
        ),
      );
    } else {
      // Nested user data from profile endpoint
      final userData = json['user'] as Map<String, dynamic>?;
      return Profile(
        userId: _parseInt(json['user_id']),
        user: userData != null ? User.fromJson(userData) : null,
        bio: json['bio'] as String?,
        location: json['latitude'] != null && json['longitude'] != null
            ? Location(
          latitude: _parseDouble(json['latitude']),
          longitude: _parseDouble(json['longitude']),
        )
            : null,
        photos: json['photos'] != null
            ? List<String>.from(json['photos'] as List)
            : null,
        interests: json['interests'] != null
            ? List<String>.from(json['interests'] as List)
            : null,
        lookingFor: json['looking_for'] as String?,
        genderPreference: json['gender_preference'] as String?,
        minAgePreference: json['min_age_preference'] != null ? _parseInt(json['min_age_preference']) : null,
        maxAgePreference: json['max_age_preference'] != null ? _parseInt(json['max_age_preference']) : null,
        maxDistanceKm: json['max_distance_km'] != null ? _parseInt(json['max_distance_km']) : null,
        heightCm: json['height_cm'] != null ? _parseInt(json['height_cm']) : null,
        fitnessLevel: json['fitness_level'] as String?,
        occupation: json['occupation'] as String?,
        education: json['education'] as String?,
        religion: json['religion'] as String?,
        smoking: json['smoking'] as String?,
        drinking: json['drinking'] as String?,
        hasKids: _parseBool(json['has_kids']),
        wantsKids: _parseBool(json['wants_kids']),
        isVerified: _parseBool(json['is_verified']),
        isPremium: _parseBool(json['is_premium']),
        lastActive: _parseDateTime(json['last_active']),
        distance: distance,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'bio': bio,
      'latitude': location?.latitude,
      'longitude': location?.longitude,
      'photos': photos,
      'interests': interests,
      'looking_for': lookingFor,
      'gender_preference': genderPreference,
      'min_age_preference': minAgePreference,
      'max_age_preference': maxAgePreference,
      'max_distance_km': maxDistanceKm,
      'height_cm': heightCm,
      'fitness_level': fitnessLevel,
      'occupation': occupation,
      'education': education,
      'religion': religion,
      'smoking': smoking,
      'drinking': drinking,
      'has_kids': hasKids ? 1 : 0,
      'wants_kids': wantsKids ? 1 : 0,
    };
  }

  String get displayName => user?.name ?? name ?? 'Unknown';
  int get displayAge => user?.age ?? age ?? 0;
  String get displayGender => user?.gender ?? gender ?? 'Not specified';
  String get displayBio => user?.bio ?? bio ?? 'No bio yet';
  bool get isUserVerified => user?.isVerified ?? isVerified;
  bool get isUserPremium => user?.isPremium ?? isPremium;
  String? get mainPhoto => user?.profilePicture ?? profilePicture;

  String get distanceDisplay {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }
}