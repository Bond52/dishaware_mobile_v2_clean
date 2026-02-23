import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../api/api_client.dart';

/// Envoie la position au backend toutes les 3 minutes (polling simple, pas de background).
class LocationService {
  static Timer? _timer;
  static bool _running = false;

  static bool get isRunning => _running;

  /// Démarre le polling : position toutes les 3 min → POST /location/update.
  static void startPolling() {
    if (_running) return;
    _running = true;
    if (kDebugMode) {
      debugPrint('[flutterNotification] location polling started');
    }
    _tick();
    _timer = Timer.periodic(const Duration(minutes: 3), (_) => _tick());
  }

  /// Arrête le polling.
  static void stopPolling() {
    _timer?.cancel();
    _timer = null;
    _running = false;
    if (kDebugMode) {
      debugPrint('[flutterNotification] location polling stopped');
    }
  }

  static Future<void> _tick() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      await ApiClient.dio.post(
        '/location/update',
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
        },
        options: await ApiClient.optionsWithUserId(),
      );
      if (kDebugMode) {
        debugPrint('[flutterNotification] location sent');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[flutterNotification] location update error (silent): $e');
      }
    }
  }
}
