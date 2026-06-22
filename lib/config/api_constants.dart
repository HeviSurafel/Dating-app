// lib/config/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'http://192.168.8.142:5000/api';
  static const int timeout = 30000;

  // Auth endpoints
  static const String register = '/auth/register';
  static const String verifyOTP = '/auth/verify-otp';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String resendOTP = '/auth/resend-otp';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String userProfile = '/users/me';
  static const String updateProfile = '/users/me';
  static const String updateLocation = '/users/me/location';
  static const String nearbyUsers = '/users/me/nearby'; // ✅ Correct endpoint
  static const String recommendations = '/users/recommendations';
  static const String userById = '/users';
  static const String settings = '/users/me/settings';

  // Swipe endpoints
  static const String like = '/swipes/like';
  static const String pass = '/swipes/pass';
  static const String superLike = '/swipes/super-like';
  static const String swipeStats = '/swipes/stats';
  static const String swipeHistory = '/swipes/history';

  // Match endpoints
  static const String matches = '/matches';
  static String matchDetails(int matchId) => '/matches/$matchId';
  static String matchMessages(int matchId) => '/matches/$matchId/messages';
  static String sendMessage(int matchId) => '/matches/$matchId/messages';
  static String deleteMessage(int messageId) => '/messages/$messageId';
  static String blockMatch(int matchId) => '/matches/$matchId/block';
  static String unmatch(int matchId) => '/matches/$matchId';
  static const String matchByUsers = '/matches/by-users';
  static String markMessagesAsRead(int matchId) => '/matches/$matchId/messages/read';
  static const String unreadCount = '/matches/unread-count';

  // Upload endpoints
  static const String uploadPhoto = '/uploads/photos';
  static const String deletePhoto = '/uploads/photos';
  static const String setMainPhoto = '/uploads/photos/main';
  static const String getPhotos = '/uploads/photos';

  // Notification endpoints
  static const String notifications = '/notifications';
  static const String unreadNotifications = '/notifications/unread';
  static const String markRead = '/notifications';
  static const String markAllRead = '/notifications/read-all';
}