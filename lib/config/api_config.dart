/// Configuration centralisée de l'URL du backend.
/// Pour repasser en local : commenter [baseUrl] production et décommenter une ligne localhost.
class ApiConfig {
  // Backend local (Android Emulator)
  // static const String baseUrl = "http://10.0.2.2:4000";
  // Backend local (browser / iOS Simulator)
  // static const String baseUrl = "http://localhost:4000";

  static const String baseUrl = "https://dishaware-backend.onrender.com";

  /// Base URL avec préfixe /api pour les clients Dio (profile, dishes, explorer, etc.)
  static String get apiBaseUrl => "$baseUrl/api";
}
