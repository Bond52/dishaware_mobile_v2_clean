import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../api/api_client.dart';
import '../models/recipe.dart';

/// Service recette menu : `POST /dishes/recipe` (base Dio = [ApiConfig.apiBaseUrl] → déjà suffixe `/api`).
class MenuRecipeApiService {
  MenuRecipeApiService._();

  /// Cache mémoire par nom de plat (rapide, session courante).
  static final Map<String, Recipe> recipeCache = {};

  static String _cacheKey(String dishName) => dishName.trim().toLowerCase();

  /// Récupère une recette (cache mémoire puis API).
  ///
  /// [bypassCache] : ex. pull-to-refresh pour forcer un nouvel appel.
  static Future<(Recipe recipe, bool fromMemoryCache)> fetchRecipe(
    String dishName,
    String description, {
    bool bypassCache = false,
  }) async {
    final name = dishName.trim();
    if (name.isEmpty) {
      throw ArgumentError('dishName vide');
    }

    final key = _cacheKey(name);
    if (!bypassCache && recipeCache.containsKey(key)) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('RECIPE CACHE HIT: $name');
      }
      return (recipeCache[key]!, true);
    }

    if (kDebugMode) {
      // ignore: avoid_print
      print('RECIPE REQUEST: $name');
    }

    final options = await ApiClient.optionsWithUserId();
    try {
      final response = await ApiClient.dio.post(
        '/dishes/recipe',
        data: {
          'dishName': name,
          'description': description,
        },
        options: options,
      );

      if (kDebugMode) {
        // ignore: avoid_print
        print('RECIPE RESPONSE: ${response.data}');
      }

      final data = response.data;
      if (data is! Map) {
        throw FormatException('Réponse recette invalide (objet JSON attendu à la racine)');
      }
      final root = Map<String, dynamic>.from(data);
      final recipeRaw = root['recipe'];
      if (recipeRaw is! Map) {
        throw FormatException('Champ "recipe" manquant ou invalide dans la réponse');
      }
      final recipe = Recipe.fromJson(Map<String, dynamic>.from(recipeRaw));
      final resolved = recipe.title.trim().isEmpty
          ? Recipe(
              id: recipe.id,
              title: name,
              description: recipe.description,
              ingredients: recipe.ingredients,
              steps: recipe.steps,
              cookingTime: recipe.cookingTime,
              difficulty: recipe.difficulty,
              tips: recipe.tips,
              nutritionSummary: recipe.nutritionSummary,
              calories: recipe.calories,
            )
          : recipe;

      recipeCache[key] = resolved;
      return (resolved, false);
    } on DioException catch (e, st) {
      debugPrint('[MenuRecipeApi] fetchRecipe failed: $e\n$st');
      if (kDebugMode) {
        // ignore: avoid_print
        print('RECIPE ERROR: ${e.response?.statusCode} ${e.response?.data}');
      }
      rethrow;
    }
  }
}
