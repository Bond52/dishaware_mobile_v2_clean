import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../features/auth/models/user.dart';

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

  /// Heuristique : ne jamais envoyer un JWT comme `x-user-id` (favoris / profil par utilisateur).
  static bool looksLikeJwt(String value) {
    final v = value.trim();
    if (v.length < 20) return false;
    final parts = v.split('.');
    return parts.length == 3 &&
        parts.every((p) => p.isNotEmpty) &&
        !RegExp(r'^[a-f0-9]{24}$', caseSensitive: false).hasMatch(v);
  }

  /// UserId pour `x-user-id` : **priorité à `currentUserId` en prefs** (mis à jour par
  /// [ProfileApiService] après GET /profile/me), puis [User] au login — sans réécraser
  /// les prefs avec l’ancien userId du JSON `currentUser` (sinon restaurants / mockAuth
  /// repassent sur un id non-ObjectId).
  static Future<String> get currentUserId async {
    final prefs = await SharedPreferences.getInstance();
    final fromPrefs = prefs.getString('currentUserId');

    if (fromPrefs != null &&
        fromPrefs.isNotEmpty &&
        !looksLikeJwt(fromPrefs)) {
      return fromPrefs;
    }

    final persisted = await User.loadFromPrefs();
    if (persisted != null && persisted.userId.isNotEmpty) {
      if (looksLikeJwt(persisted.userId)) {
        throw Exception(
          'userId invalide : un jeton a été stocké à la place du userId. '
          'Déconnectez-vous et reconnectez-vous.',
        );
      }
      await prefs.setString('currentUserId', persisted.userId);
      return persisted.userId;
    }

    if (fromPrefs != null && fromPrefs.isNotEmpty) {
      if (looksLikeJwt(fromPrefs)) {
        throw Exception(
          'userId invalide : un jeton a été stocké à la place du userId. '
          'Déconnectez-vous et reconnectez-vous.',
        );
      }
      return fromPrefs;
    }

    throw Exception('Utilisateur non connecté (userId manquant)');
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
