import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dating_app/services/api_service.dart';
import 'package:dating_app/config/api_constants.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // Static counter for notification IDs
  static int _notificationIdCounter = 0;

  static Future<void> initialize() async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      settings:
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response);
      },
      onDidReceiveBackgroundNotificationResponse: _handleBackgroundNotificationTap,
    );

    // Request permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $token');

      // Save token to server
      if (token != null) {
        await _saveTokenToServer(token);
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Handle when app is opened from a terminated state
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleRemoteMessageTap(initialMessage);
      }
    }
  }

  static Future<void> _saveTokenToServer(String token) async {
    try {
      final apiService = ApiService();
      await apiService.post(
        '/notifications/device',
        data: {'device_token': token},
      );
    } catch (e) {
      print('❌ Failed to save FCM token: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('📨 Handling background message: ${message.messageId}');

    if (message.notification != null) {
      await _showBackgroundNotification(message);
    }
  }

  @pragma('vm:entry-point')
  static void _handleBackgroundNotificationTap(NotificationResponse response) {
    print('🔔 Background notification tapped: ${response.payload}');
  }

  static Future<void> _showBackgroundNotification(RemoteMessage message) async {
    _notificationIdCounter++;
    final int notificationId = _notificationIdCounter;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'dating_app_channel',
      'Dating App Notifications',
      channelDescription: 'Notifications for matches and messages',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // FIXED: Using named parameters correctly
    await _localNotifications.show(
      id: notificationId,
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? 'You have a new notification',
      notificationDetails: platformChannelSpecifics,
      payload: message.data['type'] ?? 'general',
    );
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    _notificationIdCounter++;
    final int notificationId = _notificationIdCounter;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'dating_app_channel',
      'Dating App Notifications',
      channelDescription: 'Notifications for matches and messages',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    // FIXED: Using named parameters correctly
    await _localNotifications.show(
      id: notificationId,
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? 'You have a new notification',
      notificationDetails: platformChannelSpecifics,
      payload: message.data['type'] ?? 'general',
    );
  }

  static Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    _notificationIdCounter++;
    final int notificationId = id ?? _notificationIdCounter;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'dating_app_channel',
      'Dating App Notifications',
      channelDescription: 'Notifications for matches and messages',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // FIXED: Using named parameters correctly
    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: payload,
    );
  }

  static void _handleNotificationTap(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');

    if (response.payload == 'match') {
      _navigateTo('/home/matches');
    } else if (response.payload == 'message') {
      _navigateTo('/home/chat');
    } else if (response.payload == 'like') {
      _navigateTo('/home/profile');
    }
  }

  static void _handleRemoteMessageTap(RemoteMessage message) {
    print('🔔 Remote message tapped: ${message.data}');

    final type = message.data['type'];
    final matchId = message.data['matchId'];

    if (type == 'match') {
      _navigateTo('/home/matches');
    } else if (type == 'message') {
      _navigateTo('/home/chat/$matchId');
    } else if (type == 'like') {
      _navigateTo('/home/profile');
    }
  }

  static void _navigateTo(String route) {
    print('📍 Navigating to: $route');
    // Implement navigation using your router
  }

  static Future<void> getUnreadNotifications() async {
    try {
      final apiService = ApiService();
      final response = await apiService.get(ApiConstants.unreadNotifications);
    } catch (e) {
      print('❌ Failed to get unread notifications: $e');
    }
  }

  static Future<void> markAsRead(int notificationId) async {
    try {
      final apiService = ApiService();
      await apiService.put('${ApiConstants.markRead}/$notificationId/read');
    } catch (e) {
      print('❌ Failed to mark notification as read: $e');
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      final apiService = ApiService();
      await apiService.put(ApiConstants.markAllRead);
    } catch (e) {
      print('❌ Failed to mark all notifications as read: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id:id);
  }

  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  static void resetCounter() {
    _notificationIdCounter = 0;
  }

  // Test method
  static void testNotification() {
    showCustomNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Dating App!',
      payload: 'test',
    );
    print('✅ Test notification sent!');
  }
}