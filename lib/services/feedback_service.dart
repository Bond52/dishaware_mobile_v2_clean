import 'package:dio/dio.dart';
import '../api/api_client.dart';

class FeedbackService {
  static const String _mockUserId = '64b7f9c2f5c1f2b3a4c5d6e7';

  static Options _options() {
    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'x-user-id': _mockUserId,
      },
    );
  }

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
      options: _options(),
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {};
  }
}
