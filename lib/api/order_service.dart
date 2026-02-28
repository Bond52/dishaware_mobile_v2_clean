import 'package:dio/dio.dart';

import '../config/api_config.dart';

class OrderService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  /// ➕ POST /orders
  Future<void> createOrder({
    required String recipeId,
    required String userId,
  }) async {
    await _dio.post(
      '/orders',
      data: {
        "recipeId": recipeId,
        "userId": userId,
      },
    );
  }

  /// 📄 GET /orders (optionnel : filtre par userId)
  Future<List<Map<String, dynamic>>> getOrders({
    String? userId,
  }) async {
    final response = await _dio.get(
      '/orders',
      queryParameters: userId != null
          ? {
              "userId": userId,
            }
          : null,
    );

    // Sécurité typage
    final data = response.data as List<dynamic>;

    return data.cast<Map<String, dynamic>>();
  }
}
