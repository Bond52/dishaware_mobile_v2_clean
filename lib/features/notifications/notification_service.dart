import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../router.dart';

/// Gère FCM : permissions, token, réception des notifications, navigation au clic.
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Initialise Firebase Messaging, demande la permission, enregistre les listeners.
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _initialized = true;
      if (kDebugMode) {
        debugPrint('[flutterNotification] token registered');
      }
      _setupListeners();
      // App ouverte depuis une notification (app était fermée)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          debugPrint('[flutterNotification] notification received (cold start)');
        }
        _navigateFromPayload(initialMessage.data);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[flutterNotification] init error: $e');
      }
    }
  }

  static void _setupListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('[flutterNotification] notification received: ${message.notification?.title}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('[flutterNotification] notification opened: ${message.data}');
      }
      _navigateFromPayload(message.data);
    });
  }

  static void _navigateFromPayload(Map<String, dynamic> data) {
    final restaurantId = data['restaurantId']?.toString();
    if (restaurantId != null && restaurantId.isNotEmpty) {
      appRouter.go('/restaurant/$restaurantId');
    }
  }

  /// Récupère le token FCM actuel (pour opt-in).
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode && token != null) {
        debugPrint('[flutterNotification] token obtained');
      }
      return token;
    } catch (e) {
      if (kDebugMode) debugPrint('[flutterNotification] getToken error: $e');
      return null;
    }
  }

  /// Demande la permission notification (pour affichage dans les réglages).
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
