import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../features/profile/models/share_target.dart';

class ShareTargetService {
  static Future<List<ShareTarget>> searchShareTargets(String query) async {
    debugPrint('[SHARE_TARGETS] GET /share-targets/search?q=$query');
    List<ShareTarget> result = [];
    try {
      final response = await ApiClient.dio.get(
        '/share-targets/search',
        queryParameters: {'q': query},
        options: await ApiClient.optionsWithUserId(),
      );

      final data = response.data;
      debugPrint('[SHARE_TARGETS] status: ${response.statusCode}, data type: ${data.runtimeType}');

      if (data is List) {
        debugPrint('[SHARE_TARGETS] response is List, length: ${data.length}');
        result = data
            .whereType<Map<String, dynamic>>()
            .map((e) => ShareTarget.fromJson(e))
            .toList();
      } else if (data is Map<String, dynamic>) {
        debugPrint('[SHARE_TARGETS] response is Map, keys: ${data.keys.toList()}');
        final list = data['items'] ?? data['results'] ?? data['data'] ?? data['users'] ?? data['profiles'];
        if (list is List) {
          debugPrint('[SHARE_TARGETS] list length: ${list.length}');
          result = list
              .whereType<Map<String, dynamic>>()
              .map((e) => ShareTarget.fromJson(e))
              .toList();
        } else {
          debugPrint('[SHARE_TARGETS] no list in map (items/results/data/users/profiles)');
        }
      }
      debugPrint('[SHARE_TARGETS] parsed ${result.length} targets');
    } on DioException catch (e) {
      debugPrint('[SHARE_TARGETS] DioException: ${e.type} ${e.message}');
      debugPrint('[SHARE_TARGETS] response: ${e.response?.statusCode} ${e.response?.data}');
      rethrow;
    }
    return result;
  }
}
