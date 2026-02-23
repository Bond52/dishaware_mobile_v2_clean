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

  /// 📧 Inscription sans mot de passe (prénom + nom)
  static Future<Map<String, dynamic>> registerWithEmail({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/email/register',
        data: {
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
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

  /// 📧 Connexion sans mot de passe (prénom + nom)
  static Future<Map<String, dynamic>> loginWithEmail({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/email/login',
        data: {
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {'success': false, 'notFound': true};
      }
      if (e.response?.data != null) {
        return Map<String, dynamic>.from(e.response!.data);
      }
      return {
        'success': false,
        'message': 'Erreur réseau ou serveur injoignable',
      };
    }
  }

  /// 🔐 GOOGLE AUTH — échange idToken Firebase contre JWT backend
  static Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/google',
        data: {'idToken': idToken},
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return Map<String, dynamic>.from(e.response!.data);
      }
      rethrow;
    }
  }
}
