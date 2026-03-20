import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';

/// Appels liés aux ingrédients (scan image → liste).
class IngredientService {
  IngredientService._();

  /// POST `/ai/ingredients-from-image` avec `image_base64`.
  static Future<List<String>> ingredientsFromImageBase64(String imageBase64) async {
    if (imageBase64.trim().isEmpty) {
      throw ArgumentError('image_base64 vide');
    }
    final options = await ApiClient.optionsWithUserId();
    try {
      final response = await ApiClient.dio.post<dynamic>(
        '/ai/ingredients-from-image',
        data: {'image_base64': imageBase64},
        options: options,
      );
      return _parseIngredientsResponse(response.data);
    } on DioException catch (e, st) {
      debugPrint('[IngredientService] ingredientsFromImageBase64: $e\n$st');
      rethrow;
    }
  }

  static List<String> _parseIngredientsResponse(dynamic raw) {
    final list = _extractList(raw);
    return list
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static List<dynamic> _extractList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw;
    if (raw is! Map) return [];
    final m = Map<String, dynamic>.from(raw);
    if (m['data'] != null) {
      return _extractList(m['data']);
    }
    final candidates = [
      m['ingredients'],
      m['detectedIngredients'],
      m['detected'],
      m['items'],
      m['labels'],
    ];
    for (final c in candidates) {
      if (c is List) return c;
      if (c is Map) {
        return c.values.toList();
      }
    }
    return [];
  }
}
