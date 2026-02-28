import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// Intercepteur pour logger les requêtes/réponses API (visible dans la console en debug).
class _ApiLogInterceptor extends Interceptor {
  static const int _maxBodyLength = 800;

  static String _truncate(dynamic body) {
    if (body == null) return 'null';
    final s = body.toString();
    return s.length <= _maxBodyLength ? s : '${s.substring(0, _maxBodyLength)}...';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[API] → ${options.method} ${options.uri}');
    if (options.data != null) {
      debugPrint('[API]   body: ${_truncate(options.data)}');
    }
    if (options.queryParameters.isNotEmpty) {
      debugPrint('[API]   query: ${options.queryParameters}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[API] ← ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('[API]   response: ${_truncate(response.data)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[API] ✗ ERROR ${err.requestOptions.method} ${err.requestOptions.uri}');
    debugPrint('[API]   ${err.type} ${err.message}');
    if (err.response != null) {
      debugPrint('[API]   status: ${err.response?.statusCode}');
      debugPrint('[API]   body: ${_truncate(err.response?.data)}');
    }
    handler.next(err);
  }
}

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      // baseUrl: "http://10.0.2.2:4000/api", // backend local (Android Emulator)
      baseUrl: ApiConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  )..interceptors.add(_ApiLogInterceptor());

  /// 🔐 Charge le token depuis SharedPreferences et l'injecte dans Dio
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token != null) {
      dio.options.headers["Authorization"] = "Bearer $token";
      print("TOKEN INJECTÉ DANS DIO = $token");
    } else {
      dio.options.headers.remove("Authorization");
      print("AUCUN TOKEN AU DEMARRAGE");
    }
  }

  /// 🔥 Utilisé après login
  static void setToken(String token) {
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  /// 🔓 Utilisé au logout
  static void clearToken() {
    dio.options.headers.remove("Authorization");
  }

  /// Retourne le userId courant (persisté après login, header x-user-id).
  static Future<String> get currentUserId async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('currentUserId');
    if (userId == null || userId.isEmpty) {
      throw Exception('Utilisateur non connecté (userId manquant)');
    }
    return userId;
  }

  /// Options Dio avec l’en-tête x-user-id du profil connecté (pour favoris, recommandations, etc.).
  static Future<Options> optionsWithUserId() async {
    final userId = await currentUserId;
    return Options(
      headers: {
        ...dio.options.headers,
        'x-user-id': userId,
      },
    );
  }
}
