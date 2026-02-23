import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_client.dart';
import '../../api/auth_api.dart';
import '../../main.dart';
import 'models/user.dart' as app_user;

/// Résultat de la connexion Google (pour UX : annulation, réseau, token invalide).
enum GoogleAuthStatus {
  success,
  cancelled,
  networkError,
  invalidToken,
  timeout,
}

/// Délai max pour tout le flux Google (évite chargement infini sur émulateur).
const Duration _kGoogleSignInTimeout = Duration(seconds: 60);

/// Connexion / inscription via Google : Google Sign-In → Firebase → backend → JWT.
class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Lance le flux complet. Retourne le statut sans lever d'exception.
  static Future<GoogleAuthStatus> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn()
          .timeout(_kGoogleSignInTimeout, onTimeout: () {
        if (kDebugMode) debugPrint('[GoogleAuth] signIn() timeout');
        throw TimeoutException('Google Sign-In', _kGoogleSignInTimeout);
      });
      if (account == null) return GoogleAuthStatus.cancelled;

      final GoogleSignInAuthentication googleAuth =
          await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      final User? user = _firebaseAuth.currentUser;
      if (user == null) return GoogleAuthStatus.cancelled;

      final String? firebaseIdToken = await user.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        await _signOutAll();
        return GoogleAuthStatus.invalidToken;
      }

      Map<String, dynamic> result;
      try {
        result = await AuthApi.loginWithGoogle(idToken: firebaseIdToken);
      } catch (_) {
        return GoogleAuthStatus.networkError;
      }

      if (result['success'] != true || result['token'] == null) {
        await _signOutAll();
        return GoogleAuthStatus.invalidToken;
      }

      final String token = result['token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      final appUser = app_user.User.fromLoginResponse(Map<String, dynamic>.from(result));
      if (appUser != null) {
        await app_user.User.persist(appUser);
      } else {
        await prefs.setString('currentUserId', token);
      }
      globalToken = token;
      ApiClient.setToken(token);

      return GoogleAuthStatus.success;
    } on TimeoutException {
      await _signOutAll();
      return GoogleAuthStatus.timeout;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[GoogleAuth] error: $e');
        debugPrint('[GoogleAuth] stack: $st');
      }
      await _signOutAll();
      return GoogleAuthStatus.networkError;
    }
  }

  static Future<void> _signOutAll() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
