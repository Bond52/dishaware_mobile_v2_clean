import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../features/profile/models/share_target.dart';

class ShareTargetService {
  static const String _mockUserId = '64b7f9c2f5c1f2b3a4c5d6e7';

  static Options _options() {
    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'x-user-id': _mockUserId,
      },
    );
  }

  static Future<List<ShareTarget>> searchShareTargets(String query) async {
    final response = await ApiClient.dio.get(
      '/share-targets/search',
      queryParameters: {'q': query},
      options: _options(),
    );

    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ShareTarget.fromJson)
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['items'] ?? data['results'] ?? data['data'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(ShareTarget.fromJson)
            .toList();
      }
    }
    return [];
  }
}
