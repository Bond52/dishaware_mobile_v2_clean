import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_client.dart';
import '../notifications/location_service.dart';
import 'models/user.dart' as app_user;

/// Déconnexion : nettoie token, user, Firebase, Google, polling position.
/// Idempotent (safe si déjà déconnecté).
class LogoutService {
  static const String _keyAuthToken = 'auth_token';

  /// Nettoie tout sans lever d'exception (gère token expiré, userId null, double appel).
  static Future<void> performLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAuthToken);
      await app_user.User.clearFromPrefs();
    } catch (_) {}

    try {
      ApiClient.clearToken();
    } catch (_) {}

    try {
      LocationService.stopPolling();
    } catch (_) {}

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
  }
}
