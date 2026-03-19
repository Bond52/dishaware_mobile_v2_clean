import 'package:flutter/foundation.dart';

import '../../../api/api_client.dart';
import '../../../ui/components/menu_debug_prompt_section.dart';
import '../domain/ai_menu.dart';

/// Développe l'enveloppe `{ "data": { ... } }` si le vrai menu est dedans.
Map<String, dynamic> _unwrapMenuGenerateBody(dynamic raw) {
  if (raw is! Map) return {};
  var m = Map<String, dynamic>.from(raw);

  bool looksLikeMenuPayload(Map<String, dynamic> x) {
    return x.containsKey('entree') ||
        x.containsKey('entry') ||
        x.containsKey('starter') ||
        x.containsKey('plat') ||
        x.containsKey('main') ||
        x.containsKey('dessert') ||
        x.containsKey('menu') ||
        x.containsKey('debugPrompt') ||
        x.containsKey('debug_prompt') ||
        x.containsKey('prompt');
  }

  final data = m['data'];
  if (data is Map) {
    final dataMap = Map<String, dynamic>.from(data);
    if (!looksLikeMenuPayload(m) && looksLikeMenuPayload(dataMap)) {
      m = dataMap;
    }
  }

  final result = m['result'];
  if (result is Map) {
    final resultMap = Map<String, dynamic>.from(result);
    if (!looksLikeMenuPayload(m) && looksLikeMenuPayload(resultMap)) {
      m = resultMap;
    }
  }

  return m;
}

class AiMenuService {
  static Future<AiMenu> generateMenu() async {
    final response = await ApiClient.dio.post(
      '/menus/generate',
      options: await ApiClient.optionsWithUserId(),
    );

    if (kDebugMode) {
      // ignore: avoid_print
      print('=== MENU API RESPONSE ===');
      // ignore: avoid_print
      print(response.data);
    }

    // Dio peut renvoyer Map<dynamic, dynamic> : éviter `is Map<String, dynamic>`.
    if (response.data is Map) {
      final rawMap = Map<String, dynamic>.from(response.data as Map);
      final data = _unwrapMenuGenerateBody(response.data);
      final menu = AiMenu.fromJson(data);
      // Prompt parfois sur l'enveloppe (hors `data`) — fusionner avec le corps déballé.
      final fromEnvelope = parseMenuDebugPrompt(rawMap);
      final merged = (menu.debugPrompt != null && menu.debugPrompt!.trim().isNotEmpty)
          ? menu.debugPrompt
          : fromEnvelope;
      final resolved = merged != null && merged.trim().isNotEmpty
          ? AiMenu(
              entree: menu.entree,
              plat: menu.plat,
              dessert: menu.dessert,
              totalEstimatedCalories: menu.totalEstimatedCalories,
              debugPrompt: merged.trim(),
            )
          : menu;

      if (kDebugMode) {
        // ignore: avoid_print
        print('SERVICE resolved.debugPrompt: ${resolved.debugPrompt}');
        if (resolved.debugPrompt == null || resolved.debugPrompt!.trim().isEmpty) {
          debugPrint(
            '[MENU_GENERATE] Aucun debugPrompt parsé. '
            'Clés enveloppe: ${rawMap.keys.toList()} | clés payload: ${data.keys.toList()}',
          );
        }
      }
      return resolved;
    }

    return const AiMenu(entree: null, plat: null, dessert: null);
  }
}
