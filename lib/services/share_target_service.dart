import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../features/profile/models/share_target.dart';

class ShareTargetService {
  static Future<List<ShareTarget>> searchShareTargets(String query) async {
    final response = await ApiClient.dio.get(
      '/share-targets/search',
      queryParameters: {'q': query},
      options: await ApiClient.optionsWithUserId(),
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
