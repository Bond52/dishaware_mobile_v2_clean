import '../../../api/api_client.dart';
import '../domain/recommended_dish.dart';

class RecommendationApi {
  static Future<List<RecommendedDish>> getRecommendations({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (forceRefresh) {
      queryParams['_t'] = DateTime.now().millisecondsSinceEpoch;
    }
    final response = await ApiClient.dio.get(
      '/recommendations/debug',
      queryParameters: queryParams,
      options: await ApiClient.optionsWithUserId(),
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
