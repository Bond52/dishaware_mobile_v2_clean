import 'package:dio/dio.dart';
import '../../../api/api_client.dart';
import '../domain/ai_menu.dart';

class AiMenuService {
  static const String _mockUserId = '64b7f9c2f5c1f2b3a4c5d6e7';

  static Options _options() {
    return Options(
      headers: {
        ...ApiClient.dio.options.headers,
        'x-user-id': _mockUserId,
      },
    );
  }

  static Future<AiMenu> generateMenu() async {
    final response = await ApiClient.dio.post(
      '/menus/generate',
      options: _options(),
    );

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final menuData = data['menu'] is Map<String, dynamic> ? data['menu'] : data;
      return AiMenu.fromJson(menuData as Map<String, dynamic>);
    }

    return const AiMenu(entree: null, plat: null, dessert: null);
  }
}
