import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:4000/api", // backend local (Android Emulator)
      // baseUrl: "https://dishaware-backend.onrender.com/api", // backend Render (désactivé)
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

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
}
