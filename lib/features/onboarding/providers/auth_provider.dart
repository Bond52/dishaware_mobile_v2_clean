import 'package:flutter/foundation.dart';

enum AuthMethod { google, apple, email }

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated;
  AuthMethod? _authMethod;
  bool _hasCompletedOnboarding;

  AuthProvider({
    bool isAuthenticated = false,
    bool hasCompletedOnboarding = false,
  })  : _isAuthenticated = isAuthenticated,
        _hasCompletedOnboarding = hasCompletedOnboarding;

  bool get isAuthenticated => _isAuthenticated;
  AuthMethod? get authMethod => _authMethod;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  void setAuthMethod(AuthMethod method) {
    _authMethod = method;
    notifyListeners();
  }

  void authenticate(AuthMethod method) {
    // TODO: Remplacer par la vraie logique d'authentification.
    _authMethod = method;
    _isAuthenticated = true;
    notifyListeners();
  }

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  void setHasCompletedOnboarding(bool value) {
    _hasCompletedOnboarding = value;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _authMethod = null;
    _hasCompletedOnboarding = false;
    notifyListeners();
  }
}
