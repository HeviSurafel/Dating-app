class AppConfig {
  static const String appName = 'Dating App';
  static const String appVersion = '1.0.0';
  static const String defaultLanguage = 'en';

  // Features flags
  static const bool enablePushNotifications = true;
  static const bool enableLocationServices = true;
  static const bool enableVideoCalls = false; // For future
  static const bool enableVoiceCalls = false; // For future

  // Limits
  static const int maxPhotos = 6;
  static const int maxBioLength = 500;
  static const int maxMessageLength = 1000;
  static const int defaultSwipeLimit = 50;

  // Timeouts
  static const int otpExpirySeconds = 600; // 10 minutes
  static const int sessionTimeoutMinutes = 30;
}