import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/api_client.dart';
import '../models/user_profile.dart';

class ProfileApiService {
  static Future<String> _requireUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('currentUserId');
    if (userId == null || userId.isEmpty) {
      throw Exception('UserId non initialisé (mockAuth)');
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

  static Future<UserProfile> getMyProfile() async {
    final response = await ApiClient.dio.get(
      '/profile/me',
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
