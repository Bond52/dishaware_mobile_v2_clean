import 'package:flutter/foundation.dart';

import '../models/user.dart';

/// Utilisateur connecté (persisté + état global).
class UserProvider extends ChangeNotifier {
  User? _user;

  User? get currentUser => _user;

  UserProvider({User? initialUser}) : _user = initialUser;

  /// Charge l'utilisateur depuis SharedPreferences (au démarrage).
  static Future<User?> loadFromPrefs() => User.loadFromPrefs();

  /// Après login : persiste et met à jour l'état.
  Future<void> setUser(User user) async {
    await User.persist(user);
    _user = user;
    notifyListeners();
  }

  /// Au logout : supprime la persistance et l'état.
  Future<void> clearUser() async {
    await User.clearFromPrefs();
    _user = null;
    notifyListeners();
  }
}
