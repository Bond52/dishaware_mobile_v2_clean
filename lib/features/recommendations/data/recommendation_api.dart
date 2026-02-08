import 'package:dio/dio.dart';
import '../../../api/api_client.dart';
import '../domain/recommended_dish.dart';

class RecommendationApi {
  static const String _mockUserId = '64b7f9c2f5c1f2b3a4c5d6e7';

  static Options _options() {
    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'x-user-id': _mockUserId,
      },
    );
  }

  static Future<List<RecommendedDish>> getRecommendations({int limit = 10}) async {
    final response = await ApiClient.dio.get(
      '/recommendations/debug',
      queryParameters: {'limit': limit},
      options: _options(),
    );

    final data = response.data;
    List<RecommendedDish> items = [];
    if (data is List) {
      items = data
          .whereType<Map<String, dynamic>>()
          .map(RecommendedDish.fromJson)
          .toList();
    } else if (data is Map<String, dynamic>) {
      final list = data['results'] ?? data['items'] ?? data['data'];
      if (list is List) {
        items = list
            .whereType<Map<String, dynamic>>()
            .map(RecommendedDish.fromJson)
            .toList();
      }
    }

    items.sort((a, b) => b.score.compareTo(a.score));
    for (final item in items) {
      if (item.explanation.isNotEmpty) {
        // ignore: avoid_print
        print('Recommendation explanation: ${item.explanation}');
      }
    }

    return items;
  }
}
