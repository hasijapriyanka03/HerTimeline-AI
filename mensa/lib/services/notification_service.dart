import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission for iOS and Android 13+
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('⚠️ User granted provisional notification permission');
      } else {
        debugPrint(
          '❌ User declined or has not accepted notification permission',
        );
      }

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      debugPrint('📱 FCM Token: $token');
      debugPrint(
        '📋 Copy this token to test notifications from Firebase Console',
      );

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM Token refreshed: $newToken');
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📬 Got a message in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('📬 Notification: ${message.notification!.title}');
          debugPrint('📝 Body: ${message.notification!.body}');

          // Display local notification when app is in foreground
          _showLocalNotification(
            title: message.notification!.title ?? 'Mensa',
            body: message.notification!.body ?? '',
            payload: message.data.toString(),
          );
        }
      });

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔔 Notification tapped! Opening app...');
        debugPrint('Message data: ${message.data}');
        _handleNotificationTap(message.data);
      });

      // Check if app was opened from a terminated state via notification
      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🚀 App opened from terminated state via notification');
        debugPrint('Message data: ${initialMessage.data}');
        _handleNotificationTap(initialMessage.data);
      }
    } catch (e) {
      debugPrint('❌ Error initializing notification service: $e');
      rethrow;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
        if (response.payload != null) {
          _handleNotificationTap({'payload': response.payload});
        }
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pregnancy_tracker_channel',
      'Pregnancy Tracker Notifications',
      description: 'Notifications for pregnancy tracking and health reminders',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pregnancy_tracker_channel',
          'Pregnancy Tracker Notifications',
          channelDescription:
              'Notifications for pregnancy tracking and health reminders',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    // Handle navigation based on notification data
    debugPrint('Handling notification tap with data: $data');
    // TODO: Implement navigation logic based on notification type
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to topic for group notifications
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('✅ Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('❌ Unsubscribed from topic: $topic');
  }

  // Schedule a local notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      await _localNotifications.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pregnancy_tracker_channel',
            'Pregnancy Tracker Notifications',
            channelDescription:
                'Notifications for pregnancy tracking and health reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      // Fallback: show immediate notification instead
      await _showLocalNotification(title: title, body: body);
    }
  }

  // Show immediate notification (simpler, no scheduling)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    await _showLocalNotification(title: title, body: body);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}
