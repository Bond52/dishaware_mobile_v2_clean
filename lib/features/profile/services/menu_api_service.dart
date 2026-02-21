import '../../../api/api_client.dart';
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
    if (data is Map<String, dynamic>) {
      return ConsensusMenu.fromJson(data);
    }
    if (data is Map && data['menu'] != null && data['menu'] is Map) {
      return ConsensusMenu.fromJson(
        Map<String, dynamic>.from(data['menu'] as Map),
      );
    }
    throw Exception('Réponse menu consensus invalide');
  }
}
