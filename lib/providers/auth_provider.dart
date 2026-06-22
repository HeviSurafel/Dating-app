// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dating_app/services/auth_service.dart';
import '../models/user_model.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;
  final String? accessToken;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.accessToken,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
    String? accessToken,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      // You can fetch user profile here if needed
      final token = await _authService.getAccessToken();
      state = state.copyWith(
        isAuthenticated: true,
        accessToken: token,
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String gender,
    required DateTime dateOfBirth,
    String? phone,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        name: name,
        gender: gender,
        dateOfBirth: dateOfBirth.toIso8601String().split('T')[0],
        phone: phone,
        latitude: latitude,
        longitude: longitude,
      );

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          accessToken: data['accessToken'] as String?,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] as String? ?? 'Registration failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred. Please try again.',
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          accessToken: data['accessToken'] as String?,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] as String? ?? 'Login failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred. Please try again.',
      );
    }
  }

  Future<void> verifyOTP({
    String? email,
    String? phone,
    required String otp,
    required String purpose,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.verifyOTP(
        email: email,
        phone: phone,
        otp: otp,
        purpose: purpose,
      );

      if (result['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] as String? ?? 'OTP verification failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});