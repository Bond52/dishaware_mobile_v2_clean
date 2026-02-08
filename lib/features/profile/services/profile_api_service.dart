import 'package:dio/dio.dart';
import '../../../api/api_client.dart';
import '../models/user_profile.dart';

class ProfileApiService {
  static const String _mockUserId = '64b7f9c2f5c1f2b3a4c5d6e7';

  static Map<String, dynamic> _headers() => {
        'x-user-id': _mockUserId,
      };

  static Options _options() {
    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        ..._headers(),
      },
    );
  }

  static Future<UserProfile> getMyProfile() async {
    final response = await ApiClient.dio.get(
      '/profile/me',
      options: _options(),
    );
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<UserProfile> createProfile(
      Map<String, dynamic> payload) async {
    final response = await ApiClient.dio.post(
      '/profile',
      data: payload,
      options: _options(),
    );
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<UserProfile> updateProfile(
      Map<String, dynamic> payload) async {
    final response = await ApiClient.dio.put(
      '/profile',
      data: payload,
      options: _options(),
    );
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }
}
