import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dating_app/services/api_service.dart';
import 'package:dating_app/config/api_constants.dart';
import 'package:dating_app/models/profile_model.dart';

import '../models/user_model.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getProfile() async {
    try {
      print('🔍 Fetching profile...');
      final response = await _apiService.get(ApiConstants.userProfile);

      print('📦 Response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final userData = data['data'] as Map<String, dynamic>;

          // ✅ Parse as User, not Profile
          final user = User.fromJson(userData);

          // Also convert to Profile if needed
          final profile = Profile(
            userId: user.id,
            user: user,
            bio: user.bio,
            location: user.latitude != null && user.longitude != null
                ? Location(
              latitude: user.latitude!,
              longitude: user.longitude!,
            )
                : null,
            photos: user.photos?.map((p) => p.url).toList() ?? [],
            interests: user.interests ?? [],
            lookingFor: user.lookingFor,
            genderPreference: user.genderPreference,
            minAgePreference: user.minAgePreference,
            maxAgePreference: user.maxAgePreference,
            maxDistanceKm: user.maxDistanceKm,
            heightCm: user.heightCm,
            fitnessLevel: user.fitnessLevel,
            occupation: user.occupation,
            education: user.education,
            religion: user.religion,
            smoking: user.smoking,
            drinking: user.drinking,
            hasKids: user.hasKids,
            wantsKids: user.wantsKids,
          );

          return {
            'success': true,
            'data': profile,
            'user': user,
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to get profile',
      };
    } on DioException catch (e) {
      print('❌ Error fetching profile: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.put(
        ApiConstants.updateProfile,
        data: profileData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] as bool? ?? false,
          'message': data['message'] as String?,
        };
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to update profile',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.put(
        ApiConstants.updateProfile,
        data: userData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] as bool? ?? false,
          'message': data['message'] as String?,
        };
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to update user',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  Future<Map<String, dynamic>> updateLocation(double latitude, double longitude) async {
    try {
      final response = await _apiService.put(
        ApiConstants.updateLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] as bool? ?? false,
          'message': data['message'] as String?,
        };
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to update location',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  Future<Map<String, dynamic>> getNearbyUsers({
    int limit = 20,
    int maxDistance = 50,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.nearbyUsers,
        queryParameters: {
          'limit': limit,
          'maxDistance': maxDistance,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final users = (data['data'] as List<dynamic>?)
              ?.map((e) => Profile.fromJson(e as Map<String, dynamic>))
              .toList() ?? [];
          return {
            'success': true,
            'data': users,
            'count': data['count'] as int? ?? 0,
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to get nearby users',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  Future<Map<String, dynamic>> getUserById(int userId) async {
    try {
      final response = await _apiService.get('${ApiConstants.userById}/$userId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return {
            'success': true,
            'data': Profile.fromJson(data['data'] as Map<String, dynamic>),
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'User not found',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _apiService.get(ApiConstants.settings);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'] as Map<String, dynamic>? ?? {},
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to get settings',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> settings) async {
    try {
      final response = await _apiService.put(
        ApiConstants.settings,
        data: settings,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] as bool? ?? false,
          'message': data['message'] as String?,
        };
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to update settings',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _apiService.delete(ApiConstants.userProfile);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] as bool? ?? false,
          'message': data['message'] as String?,
        };
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to delete account',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  Future<Map<String, dynamic>> uploadPhoto(String filePath) async {
    try {
      final response = await _apiService.upload(
        ApiConstants.uploadPhoto,
        filePath,
        onSendProgress: (sent, total) {
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] as bool? ?? false,
          'message': data['message'] as String?,
          'data': data['data'] as Map<String, dynamic>?,
        };
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to upload photo',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  Future<Map<String, dynamic>> deletePhoto(int photoId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.deletePhoto}/$photoId',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] as bool? ?? false,
          'message': data['message'] as String?,
        };
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to delete photo',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }
}