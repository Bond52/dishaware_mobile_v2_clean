import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../features/profile/models/share_target.dart';
import '../features/profile_comparison/models/received_share_profile.dart';

class ProfileShareService {
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

  static Future<void> createProfileShare({
    required String targetId,
    required ShareTargetType targetType,
  }) async {
    await ApiClient.dio.post(
      '/profile-shares',
      data: {
        'targetType': targetType == ShareTargetType.user ? 'user' : 'event',
        'targetId': targetId,
        'scope': 'compare',
        'duration': '24h',
      },
      options: await _options(),
    );
  }

  static Future<List<ReceivedShareProfile>> getReceivedShares() async {
    final response = await ApiClient.dio.get(
      '/profile-shares/received/me',
      options: await _options(),
    );
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ReceivedShareProfile.fromJson)
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['items'] ?? data['results'] ?? data['data'] ?? data['shares'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(ReceivedShareProfile.fromJson)
            .toList();
      }
    }
    return [];
  }
}
