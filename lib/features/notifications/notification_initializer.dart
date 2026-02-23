import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'location_service.dart';
import 'notification_service.dart';

const String _keyOptIn = 'notifications_geoloc_opt_in';

/// À appeler au lancement de l'app : si opt-in actif, init FCM et démarre le polling position.
class NotificationInitializer {
  static Future<bool> isOptInActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOptIn) ?? false;
  }

  static Future<void> setOptIn(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOptIn, enabled);
  }

  static Future<void> run() async {
    try {
      final enabled = await isOptInActive();
      if (!enabled) return;

      if (kDebugMode) {
        debugPrint('[flutterNotification] opt-in enabled, initializing');
      }
      await NotificationService.initialize();
      LocationService.startPolling();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[flutterNotification] initializer error: $e');
      }
    }
  }
}
