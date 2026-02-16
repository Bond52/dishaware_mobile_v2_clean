import 'package:dio/dio.dart';
import '../../../api/api_client.dart';
import '../domain/ai_menu.dart';

class AiMenuService {
  static Future<AiMenu> generateMenu() async {
    final response = await ApiClient.dio.post(
      '/menus/generate',
      options: await ApiClient.optionsWithUserId(),
    );

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final menuData = data['menu'] is Map<String, dynamic> ? data['menu'] : data;
      return AiMenu.fromJson(menuData as Map<String, dynamic>);
    }

    return const AiMenu(entree: null, plat: null, dessert: null);
  }
}
