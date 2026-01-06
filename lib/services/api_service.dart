import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static Future<http.Response> ping() {
    return http.get(
      Uri.parse('${ApiConfig.baseUrl}/health'),
    );
  }
}
