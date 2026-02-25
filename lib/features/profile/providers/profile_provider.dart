import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../router_refresh.dart';
import '../models/user_profile.dart';
import '../services/profile_api_service.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProfileProvider() {
    loadMyProfile();
  }

  Future<void> loadMyProfile() async {
    print('PROFILE LOADING...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await ProfileApiService.getMyProfile();
      if (_profile == null) {
        _error = 'Profil non trouvé';
      } else {
        _error = null;
      }
      print('PROFILE LOADED: ${_profile?.hasCompletedOnboarding}');
    } catch (e) {
      if (e is DioException) {
        debugPrint(
          'PROFILE LOAD ERROR: ${e.response?.statusCode} ${e.message} ${e.response?.data}',
        );
        if (e.response?.statusCode == 404) {
          _error = 'Profil non trouvé';
        } else {
          _error = 'Impossible de charger le profil. Réessayez.';
        }
      } else {
        debugPrint('PROFILE LOAD ERROR: $e');
        _error = 'Impossible de charger le profil. Réessayez.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      RouterRefresh.instance.refresh();
    }
  }

  void setProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
    RouterRefresh.instance.refresh();
  }

  /// Au logout : vide le profil en mémoire pour que le routeur ne considère plus l'utilisateur comme connecté.
  void clearProfile() {
    _profile = null;
    _error = null;
    notifyListeners();
    RouterRefresh.instance.refresh();
  }

  Future<UserProfile?> updateProfile(Map<String, dynamic> payload) async {
    try {
      await ProfileApiService.updateProfile(payload);
      await loadMyProfile();
      return _profile;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
