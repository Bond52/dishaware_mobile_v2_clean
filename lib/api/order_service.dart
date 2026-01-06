import 'package:dio/dio.dart';

class OrderService {
  final Dio _dio = Dio(
    BaseOptions(
                // baseUrl: "http://10.0.2.2:4000/api", // backend local
     baseUrl: "https://dishaware-backend.onrender.com/api",
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
