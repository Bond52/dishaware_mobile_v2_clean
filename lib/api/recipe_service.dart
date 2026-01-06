import 'package:dio/dio.dart';
import '../models/dish_suggestion.dart';
import 'package:flutter/foundation.dart'; // ✅ debugPrint


class RecipeService {
  final Dio _dio = Dio(
    BaseOptions(
               // baseUrl: "http://10.0.2.2:4000/api", // backend local
     baseUrl: "https://dishaware-backend.onrender.com/api",
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<DishSuggestion> getRecipeById(String id) async {
    debugPrint("📡 GET http://10.0.2.2:4000/recipe/$id");

    final response = await _dio.get('/recipe/$id');

    debugPrint("📦 Recipe API response: ${response.data}");

    return DishSuggestion.fromJson(response.data);
  }
}
