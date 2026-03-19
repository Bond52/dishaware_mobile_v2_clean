class UserProfile {
  /// Id du document profil en base (MongoDB _id). Utilisé pour les APIs qui attendent un profileId.
  final String? id;
  final String? userId;
  final String firstName;
  final String lastName;
  final int dailyCalories;
  final List<String> allergies;
  final List<String> diets;
  final List<String> favoriteCuisines;
  final List<String> favoriteIngredients;
  final String activityLevel;
  final String orderFrequency;
  final String tasteIntensity;
  final String tasteProfile;
  final String texturePreference;
  final String satietyAfterMeal;
  final String diningContext;
  final String explorationAttitude;
  final List<String> profileExplanation;
  final Map<String, double> tasteVectorWeights;
  final List<String> preferredCookingMethods;
  final double? satietyPreference;
  final Map<String, double> texturePreferences;
  final bool hasCompletedOnboarding;

  const UserProfile({
    this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.dailyCalories,
    required this.allergies,
    required this.diets,
    required this.favoriteCuisines,
    required this.favoriteIngredients,
    required this.activityLevel,
    required this.orderFrequency,
    required this.tasteIntensity,
    required this.tasteProfile,
    required this.texturePreference,
    required this.satietyAfterMeal,
    required this.diningContext,
    required this.explorationAttitude,
    required this.profileExplanation,
    required this.tasteVectorWeights,
    required this.preferredCookingMethods,
    required this.satietyPreference,
    required this.texturePreferences,
    required this.hasCompletedOnboarding,
  });

  static List<String> _stringList(dynamic v) {
    if (v == null) return [];
    if (v is! List) return [];
    return v.map((e) => e.toString()).toList();
  }

  static Map<String, double> _doubleMap(dynamic v) {
    if (v is! Map) return {};
    final out = <String, double>{};
    v.forEach((key, value) {
      if (value is num) {
        out[key.toString()] = value.toDouble();
      } else {
        final parsed = double.tryParse(value.toString());
        if (parsed != null) out[key.toString()] = parsed;
      }
    });
    return out;
  }

  static double? _doubleOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId']?.toString(),
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      dailyCalories: (json['dailyCalories'] ?? 2000) as int,
      allergies: _stringList(json['allergies'] ?? json['forbiddenIngredients']),
      diets: (json['diets'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      favoriteCuisines: (json['favoriteCuisines'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      favoriteIngredients: (json['favoriteIngredients'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      activityLevel: (json['activityLevel'] ?? '') as String,
      orderFrequency: (json['orderFrequency'] ?? '') as String,
      tasteIntensity: (json['tasteIntensity'] ?? '') as String,
      tasteProfile: (json['tasteProfile'] ?? '') as String,
      texturePreference: (json['texturePreference'] ?? '') as String,
      satietyAfterMeal: (json['satietyAfterMeal'] ?? '') as String,
      diningContext: (json['diningContext'] ?? '') as String,
      explorationAttitude: (json['explorationAttitude'] ?? '') as String,
      profileExplanation: (json['profileExplanation'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      tasteVectorWeights: _doubleMap(
        json['taste_vector_weights'] ?? json['tasteVectorWeights'],
      ),
      preferredCookingMethods: _stringList(
        json['preferred_cooking_methods'] ?? json['preferredCookingMethods'],
      ),
      satietyPreference: _doubleOrNull(
        json['satiety_preference'] ?? json['satietyPreference'],
      ),
      texturePreferences: _doubleMap(
        json['texture_preferences'] ?? json['texturePreferences'],
      ),
      hasCompletedOnboarding:
          (json['hasCompletedOnboarding'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (userId != null) 'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'dailyCalories': dailyCalories,
      'allergies': allergies,
      'diets': diets,
      'favoriteCuisines': favoriteCuisines,
      'favoriteIngredients': favoriteIngredients,
      'activityLevel': activityLevel,
      'orderFrequency': orderFrequency,
      'tasteIntensity': tasteIntensity,
      'tasteProfile': tasteProfile,
      'texturePreference': texturePreference,
      'satietyAfterMeal': satietyAfterMeal,
      'diningContext': diningContext,
      'explorationAttitude': explorationAttitude,
      'profileExplanation': profileExplanation,
      'taste_vector_weights': tasteVectorWeights,
      'preferred_cooking_methods': preferredCookingMethods,
      'satiety_preference': satietyPreference,
      'texture_preferences': texturePreferences,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }
}
