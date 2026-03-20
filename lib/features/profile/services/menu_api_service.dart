import 'package:flutter/foundation.dart';
import '../../../api/api_client.dart';
import '../../../screens/host_mode_models.dart';
import '../models/consensus_menu.dart';

class MenuApiService {
  /// Génère un menu consensus à partir des données de comparaison.
  /// POST /menus/consensus avec body { "comparisonData": comparisonData }
  static Future<ConsensusMenu> generateConsensusMenu(
    Map<String, dynamic> comparisonData,
  ) async {
    final response = await ApiClient.dio.post(
      '/menus/consensus',
      data: {'comparisonData': comparisonData},
      options: await ApiClient.optionsWithUserId(),
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Réponse menu consensus invalide');
    }
    debugPrint('[MENU_CONSENSUS] Clés reçues: ${data.keys.toList()}');
    // Corps complet pour conserver debugPrompt à la racine + fusion menu via fromJson.
    final menu = ConsensusMenu.fromJson(Map<String, dynamic>.from(data));
    debugPrint('[MENU_CONSENSUS] Mappé: starter=${menu.starter.isEmpty ? "vide" : "ok"}, main=${menu.main.isEmpty ? "vide" : "ok"}, dessert=${menu.dessert.isEmpty ? "vide" : "ok"}, explanation=${menu.explanation.isEmpty ? "vide" : "ok"}');
    return menu;
  }

  /// Génère un menu pour un groupe.
  /// POST `/menu/generate-group`
  /// Body: `{ "profileIds": [...], "ingredients": [...] }`.
  /// `profileIds` = identifiants des documents **UserProfile** (Mongo `_id` / `profileId` en priorité,
  /// sinon `userId` si c’est ce que le serveur résout — hôte + invités, au moins 2 entrées).
  /// Réponse attendue: { "menu": {...}, "explanation": "...", "adjustments": [...] }
  static Future<GroupMenuResult> generateGroupConsensusMenu(
    List<String> profileIds, {
    List<String> ingredients = const [],
  }) async {
    debugPrint(
      '[MENU_GROUP] POST /menu/generate-group — envoi: profileIds=$profileIds '
      '(count=${profileIds.length}), ingredients count=${ingredients.length}',
    );
    final response = await ApiClient.dio.post(
      '/menu/generate-group',
      data: {
        'profileIds': profileIds,
        'ingredients': ingredients,
      },
      options: await ApiClient.optionsWithUserId(),
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Réponse menu groupe invalide');
    }
    debugPrint('[MENU_GROUP] Clés: ${data.keys.toList()}');
    return GroupMenuResult.fromJson(data);
  }
}
