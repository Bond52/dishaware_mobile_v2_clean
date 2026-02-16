import '../api/api_client.dart';

class FeedbackService {
  static Future<Map<String, dynamic>> sendScopedFeedback({
    required String dishId,
    required bool liked,
    required String scope, // "dish" | "preparation"
    String? source,
  }) async {
    final response = await ApiClient.dio.post(
      '/feedback',
      data: {
        'dishId': dishId,
        'liked': liked,
        'scope': scope,
        if (source != null) 'source': source,
      },
      options: await ApiClient.optionsWithUserId(),
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {};
  }
}
