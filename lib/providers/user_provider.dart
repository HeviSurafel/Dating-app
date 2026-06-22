// lib/providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/models/profile_model.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

class UserState {
  final Profile? profile;
  final bool isLoading;
  final String? error;

  UserState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    Profile? profile,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final UserService _userService = UserService();

  UserNotifier() : super(UserState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _userService.getProfile();

      if (result['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          profile: result['data'] as Profile?,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] as String? ?? 'Failed to load profile',
        );
      }
    } catch (e) {
      print('❌ Error in loadProfile: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred. Please try again.',
      );
    }
  }

// ... rest of the code remains the same
}