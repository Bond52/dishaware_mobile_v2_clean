import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/api_client.dart';
import '../models/user_profile.dart';

class ProfileApiService {
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
      final profile =
          UserProfile.fromJson(response.data as Map<String, dynamic>);
      final responseUserId = (response.data as Map<String, dynamic>)['userId'];
      if (responseUserId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserId', responseUserId.toString());
      }
      return profile;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        if (kDebugMode) debugPrint('[ProfileApi] 404 sur /profile/me, essai GET /profile/$userId');
        try {
          final response = await ApiClient.dio.get(
            '/profile/$userId',
            options: opts,
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

  static Future<UserProfile> createProfile(
      Map<String, dynamic> payload) async {
    final response = await ApiClient.dio.post(
      '/profile',
      data: payload,
      options: await _options(),
    );
    final profile =
        UserProfile.fromJson(response.data as Map<String, dynamic>);
    final responseUserId = (response.data as Map<String, dynamic>)['userId'];
    if (responseUserId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', responseUserId.toString());
    }
    return profile;
  }

  static Future<UserProfile> updateProfile(
      Map<String, dynamic> payload) async {
    final response = await ApiClient.dio.put(
      '/profile',
      data: payload,
      options: await _options(),
    );
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
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
