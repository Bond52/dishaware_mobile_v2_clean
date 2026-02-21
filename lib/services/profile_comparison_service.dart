import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../features/profile_comparison/models/profile_comparison_models.dart';

class ProfileComparisonService {
  static Future<String> _requireUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('currentUserId');
    if (userId == null || userId.isEmpty) {
      throw Exception('UserId non initialisé (mockAuth)');
    }
    return userId;
  }

  static Future<String> get currentUserId async => _requireUserId();

  static Future<Options> _options() async {
    final userId = await _requireUserId();
    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'x-user-id': userId,
      },
    );
  }

  static Future<ProfileComparisonResult> compareProfiles({
    required String userIdA,
    required String userIdB,
  }) async {
    final response = await ApiClient.dio
        .get(
          '/profiles/compare/$userIdA/$userIdB',
          options: await _options(),
        )
        .timeout(const Duration(seconds: 12));

    // ——— LOG TEMPORAIRE: réponse brute API comparaison ———
    debugPrint('[COMPARE_API] ========== RÉPONSE BRUTE ==========');
    debugPrint('[COMPARE_API] response.data type: ${response.data.runtimeType}');
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      debugPrint('[COMPARE_API] Clés racine: ${data.keys.toList()}');
      debugPrint('[COMPARE_API] score (brut): ${data['score']}');
      debugPrint('[COMPARE_API] compatibilityLevel (brut): ${data['compatibilityLevel']}');
      if (data['divergences'] != null) {
        debugPrint('[COMPARE_API] divergences (brut): ${data['divergences']}');
        final divList = data['divergences'] as List<dynamic>? ?? [];
        debugPrint('[COMPARE_API] divergences.length: ${divList.length}');
        for (var i = 0; i < divList.length; i++) {
          final d = divList[i];
          if (d is Map<String, dynamic>) {
            debugPrint('[COMPARE_API]   divergence[$i]: type=${d['type']}, label=${d['label']}, description=${d['description']}');
          }
        }
      } else {
        debugPrint('[COMPARE_API] divergences: null ou absent');
      }
      if (data['recommendations'] != null) {
        final recList = data['recommendations'] as List<dynamic>? ?? [];
        debugPrint('[COMPARE_API] recommendations.length: ${recList.length}');
        debugPrint('[COMPARE_API] recommendations (brut): $recList');
      } else {
        debugPrint('[COMPARE_API] recommendations: null ou absent');
      }
      debugPrint('[COMPARE_API] users: ${data['users']}');
      debugPrint('[COMPARE_API] breakdown: ${data['breakdown']}');
    } else {
      debugPrint('[COMPARE_API] body (raw): ${response.data}');
    }
    debugPrint('[COMPARE_API] =====================================');

    if (response.data is Map<String, dynamic>) {
      final result = ProfileComparisonResult.fromJson(
        response.data as Map<String, dynamic>,
      );

      // ——— LOG TEMPORAIRE: après mapping Flutter ———
      debugPrint('[COMPARE_API] ---------- APRÈS MAPPING ----------');
      debugPrint('[COMPARE_API] result.score: ${result.score} (calculé backend: présent dans la réponse)');
      debugPrint('[COMPARE_API] result.compatibilityLevel: ${result.compatibilityLevel}');
      debugPrint('[COMPARE_API] result.divergences.length: ${result.divergences.length}');
      for (var i = 0; i < result.divergences.length; i++) {
        final d = result.divergences[i];
        debugPrint('[COMPARE_API]   mapped[$i]: type="${d.type}", label="${d.label}", description="${d.description}"');
      }
      debugPrint('[COMPARE_API] result.recommendations.length: ${result.recommendations.length}');
      for (var i = 0; i < result.recommendations.length; i++) {
        debugPrint('[COMPARE_API]   recommendation[$i]: ${result.recommendations[i]}');
      }
      debugPrint('[COMPARE_API] -------------------------------------');

      return result;
    }

    throw Exception('Réponse invalide');
  }
}
