// lib/providers/swipe_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dating_app/services/swipe_service.dart';
import 'package:dating_app/models/profile_model.dart';

final swipeProvider = StateNotifierProvider<SwipeNotifier, SwipeState>((ref) {
  return SwipeNotifier();
});

class SwipeState {
  final List<Profile> profiles;
  final bool isLoading;
  final bool isRefreshing;
  final bool isMatch;
  final int? matchId;
  final String? error;
  final Map<String, dynamic>? stats;
  final bool hasMore;
  final int currentPage;
  final int totalCount;

  SwipeState({
    this.profiles = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.isMatch = false,
    this.matchId,
    this.error,
    this.stats,
    this.hasMore = true,
    this.currentPage = 1,
    this.totalCount = 0,
  });

  SwipeState copyWith({
    List<Profile>? profiles,
    bool? isLoading,
    bool? isRefreshing,
    bool? isMatch,
    int? matchId,
    String? error,
    Map<String, dynamic>? stats,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
  }) {
    return SwipeState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isMatch: isMatch ?? this.isMatch,
      matchId: matchId ?? this.matchId,
      error: error ?? this.error,
      stats: stats ?? this.stats,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class SwipeNotifier extends StateNotifier<SwipeState> {
  final SwipeService _swipeService = SwipeService();
  bool _isLoadingMore = false;
  int _page = 1;
  static const int _pageSize = 20;

  SwipeNotifier() : super(SwipeState());

  Future<void> loadProfiles({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      state = state.copyWith(isRefreshing: true, error: null);
    } else if (state.profiles.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _swipeService.getNearbyUsers(
        radius: 50, // Default 50km radius
        limit: _pageSize,
        offset: (_page - 1) * _pageSize,
      );

      if (result['success'] == true) {
        final newProfiles = result['users'] as List<Profile>? ?? [];
        final total = result['total'] as int? ?? 0;

        print('✅ Loaded ${newProfiles.length} profiles, total: $total');

        if (refresh) {
          state = state.copyWith(
            profiles: newProfiles,
            isLoading: false,
            isRefreshing: false,
            error: null,
            currentPage: 1,
            totalCount: total,
            hasMore: newProfiles.length < total,
          );
        } else {
          // Prevent duplicates
          final existingIds = state.profiles.map((p) => p.userId).toSet();
          final uniqueNewProfiles = newProfiles.where((p) => !existingIds.contains(p.userId)).toList();

          state = state.copyWith(
            profiles: [...state.profiles, ...uniqueNewProfiles],
            isLoading: false,
            isRefreshing: false,
            error: null,
            currentPage: state.currentPage + 1,
            hasMore: state.profiles.length + uniqueNewProfiles.length < total,
            totalCount: total,
          );
        }

        if (newProfiles.isNotEmpty) {
          _page++;
        }
      } else {
        final message = result['message'] as String? ?? 'Failed to load profiles';
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: message,
        );
      }
    } catch (e) {
      print('❌ Profiles load error: $e');
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: 'Unable to load profiles. Please check your connection.',
      );
    }
  }

  Future<void> refreshProfiles() async {
    await loadProfiles(refresh: true);
  }

  Future<void> loadMoreProfiles() async {
    if (_isLoadingMore || !state.hasMore || state.isLoading || state.isRefreshing) {
      return;
    }

    _isLoadingMore = true;
    await loadProfiles(refresh: false);
    _isLoadingMore = false;
  }

  Future<bool> like(int userId) async {
    try {
      final result = await _swipeService.like(userId);

      if (result['success'] == true) {
        state = state.copyWith(
          isMatch: result['isMatch'] ?? false,
          matchId: result['matchId'],
        );
        // Remove the profile from list
        final updatedProfiles = List<Profile>.from(state.profiles)
          ..removeWhere((p) => p.userId == userId);
        state = state.copyWith(profiles: updatedProfiles);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Like error: $e');
      return false;
    }
  }

  Future<bool> pass(int userId) async {
    try {
      final result = await _swipeService.pass(userId);

      if (result['success'] == true) {
        // Remove the profile from list
        final updatedProfiles = List<Profile>.from(state.profiles)
          ..removeWhere((p) => p.userId == userId);
        state = state.copyWith(profiles: updatedProfiles);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Pass error: $e');
      return false;
    }
  }

  Future<bool> superLike(int userId) async {
    try {
      final result = await _swipeService.superLike(userId);

      if (result['success'] == true) {
        state = state.copyWith(
          isMatch: result['isMatch'] ?? false,
          matchId: result['matchId'],
        );
        final updatedProfiles = List<Profile>.from(state.profiles)
          ..removeWhere((p) => p.userId == userId);
        state = state.copyWith(profiles: updatedProfiles);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Super Like error: $e');
      return false;
    }
  }

  Future<void> loadStats() async {
    try {
      final result = await _swipeService.getStats();

      if (result['success'] == true) {
        state = state.copyWith(stats: result['data']);
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  void resetMatch() {
    state = state.copyWith(isMatch: false, matchId: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Get current profile being viewed
  Profile? getCurrentProfile() {
    if (state.profiles.isEmpty) return null;
    return state.profiles.first;
  }

  // Check if there are more profiles to load
  bool get hasMoreProfiles => state.hasMore;

  // Get remaining profiles count
  int get remainingProfiles => state.profiles.length;
}