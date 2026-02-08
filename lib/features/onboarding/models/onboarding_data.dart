class OnboardingData {
  final String firstName;
  final String lastName;
  final int dailyCalories;
  final List<String> allergies;
  final List<String> dietaryPreferences;
  final List<String> cuisinePreferences;
  final List<String> favoriteIngredients;
  final String activityLevel;
  final String orderFrequency;
  final String tasteIntensity;
  final String tasteProfile;
  final String texturePreference;
  final String satietyAfterMeal;
  final String diningContext;
  final String explorationAttitude;

  const OnboardingData({
    this.firstName = '',
    this.lastName = '',
    this.dailyCalories = 2000,
    this.allergies = const [],
    this.dietaryPreferences = const [],
    this.cuisinePreferences = const [],
    this.favoriteIngredients = const [],
    this.activityLevel = '',
    this.orderFrequency = '',
    this.tasteIntensity = '',
    this.tasteProfile = '',
    this.texturePreference = '',
    this.satietyAfterMeal = '',
    this.diningContext = '',
    this.explorationAttitude = '',
  });

  OnboardingData copyWith({
    String? firstName,
    String? lastName,
    int? dailyCalories,
    List<String>? allergies,
    List<String>? dietaryPreferences,
    List<String>? cuisinePreferences,
    List<String>? favoriteIngredients,
    String? activityLevel,
    String? orderFrequency,
    String? tasteIntensity,
    String? tasteProfile,
    String? texturePreference,
    String? satietyAfterMeal,
    String? diningContext,
    String? explorationAttitude,
  }) {
    return OnboardingData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      allergies: allergies ?? this.allergies,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      cuisinePreferences: cuisinePreferences ?? this.cuisinePreferences,
      favoriteIngredients: favoriteIngredients ?? this.favoriteIngredients,
      activityLevel: activityLevel ?? this.activityLevel,
      orderFrequency: orderFrequency ?? this.orderFrequency,
      tasteIntensity: tasteIntensity ?? this.tasteIntensity,
      tasteProfile: tasteProfile ?? this.tasteProfile,
      texturePreference: texturePreference ?? this.texturePreference,
      satietyAfterMeal: satietyAfterMeal ?? this.satietyAfterMeal,
      diningContext: diningContext ?? this.diningContext,
      explorationAttitude: explorationAttitude ?? this.explorationAttitude,
    );
  }
}
