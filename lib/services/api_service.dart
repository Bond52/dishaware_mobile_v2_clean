import 'package:http/http.dart' as http;

import '../api/api_client.dart';
import '../config/api_config.dart';

class ApiService {
  static Future<http.Response> ping() {
    return http.get(
      Uri.parse('${ApiConfig.baseUrl}/health'),
    );
  }

  /// Recherche Explorer : appel GET /api/explorer/search (Spoonacular).
  static Future<List<dynamic>> searchExplorer({
    String? query,
    String? cuisine,
    String? diet,
    int? maxCalories,
    int? maxReadyTime,
  }) async {
    final params = <String, dynamic>{
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      if (cuisine != null && cuisine.trim().isNotEmpty) 'cuisine': cuisine.trim(),
      if (diet != null && diet.trim().isNotEmpty) 'diet': diet.trim(),
      if (maxCalories != null && maxCalories > 0) 'maxCalories': maxCalories,
      if (maxReadyTime != null && maxReadyTime > 0) 'maxReadyTime': maxReadyTime,
    };
    final response = await ApiClient.dio.get(
      '/explorer/search',
      queryParameters: params,
      options: await ApiClient.optionsWithUserId(),
    );
    final data = response.data;
    if (data is List) return data;
    if (data is Map && data['results'] != null) {
      return data['results'] as List<dynamic>;
    }
    return [];
  }
}
