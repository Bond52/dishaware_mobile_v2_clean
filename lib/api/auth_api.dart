import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthApi {
  /// 🔐 LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return Map<String, dynamic>.from(e.response!.data);
      }
      return {
        'success': false,
        'message': 'Erreur réseau ou serveur injoignable',
      };
    }
  }

  /// 📝 REGISTER (backend plus tard)
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return Map<String, dynamic>.from(e.response!.data);
      }
      return {
        'success': false,
        'message': 'Erreur réseau ou serveur injoignable',
      };
    }
  }
}
