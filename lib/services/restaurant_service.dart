import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../features/restaurants/models/restaurant.dart';

class RestaurantService {
  static Future<List<Restaurant>> fetchNearbyRestaurants({
    required double lat,
    required double lng,
    int radius = 1000,
  }) async {
    final response = await ApiClient.dio.get(
      '/restaurants/nearby',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius': radius,
      },
      options: await ApiClient.optionsWithUserId(),
    );

    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Restaurant.fromJson)
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['restaurants'] ?? data['items'] ?? data['results'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(Restaurant.fromJson)
            .toList();
      }
    }
    return [];
  }
}
