import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/menu_recipe_detail.dart';

/// Cache local optionnel pour éviter de rappeler l’API à chaque ouverture.
class MenuRecipeCache {
  static const _prefsKeyPrefix = 'menu_recipe_detail_v1|';

  static String _keyForDishName(String dishName) {
    final n = dishName.trim().toLowerCase();
    if (n.length <= 120) return '$_prefsKeyPrefix$n';
    return '$_prefsKeyPrefix${n.hashCode.abs()}';
  }

  static Future<MenuRecipeDetail?> load(String dishName) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForDishName(dishName));
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final forName = map['_forName']?.toString() ?? '';
      if (forName.trim().toLowerCase() != dishName.trim().toLowerCase()) {
        return null;
      }
      final data = map['detail'];
      if (data is! Map) return null;
      return MenuRecipeDetail.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(String dishName, MenuRecipeDetail detail) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      '_forName': dishName.trim(),
      'detail': detail.toJson(),
    });
    await prefs.setString(_keyForDishName(dishName), payload);
  }
}
