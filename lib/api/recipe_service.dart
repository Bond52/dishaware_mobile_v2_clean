import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/dish_suggestion.dart';

class RecipeService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<DishSuggestion> getRecipeById(String id) async {
    debugPrint("📡 GET ${ApiConfig.apiBaseUrl}/recipe/$id");

    final response = await _dio.get('/recipe/$id');

    debugPrint("📦 Recipe API response: ${response.data}");

    return DishSuggestion.fromJson(response.data);
  }
}
