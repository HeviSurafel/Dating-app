// lib/services/swipe_service.dart
import 'package:dio/dio.dart';
import 'package:dating_app/services/api_service.dart';
import 'package:dating_app/config/api_constants.dart';
import 'package:dating_app/models/profile_model.dart';

class SwipeService {
  final ApiService _apiService = ApiService();

  /// Get nearby users for swiping
  Future<Map<String, dynamic>> getNearbyUsers({
    int radius = 50,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.nearbyUsers,
        queryParameters: {
          'radius': radius,
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final usersData = data['users'] as List<dynamic>? ?? [];
          final users = usersData
              .map((e) => Profile.fromJson(e as Map<String, dynamic>))
              .toList();

          return {
            'success': true,
            'users': users,
            'total': data['total'] as int? ?? 0,
            'count': data['count'] as int? ?? 0,
            'radius': data['radius'] as int? ?? radius,
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to get nearby users',
        'users': [],
        'total': 0,
      };
    } on DioException catch (e) {
      print('❌ Error getting nearby users: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
        'users': [],
        'total': 0,
      };
    }
  }
  // lib/services/swipe_service.dart - Add this method

  /// Get swipe statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiService.get(ApiConstants.swipeStats);

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
        'message': response.data?['message'] as String? ?? 'Failed to get stats',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  /// Like a user
  Future<Map<String, dynamic>> like(int userId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.like,
        data: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] as bool? ?? false,
          'isMatch': data['isMatch'] as bool? ?? false,
          'message': data['message'] as String?,
        };
      }

      return {
        'success': false,
        'isMatch': false,
        'message': response.data?['message'] as String? ?? 'Failed to like',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'isMatch': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  /// Pass on a user
  Future<Map<String, dynamic>> pass(int userId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.pass,
        data: {'userId': userId},
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
        'message': response.data?['message'] as String? ?? 'Failed to pass',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  /// Super like a user
  Future<Map<String, dynamic>> superLike(int userId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.superLike,
        data: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] as bool? ?? false,
          'isMatch': data['isMatch'] as bool? ?? false,
          'message': data['message'] as String?,
        };
      }

      return {
        'success': false,
        'isMatch': false,
        'message': response.data?['message'] as String? ?? 'Failed to super like',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'isMatch': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }
}