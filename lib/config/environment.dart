// lib/config/environment.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  // App Config
  static String get appName => dotenv.env['APP_NAME'] ?? 'Dating App';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get env => dotenv.env['ENV'] ?? 'development';

  // API Config
  static String get apiUrl => dotenv.env['API_URL'] ?? 'http://localhost:5000/api';
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  // Firebase
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAuthDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  // Feature Flags
  static bool get enablePushNotifications =>
      dotenv.env['ENABLE_PUSH_NOTIFICATIONS']?.toLowerCase() == 'true';
  static bool get enableLocationServices =>
      dotenv.env['ENABLE_LOCATION_SERVICES']?.toLowerCase() == 'true';
  static bool get enableVideoCalls =>
      dotenv.env['ENABLE_VIDEO_CALLS']?.toLowerCase() == 'true';

  // Limits
  static int get maxPhotos => int.tryParse(dotenv.env['MAX_PHOTOS'] ?? '6') ?? 6;
  static int get defaultSwipeLimit =>
      int.tryParse(dotenv.env['DEFAULT_SWIPE_LIMIT'] ?? '50') ?? 50;
  static int get otpExpirySeconds =>
      int.tryParse(dotenv.env['OTP_EXPIRY_SECONDS'] ?? '600') ?? 600;

  // Email
  static String get emailHost => dotenv.env['EMAIL_HOST'] ?? '';
  static int get emailPort => int.tryParse(dotenv.env['EMAIL_PORT'] ?? '587') ?? 587;
  static String get emailUser => dotenv.env['EMAIL_USER'] ?? '';
  static String get emailPass => dotenv.env['EMAIL_PASS'] ?? '';
  static String get emailFrom => dotenv.env['EMAIL_FROM'] ?? 'noreply@datingapp.com';

  // Cloudinary
  static String get cloudinaryCloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get cloudinaryApiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static String get cloudinaryApiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  // Redis
  static String get redisUrl => dotenv.env['REDIS_URL'] ?? '';
  static String get redisPassword => dotenv.env['REDIS_PASSWORD'] ?? '';

  // CORS
  static List<String> get allowedOrigins {
    final origins = dotenv.env['ALLOWED_ORIGINS'] ?? '';
    return origins.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  // Helper to check if in development mode
  static bool get isDevelopment => env == 'development';
  static bool get isProduction => env == 'production';
  static bool get isTesting => env == 'test';
}