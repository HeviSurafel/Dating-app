// lib/services/match_service.dart - Full updated file

import 'package:dio/dio.dart';
import 'package:dating_app/services/api_service.dart';
import 'package:dating_app/config/api_constants.dart';
import 'package:dating_app/models/match_model.dart';
import 'package:dating_app/models/message_model.dart';
import 'package:dating_app/models/user_model.dart';

class MatchService {
  final ApiService _apiService = ApiService();

  /// Get all matches for the current user
// In lib/services/match_service.dart - Add this debug

  Future<Map<String, dynamic>> getMatches() async {
    try {
      print('🔍 Fetching matches from: ${ApiConstants.matches}');
      final response = await _apiService.get(ApiConstants.matches);
      print('📦 Response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print('📦 Parsed data: $data');

        if (data['success'] == true) {
          final matchesData = data['matches'] ?? data['data'] ?? [];
          print('📦 Matches data length: ${matchesData.length}');

          final matches = (matchesData as List<dynamic>?)
              ?.map((e) {
            print('📦 Processing match: $e');
            return Match.fromJson(e as Map<String, dynamic>);
          })
              .toList() ??
              [];

          print('✅ Loaded ${matches.length} matches');
          return {
            'success': true,
            'data': matches,
            'total': data['total'] as int? ?? matches.length,
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to get matches',
      };
    } on DioException catch (e) {
      print('❌ Error getting matches: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }
  /// Get match details including messages and matched user info
  Future<Map<String, dynamic>> getMatchDetails(int matchId) async {
    try {
      final response = await _apiService.get(ApiConstants.matchDetails(matchId));

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final matchData = data['data'] as Map<String, dynamic>? ?? {};

          return {
            'success': true,
            'data': {
              'match': matchData['match'] != null
                  ? Match.fromJson(matchData['match'] as Map<String, dynamic>)
                  : null,
              'matchedUser': matchData['matchedUser'] as Map<String, dynamic>?,
              'messages': (matchData['messages'] as List<dynamic>?)
                  ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
                  .toList() ??
                  [],
              'unreadCount': matchData['unreadCount'] as int? ?? 0,
            },
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to get match details',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  /// Send a message to a match
  Future<Map<String, dynamic>> sendMessage(
      int matchId,
      String content, {
        String messageType = 'text',
        String? mediaUrl,
      }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.sendMessage(matchId),
        data: {
          'content': content,
          'messageType': messageType,
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] as String?,
            'data': data['data'] != null
                ? Message.fromJson(data['data'] as Map<String, dynamic>)
                : null,
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to send message',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  /// Get messages for a match with pagination
  Future<Map<String, dynamic>> getMessages(
      int matchId, {
        int limit = 50,
        int offset = 0,
      }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.matchMessages(matchId),
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final messagesData = data['data'] ?? data['messages'] ?? [];
          final messages = (messagesData as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
              [];
          return {
            'success': true,
            'data': messages,
            'total': data['total'] as int? ?? messages.length,
            'limit': limit,
            'offset': offset,
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to get messages',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  /// Delete a message (soft delete)
  Future<Map<String, dynamic>> deleteMessage(int messageId) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.deleteMessage(messageId),
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
        'message': response.data?['message'] as String? ?? 'Failed to delete message',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  /// Block a match
  Future<Map<String, dynamic>> blockMatch(int matchId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.blockMatch(matchId),
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
        'message': response.data?['message'] as String? ?? 'Failed to block match',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  /// Unmatch/delete a match
  Future<Map<String, dynamic>> unmatch(int matchId) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.unmatch(matchId),
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
        'message': response.data?['message'] as String? ?? 'Failed to unmatch',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  /// Get unread message count for all matches
  Future<Map<String, dynamic>> getUnreadCounts() async {
    try {
      final response = await _apiService.get(ApiConstants.unreadCount);

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
        'message': response.data?['message'] as String? ?? 'Failed to get unread counts',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  /// Mark messages as read for a match
  Future<Map<String, dynamic>> markMessagesAsRead(int matchId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.markMessagesAsRead(matchId),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] as bool? ?? false,
          'message': data['message'] as String?,
          'count': data['count'] as int? ?? 0,
        };
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to mark messages as read',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  /// Check if two users are matched
  Future<Map<String, dynamic>> checkMatch(int user1Id, int user2Id) async {
    try {
      final response = await _apiService.get(
        ApiConstants.matchByUsers,
        queryParameters: {
          'user1Id': user1Id,
          'user2Id': user2Id,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] as bool? ?? false,
          'isMatched': data['isMatched'] as bool? ?? false,
          'data': data['data'] as Map<String, dynamic>?,
        };
      }

      return {
        'success': false,
        'isMatched': false,
        'message': response.data?['message'] as String? ?? 'Failed to check match',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'isMatched': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }
}