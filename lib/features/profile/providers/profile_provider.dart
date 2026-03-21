import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../router_refresh.dart';
import '../models/user_profile.dart';
import '../services/profile_api_service.dart';

class ProfileProvider extends ChangeNotifier {
  /// Dernière valeur persistée de [UserProfile.hasCompletedOnboarding] (session précédente).
  /// Sert au routeur quand le profil ne peut pas être rechargé (404, mauvais x-user-id) :
  /// on renvoie vers /welcome au lieu du questionnaire 16 étapes.
  static const String kPrefsProfileOnboardingComplete =
      'profile_onboarding_complete';

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;
  /// Mis à jour depuis les prefs au début de chaque chargement + après succès API.
  bool _lastKnownOnboardingComplete = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// True si l’utilisateur avait terminé l’onboarding lors du dernier chargement réussi (prefs).
  bool get lastKnownOnboardingComplete => _lastKnownOnboardingComplete;

  ProfileProvider() {
    loadMyProfile();
  }

  Future<void> loadMyProfile() async {
    print('PROFILE LOADING...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _lastKnownOnboardingComplete =
          prefs.getBool(kPrefsProfileOnboardingComplete) ?? false;

      _profile = await ProfileApiService.getMyProfile();
      if (_profile == null) {
        _error = 'Profil non trouvé';
      } else {
        _error = null;
        await prefs.setBool(
          kPrefsProfileOnboardingComplete,
          _profile!.hasCompletedOnboarding,
        );
        _lastKnownOnboardingComplete = _profile!.hasCompletedOnboarding;
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
    _lastKnownOnboardingComplete = profile.hasCompletedOnboarding;
    notifyListeners();
    RouterRefresh.instance.refresh();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(
        kPrefsProfileOnboardingComplete,
        profile.hasCompletedOnboarding,
      );
    });
  }

  /// Au logout : vide le profil en mémoire pour que le routeur ne considère plus l'utilisateur comme connecté.
  Future<void> clearProfile() async {
    _profile = null;
    _error = null;
    _lastKnownOnboardingComplete = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(kPrefsProfileOnboardingComplete);
    } catch (_) {}
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
