import 'package:dio/dio.dart';
import '../models/filter_payload.dart';
import '../models/dish_suggestion.dart';

class AiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000', // ⚠️ adapter si besoin
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
