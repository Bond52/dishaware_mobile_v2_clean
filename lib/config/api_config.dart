/// Configuration centralisée de l'URL du backend.
class ApiConfig {
  /// Basculer à `false` pour repasser en production Render.
  static const bool useLocalhost = true;

  // 🔴 Production (Render)
  static const String renderBaseUrl = "https://dishaware-backend.onrender.com";

  // 🟢 Local testing
  // Android Emulator
  static const String localhostAndroid = "http://10.0.2.2:4000";
  // iOS Simulator / Web
  static const String localhostIos = "http://localhost:4000";
  // Appareil physique (adapter avec l'IP de votre machine)
  // static const String localhostDevice = "http://192.168.x.x:4000";

  // URL active
  static const String baseUrl = useLocalhost ? localhostAndroid : renderBaseUrl;
  // static const String baseUrl = "https://dishaware-backend.onrender.com";

  /// Base URL avec préfixe /api pour les clients Dio (profile, dishes, explorer, etc.)
  static String get apiBaseUrl => "$baseUrl/api";
}
