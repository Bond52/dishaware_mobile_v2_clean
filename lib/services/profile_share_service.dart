import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../features/profile/models/share_target.dart';

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
}
