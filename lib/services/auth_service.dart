import 'package:dio/dio.dart';
import 'package:dating_app/services/api_service.dart';
import 'package:dating_app/config/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ✅ Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ✅ Use the same ApiService instance
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String gender,
    required String dateOfBirth,
    String? phone,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'email': email,
        'password': password,
        'name': name,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'phone': phone,
      };

      // Add location if available
      if (latitude != null) {
        data['latitude'] = latitude;
      }
      if (longitude != null) {
        data['longitude'] = longitude;
      }

      final response = await _apiService.post(
        ApiConstants.register,
        data: data,
      );

      if (response.statusCode == 201) {
        final result = response.data as Map<String, dynamic>;
        if (result['success'] == true) {
          final responseData = result['data'] as Map<String, dynamic>;

          if (responseData.containsKey('accessToken')) {
            await _saveTokens(
              responseData['accessToken'] as String,
              responseData['refreshToken'] as String,
            );
            _apiService.setAccessToken(responseData['accessToken'] as String);
            _apiService.setRefreshToken(responseData['refreshToken'] as String);
          }

          return {
            'success': true,
            'message': result['message'] as String? ?? 'Registration successful',
            'data': responseData,
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Registration failed',
      };
    } on DioException catch (e) {
      print('❌ Register error: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  Future<Map<String, dynamic>> verifyOTP({
    String? email,
    String? phone,
    required String otp,
    required String purpose,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.verifyOTP,
        data: {
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          'otp': otp,
          'purpose': purpose,
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
        'message': response.data?['message'] as String? ?? 'OTP verification failed',
      };
    } on DioException catch (e) {
      print('❌ Verify OTP error: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  Future<Map<String, dynamic>> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login to: ${ApiConstants.baseUrl}${ApiConstants.login}');
      print('📧 Email: $email');

      final response = await _apiService.post(
        ApiConstants.login,
        data: {
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          'password': password,
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final result = data['data'] as Map<String, dynamic>;

          if (result.containsKey('accessToken')) {
            final accessToken = result['accessToken'] as String;
            final refreshToken = result['refreshToken'] as String;

            await _saveTokens(accessToken, refreshToken);
            _apiService.setAccessToken(accessToken);
            _apiService.setRefreshToken(refreshToken);
          }

          return {
            'success': true,
            'message': data['message'] as String? ?? 'Login successful',
            'data': result,
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Login failed',
      };
    } on DioException catch (e) {
      print('❌ Login error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      print('❌ Status: ${e.response?.statusCode}');
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    _apiService.clearAccessToken();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<Map<String, dynamic>> resendOTP({
    String? email,
    String? phone,
    required String purpose,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.resendOTP,
        data: {
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          'purpose': purpose,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': data['success'] as bool? ?? false,
          'message': data['message'] as String? ?? 'OTP sent successfully',
          'otp': data['otp'], // For development
        };
      }

      return {
        'success': false,
        'message': response.data?['message'] as String? ?? 'Failed to resend OTP',
      };
    } on DioException catch (e) {
      print('❌ Resend OTP error: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data?['message'] as String? ?? e.message,
      };
    }
  }

  // Load saved tokens on app start
  Future<void> loadSavedTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    if (accessToken != null && accessToken.isNotEmpty) {
      _apiService.setAccessToken(accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        _apiService.setRefreshToken(refreshToken);
      }
    }
  }
}