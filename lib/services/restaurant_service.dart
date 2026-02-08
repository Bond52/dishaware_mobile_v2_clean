import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../features/restaurants/models/restaurant.dart';

class RestaurantService {
  static const String _mockUserId = '64b7f9c2f5c1f2b3a4c5d6e7';

  static Options _options() {
    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'x-user-id': _mockUserId,
      },
    );
  }

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
      options: _options(),
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
