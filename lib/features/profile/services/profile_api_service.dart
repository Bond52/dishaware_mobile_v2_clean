import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/api_client.dart';
import '../../auth/models/user.dart';
import '../models/user_profile.dart';

class ProfileApiService {
  static final RegExp _mongoObjectIdHex =
      RegExp(r'^[a-f0-9]{24}$', caseSensitive: false);

  static bool _isMongoObjectIdString(String s) =>
      _mongoObjectIdHex.hasMatch(s.trim());

  /// Met à jour `currentUserId` + JSON [User] avec l’id attendu en `x-user-id`.
  ///
  /// **Priorité : `userId` du profil** (clé métier : mock_, ObjectId compte, etc.) — c’est ce que
  /// `/profile/me`, recommandations et favoris résolvent en base. Le **`_id` du document UserProfile**
  /// n’est pas interchangeable (sinon 404 « Profil introuvable »).
  ///
  /// Si `userId` est absent, repli sur un ObjectId 24 hex (`_id` / `id` / `profileId`).
  static Future<void> _persistCanonicalUserIdFromResponse(
    Map<String, dynamic> body,
  ) async {
    final dataNode =
        (body['data'] is Map<String, dynamic>) ? body['data'] as Map<String, dynamic> : null;
    final root = dataNode ?? body;

    String? pick(String key) {
      final v = root[key]?.toString().trim();
      return (v != null && v.isNotEmpty) ? v : null;
    }

    String? canonical = pick('userId');
    if (canonical == null) {
      for (final k in ['_id', 'id', 'profileId']) {
        final v = pick(k);
        if (v != null && _isMongoObjectIdString(v)) {
          canonical = v;
          break;
        }
      }
    }

    if (canonical == null || canonical.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', canonical);

    final u = await User.loadFromPrefs();
    if (u != null && u.userId != canonical) {
      await User.persist(
        User(
          userId: canonical,
          firstName: u.firstName,
          lastName: u.lastName,
          name: u.name,
          hasCompletedOnboarding: u.hasCompletedOnboarding,
        ),
      );
    }
  }

  static Future<String> _requireUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('currentUserId');
    if (userId == null || userId.isEmpty) {
      throw Exception('UserId non initialisé');
    }
    if (kDebugMode) {
      debugPrint('[ProfileApi] GET /profile/me avec x-user-id: $userId');
    }
    return userId;
  }

  static Future<Options> _options() async {
    final userId = await _requireUserId();
    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'x-user-id': userId,
      },
    );
  }

  /// GET /profile/me avec x-user-id (userId du profil en base).
  /// Si 404 : fallback GET /profile/:userId avec le même x-user-id.
  static Future<UserProfile?> getMyProfile() async {
    final opts = await _options();
    final userId = await _requireUserId();

    try {
      final response = await ApiClient.dio.get(
        '/profile/me',
        options: opts,
      );
      if (kDebugMode && response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        final dataNode =
            (body['data'] is Map<String, dynamic>) ? body['data'] as Map<String, dynamic> : null;
        final root = dataNode ?? body;
        debugPrint('PROFILE RECEIVED: $root');
        debugPrint('ALGO FEATURES: ${root['algorithmFeatures']}');
      }
      final map = response.data as Map<String, dynamic>;
      final profile = UserProfile.fromJson(map);
      await _persistCanonicalUserIdFromResponse(map);
      return profile;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        if (kDebugMode) debugPrint('[ProfileApi] 404 sur /profile/me, essai GET /profile/$userId');
        try {
          final response = await ApiClient.dio.get(
            '/profile/$userId',
            options: opts,
          );
          if (kDebugMode && response.data is Map<String, dynamic>) {
            final body = response.data as Map<String, dynamic>;
            final dataNode =
                (body['data'] is Map<String, dynamic>) ? body['data'] as Map<String, dynamic> : null;
            final root = dataNode ?? body;
            debugPrint('PROFILE RECEIVED: $root');
            debugPrint('ALGO FEATURES: ${root['algorithmFeatures']}');
          }
          final map2 = response.data as Map<String, dynamic>;
          await _persistCanonicalUserIdFromResponse(map2);
          return UserProfile.fromJson(map2);
        } on DioException catch (e2) {
          if (e2.response?.statusCode == 404) return null;
          rethrow;
        }
      }
      rethrow;
    }
  }

  static Future<UserProfile> createProfile(
      Map<String, dynamic> payload) async {
    final response = await ApiClient.dio.post(
      '/profile',
      data: payload,
      options: await _options(),
    );
    final map = response.data as Map<String, dynamic>;
    final profile = UserProfile.fromJson(map);
    await _persistCanonicalUserIdFromResponse(map);
    return profile;
  }

  static Future<UserProfile> updateProfile(
      Map<String, dynamic> payload) async {
    final response = await ApiClient.dio.put(
      '/profile',
      data: payload,
      options: await _options(),
    );
    final map = response.data as Map<String, dynamic>;
    await _persistCanonicalUserIdFromResponse(map);
    return UserProfile.fromJson(map);
  }

  /// Récupère le profil d'un utilisateur par son id (pour Mode Hôte, profils partagés).
  /// Essaie GET /profiles/:userId puis GET /profile/:userId en fallback.
  static Future<UserProfile?> getProfileByUserId(String userId) async {
    try {
      final response = await ApiClient.dio.get(
        '/profiles/$userId',
        options: await _options(),
      );
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          final response = await ApiClient.dio.get(
            '/profile/$userId',
            options: await _options(),
          );
          return UserProfile.fromJson(response.data as Map<String, dynamic>);
        } on DioException catch (e2) {
          if (e2.response?.statusCode == 404) return null;
          rethrow;
        }
      }
      rethrow;
    }
  }
}
