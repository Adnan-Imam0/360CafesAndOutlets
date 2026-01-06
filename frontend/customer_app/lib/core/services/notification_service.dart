import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_client.dart';

// Background handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔥 [BACKGROUND] Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiClient _apiClient = ApiClient();

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize(String firebaseUid) async {
    print('🚀 [FCM] Initializing NotificationService for $firebaseUid...');

    // 1. Request Permission
    print('🚀 [FCM] Requesting permission...');
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🚀 [FCM] Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('🚀 [FCM] User granted permission');

      // 2. Setup Background Handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 3. Get Token and Save to Backend
      try {
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          print('🚀 [FCM] Token retrieved: ${token.substring(0, 10)}...');
          await _saveTokenToBackend(firebaseUid, token);
        } else {
          print('❌ [FCM] Token is NULL!');
        }
      } catch (e) {
        print('❌ [FCM] Error getting token: $e');
      }

      // 4. Setup Foreground Handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('🔥 [FOREGROUND] Got a message!');
        if (message.notification != null) {
          print(
            '🔥 [FOREGROUND] Title: ${message.notification?.title}, Body: ${message.notification?.body}',
          );
        }
      });
    } else {
      print('❌ [FCM] User declined or has not accepted permission');
    }
  }

  Future<void> _saveTokenToBackend(String uid, String token) async {
    try {
      print('🚀 [FCM] Sending token to backend...');
      await _apiClient.patch('/users/customers/$uid/fcm', {'fcm_token': token});
      print('✅ [FCM] Token saved to backend successfully!');
    } catch (e) {
      print('❌ [FCM] Failed to save FCM token to backend: $e');
    }
  }
}
