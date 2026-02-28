import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/dish_suggestion.dart';
import '../models/filter_payload.dart';

class AiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<DishSuggestion>> getSuggestions(
    FiltersPayload filters,
  ) async {
    final response = await _dio.post(
      '/ai/suggestions',
      data: filters.toJson(),
    );

    final List data = response.data['suggestions'];

    return data
        .map((json) => DishSuggestion.fromJson(json))
        .toList();
  }
}
