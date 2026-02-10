import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../features/profile/models/share_target.dart';
import '../features/profile_comparison/models/received_share_profile.dart';

class ProfileShareService {
  static const String _mockUserId = '64b7f9c2f5c1f2b3a4c5d6e7';

  static Options _options() {
    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'x-user-id': _mockUserId,
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
      options: _options(),
    );
  }

  static Future<List<ReceivedShareProfile>> getReceivedShares() async {
    final response = await ApiClient.dio.get(
      '/profile-shares/received/me',
      options: _options(),
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
