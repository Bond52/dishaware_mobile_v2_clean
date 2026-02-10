import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../features/profile_comparison/models/profile_comparison_models.dart';

class ProfileComparisonService {
  static const String _mockUserId = '64b7f9c2f5c1f2b3a4c5d6e7';
  static String get currentUserId => _mockUserId;

  static Options _options() {
    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'x-user-id': _mockUserId,
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
          options: _options(),
        )
        .timeout(const Duration(seconds: 12));

    if (response.data is Map<String, dynamic>) {
      return ProfileComparisonResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    throw Exception('Réponse invalide');
  }
}
