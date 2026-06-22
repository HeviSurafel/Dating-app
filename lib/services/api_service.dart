import 'package:dio/dio.dart';
import 'package:dating_app/config/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _accessToken;
  String? _refreshToken; // This is the FIELD
  bool _isRefreshing = false;
  final List<QueuedRequest> _queue = [];

  Dio get dio => _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.timeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.timeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Skip token refresh for login and register endpoints
          final isAuthEndpoint = error.requestOptions.path == ApiConstants.login ||
              error.requestOptions.path == ApiConstants.register ||
              error.requestOptions.path == ApiConstants.refreshToken;

          if (error.response?.statusCode == 401 && !isAuthEndpoint) {
            // Only try refresh if we have a refresh token
            if (_refreshToken != null) {
              // Store the token before async operations to avoid null issues
              final refreshTokenValue = _refreshToken!;
              await _performRefreshToken(refreshTokenValue);

              // Retry the request if we got a new token
              if (_accessToken != null) {
                final requestOptions = error.requestOptions;
                final newOptions = Options(
                  method: requestOptions.method,
                  headers: {
                    ...requestOptions.headers,
                    'Authorization': 'Bearer $_accessToken',
                  },
                );
                try {
                  final response = await _dio.request(
                    requestOptions.path,
                    data: requestOptions.data,
                    queryParameters: requestOptions.queryParameters,
                    options: newOptions,
                  );
                  return handler.resolve(response);
                } catch (retryError) {
                  return handler.next(retryError as DioException);
                }
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void setRefreshToken(String token) {
    _refreshToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
    _refreshToken = null;
  }

  // ✅ Renamed method to avoid conflict with the field
  Future<void> _performRefreshToken(String refreshToken) async {
    if (_isRefreshing) {
      // Wait for the ongoing refresh
      await Future.delayed(const Duration(milliseconds: 100));
      return;
    }

    _isRefreshing = true;
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final result = data['data'] as Map<String, dynamic>;
          final newAccessToken = result['accessToken'] as String;
          final newRefreshToken = result['refreshToken'] as String;

          _accessToken = newAccessToken;
          _refreshToken = newRefreshToken;

          // Save new tokens
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', newAccessToken);
          await prefs.setString('refreshToken', newRefreshToken);

          // Process queued requests
          for (final request in _queue) {
            request.completer.complete(_performRetryRequest(request.options));
          }
          _queue.clear();
        } else {
          // Refresh failed - logout
          clearAccessToken();
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('accessToken');
          await prefs.remove('refreshToken');

          // Fail all queued requests
          for (final request in _queue) {
            request.completer.completeError('Session expired');
          }
          _queue.clear();
        }
      }
    } catch (e) {
      // Refresh failed - logout
      clearAccessToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');

      // Fail all queued requests
      for (final request in _queue) {
        request.completer.completeError('Session expired');
      }
      _queue.clear();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response> _performRetryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $_accessToken',
      },
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // GET request
  Future<Response> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // Multipart file upload
  Future<Response> upload(
      String endpoint,
      String filePath, {
        Map<String, dynamic>? data,
        void Function(int, int)? onSendProgress,
      }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
        ...?data,
      });

      return await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );
    } on DioException {
      rethrow;
    }
  }
}

// Helper class for request queue
class QueuedRequest {
  final RequestOptions options;
  final Completer<Response> completer;
  QueuedRequest(this.options, this.completer);
}