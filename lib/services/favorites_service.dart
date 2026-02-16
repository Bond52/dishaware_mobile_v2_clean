import '../api/api_client.dart';
import '../features/recommendations/domain/recommended_dish.dart';

class FavoritesService {
  static Future<void> toggleFavorite({required String dishId}) async {
    await ApiClient.dio.post(
      '/favorites/toggle',
      data: {
        'dishId': dishId,
      },
      options: await ApiClient.optionsWithUserId(),
    );
  }

  static Future<List<RecommendedDish>> getFavorites() async {
    final response = await ApiClient.dio.get(
      '/favorites',
      options: await ApiClient.optionsWithUserId(),
    );
    final data = response.data;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(RecommendedDish.fromJson)
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final list = data['items'] ?? data['favorites'] ?? data['results'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(RecommendedDish.fromJson)
            .toList();
      }
    }

    if (data is Map<String, dynamic> && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RecommendedDish.fromJson)
          .toList();
    }

    return [];
  }
}
