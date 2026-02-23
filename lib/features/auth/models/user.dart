import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Utilisateur connecté (persisté après login).
/// user.userId = profile.userId en base (ex. 64b7f9c2f5c1f2b3a4c5d6e7), envoyé en x-user-id.
class User {
  final String userId;
  final String firstName;
  final String lastName;
  final String? name;

  const User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.name,
  });

  String get displayName {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return n;
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty && l.isEmpty) return 'Utilisateur';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '$f $l';
  }

  /// Prénom pour le greeting "Bonjour, Steve"
  String get greetingName => firstName.trim().isEmpty ? 'Utilisateur' : firstName.trim();

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        if (name != null) 'name': name,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: (json['userId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      firstName: (json['firstName'] ?? json['first_name'] ?? '').toString(),
      lastName: (json['lastName'] ?? json['last_name'] ?? '').toString(),
      name: (json['name'] as String?)?.trim(),
    );
  }

  /// Extrait l'objet user depuis une réponse login (user.userId = profile.userId en base).
  static User? fromLoginResponse(Map<String, dynamic> result) {
    if (result['user'] is Map<String, dynamic>) {
      return User.fromJson(Map<String, dynamic>.from(result['user'] as Map));
    }
    final userId = result['userId'] ?? result['id'];
    final firstName = result['firstName'] ?? result['first_name'];
    final lastName = result['lastName'] ?? result['last_name'];
    final name = result['name']?.toString().trim();
    if (userId == null || userId.toString().isEmpty) return null;
    return User(
      userId: userId.toString(),
      firstName: (firstName ?? '').toString(),
      lastName: (lastName ?? '').toString(),
      name: (name != null && name.isNotEmpty) ? name : null,
    );
  }

  static const String _keyCurrentUser = 'currentUser';

  static Future<void> persist(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentUser, jsonEncode(user.toJson()));
    await prefs.setString('currentUserId', user.userId);
  }

  static Future<User?> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyCurrentUser);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUser);
    await prefs.remove('currentUserId');
  }
}
