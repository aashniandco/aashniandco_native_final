import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../../navigation_service.dart';
import '../auth/view/native_product_screen.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _localNotifications =
//   FlutterLocalNotificationsPlugin();
//
//   static Future<void> init() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//     // 🔹 Request permission (Android 13+)
//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     // 🔹 Local notification init
//     const AndroidInitializationSettings androidInit =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings initSettings =
//     InitializationSettings(android: androidInit);
//
//     await _localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (response) {
//         debugPrint("🔔 Notification clicked: ${response.payload}");
//       },
//     );
//
//     // 🔹 Foreground notification
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _showNotification(message);
//     });
//
//     // 🔹 App opened from notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       debugPrint("📲 App opened from notification");
//     });
//   }
//
//   static Future<void> _showNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//
//     const NotificationDetails details =
//     NotificationDetails(android: androidDetails);
//
//     await _localNotifications.show(
//       0,
//       message.notification?.title ?? 'Aashni & Co',
//       message.notification?.body ?? '',
//       details,
//       payload: message.data.toString(),
//     );
//   }
//
//   /// 🔑 Get FCM Token
//   static Future<String?> getFcmToken() async {
//     return await FirebaseMessaging.instance.getToken();
//   }
// }

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  /// 🔔 INITIALIZE NOTIFICATIONS
  static Future<void> init() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // iOS permission
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ANDROID SETTINGS
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS SETTINGS
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // COMBINED SETTINGS
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          final Map<String, dynamic> data =
          jsonDecode(response.payload!);
          _handleNotificationClick(data);
        }
      },
    );

    // FOREGROUND MESSAGE
    FirebaseMessaging.onMessage.listen(_showNotification);

    // BACKGROUND / TERMINATED CLICK
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationClick(message.data);
    });

    final initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage.data);
    }
  }

  /// 🔔 SHOW LOCAL NOTIFICATION (FOREGROUND)
  static Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Aashni & Co',
      message.notification?.body ?? '',
      details,
      payload: jsonEncode(message.data),
    );
  }

  /// 🔑 SAFE FCM TOKEN (iOS APNS AWARE)
  static Future<String?> getFcmToken() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // iOS needs APNS token first
    if (Platform.isIOS) {
      String? apnsToken;

      for (int i = 0; i < 10; i++) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (apnsToken == null) {
        debugPrint('❌ APNS token not available');
        return null;
      }

      debugPrint('✅ APNS TOKEN: $apnsToken');
    }

    final fcmToken = await messaging.getToken();
    return fcmToken;
  }

  /// 🧭 HANDLE NOTIFICATION CLICK
  static void _handleNotificationClick(Map<String, dynamic> data) {
    final String type = data['type'] ?? '';
    final String url = data['url'] ?? '';

    if (type == 'offer' && url.isNotEmpty) {
      NavigationService.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => NativeCategoryScreen(url: url),
        ),
      );
    }
  }
}


