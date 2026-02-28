import 'package:flutter/foundation.dart';
import '../models/onboarding_data.dart';

class OnboardingProvider extends ChangeNotifier {
  static const int totalSteps = 16;

  int _currentStep = 1;
  OnboardingData _data = const OnboardingData();

  int get currentStep => _currentStep;
  double get progress => _currentStep / totalSteps;
  OnboardingData get data => _data;

  bool get canGoBack => _currentStep > 1;
  bool get canSkipCurrentStep => _currentStep >= 2 && _currentStep <= 15;

  void nextStep() {
    if (_currentStep < totalSteps) {
      _currentStep += 1;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep -= 1;
      notifyListeners();
    }
  }

  void skipStep() {
    if (canSkipCurrentStep) {
      nextStep();
    }
  }

  void updateFirstName(String value) {
    _data = _data.copyWith(firstName: value.trim());
    notifyListeners();
  }

  void updateLastName(String value) {
    _data = _data.copyWith(lastName: value.trim());
    notifyListeners();
  }

  /// Préremplit prénom/nom si vides (ex. après inscription) pour éviter la double saisie.
  void setNamesIfEmpty(String firstName, String lastName) {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty && l.isEmpty) return;
    bool changed = false;
    if (_data.firstName.isEmpty && f.isNotEmpty) {
      _data = _data.copyWith(firstName: f);
      changed = true;
    }
    if (_data.lastName.isEmpty && l.isNotEmpty) {
      _data = _data.copyWith(lastName: l);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  /// Après inscription : on a déjà le nom sur l'écran "Créer un compte", donc on saute l'étape 1.
  void skipStep1IfNamesFilled() {
    if (_currentStep == 1 &&
        _data.firstName.trim().isNotEmpty &&
        _data.lastName.trim().isNotEmpty) {
      _currentStep = 2;
      notifyListeners();
    }
  }

  void updateDailyCalories(int value) {
    _data = _data.copyWith(dailyCalories: value);
    notifyListeners();
  }

  void toggleAllergy(String allergy) {
    final updated = List<String>.from(_data.allergies);
    if (updated.contains(allergy)) {
      updated.remove(allergy);
    } else {
      updated.add(allergy);
    }
    _data = _data.copyWith(allergies: updated);
    notifyListeners();
  }

  void toggleDietaryPreference(String value) {
    final updated = List<String>.from(_data.dietaryPreferences);
    if (updated.contains(value)) {
      updated.remove(value);
    } else {
      updated.add(value);
    }
    _data = _data.copyWith(dietaryPreferences: updated);
    notifyListeners();
  }

  void toggleCuisinePreference(String value) {
    final updated = List<String>.from(_data.cuisinePreferences);
    if (updated.contains(value)) {
      updated.remove(value);
    } else {
      updated.add(value);
    }
    _data = _data.copyWith(cuisinePreferences: updated);
    notifyListeners();
  }

  void addFavoriteIngredient(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final updated = List<String>.from(_data.favoriteIngredients);
    if (!updated.contains(trimmed)) {
      updated.add(trimmed);
      _data = _data.copyWith(favoriteIngredients: updated);
      notifyListeners();
    }
  }

  void removeFavoriteIngredient(String value) {
    final updated = List<String>.from(_data.favoriteIngredients)
      ..remove(value);
    _data = _data.copyWith(favoriteIngredients: updated);
    notifyListeners();
  }

  void setActivityLevel(String value) {
    _data = _data.copyWith(activityLevel: value);
    notifyListeners();
  }

  void setOrderFrequency(String value) {
    _data = _data.copyWith(orderFrequency: value);
    notifyListeners();
  }

  void setTasteIntensity(String value) {
    _data = _data.copyWith(tasteIntensity: value);
    notifyListeners();
  }

  void setTasteProfile(String value) {
    _data = _data.copyWith(tasteProfile: value);
    notifyListeners();
  }

  void setTexturePreference(String value) {
    _data = _data.copyWith(texturePreference: value);
    notifyListeners();
  }

  void setSatietyAfterMeal(String value) {
    _data = _data.copyWith(satietyAfterMeal: value);
    notifyListeners();
  }

  void setDiningContext(String value) {
    _data = _data.copyWith(diningContext: value);
    notifyListeners();
  }

  void setExplorationAttitude(String value) {
    _data = _data.copyWith(explorationAttitude: value);
    notifyListeners();
  }

  void reset() {
    _currentStep = 1;
    _data = const OnboardingData();
    notifyListeners();
  }
}
