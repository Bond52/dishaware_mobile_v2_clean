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
    Map<String, dynamic> toParse = const {};
    if (data is Map<String, dynamic>) {
      debugPrint('[MENU_CONSENSUS] Clés reçues: ${(data as Map).keys.toList()}');
      toParse = data;
    } else if (data is Map && data['menu'] != null && data['menu'] is Map) {
      toParse = Map<String, dynamic>.from(data['menu'] as Map);
      debugPrint('[MENU_CONSENSUS] Clés dans menu: ${toParse.keys.toList()}');
    } else {
      throw Exception('Réponse menu consensus invalide');
    }
    final menu = ConsensusMenu.fromJson(toParse);
    debugPrint('[MENU_CONSENSUS] Mappé: starter=${menu.starter.isEmpty ? "vide" : "ok"}, main=${menu.main.isEmpty ? "vide" : "ok"}, dessert=${menu.dessert.isEmpty ? "vide" : "ok"}, explanation=${menu.explanation.isEmpty ? "vide" : "ok"}');
    return menu;
  }

  /// Génère un menu consensus pour un groupe. POST /menu/consensus/group
  /// Body: { "profileIds": [...] }
  /// Réponse attendue: { "menu": {...}, "explanation": "...", "adjustments": [...] }
  static Future<GroupMenuResult> generateGroupConsensusMenu(
    List<String> profileIds,
  ) async {
    final response = await ApiClient.dio.post(
      '/menu/consensus/group',
      data: {'profileIds': profileIds},
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
