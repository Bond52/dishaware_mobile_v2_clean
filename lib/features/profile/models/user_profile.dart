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
  final Map<String, dynamic>? algorithmFeatures;
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
    this.algorithmFeatures,
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
    final dataNode =
        (json['data'] is Map<String, dynamic>) ? json['data'] as Map<String, dynamic> : null;
    final root = dataNode ?? json;
    final algo = (root['algorithmFeatures'] is Map<String, dynamic>)
        ? root['algorithmFeatures'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return UserProfile(
      userId: root['userId']?.toString(),
      firstName: (root['firstName'] ?? '') as String,
      lastName: (root['lastName'] ?? '') as String,
      dailyCalories: (root['dailyCalories'] ?? 2000) as int,
      allergies: _stringList(root['allergies'] ?? root['forbiddenIngredients']),
      diets: (root['diets'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      favoriteCuisines: (root['favoriteCuisines'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      favoriteIngredients: (root['favoriteIngredients'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      activityLevel: (root['activityLevel'] ?? '') as String,
      orderFrequency: (root['orderFrequency'] ?? '') as String,
      tasteIntensity: (root['tasteIntensity'] ?? '') as String,
      tasteProfile: (root['tasteProfile'] ?? '') as String,
      texturePreference: (root['texturePreference'] ?? '') as String,
      satietyAfterMeal: (root['satietyAfterMeal'] ?? '') as String,
      diningContext: (root['diningContext'] ?? '') as String,
      explorationAttitude: (root['explorationAttitude'] ?? '') as String,
      profileExplanation: (root['profileExplanation'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      algorithmFeatures: algo.isEmpty ? null : Map<String, dynamic>.from(algo),
      tasteVectorWeights: _doubleMap(
        algo['taste_vector_weights'] ??
            root['taste_vector_weights'] ??
            root['tasteVectorWeights'],
      ),
      preferredCookingMethods: _stringList(
        algo['preferred_cooking_methods'] ??
            root['preferred_cooking_methods'] ??
            root['preferredCookingMethods'],
      ),
      satietyPreference: _doubleOrNull(
        algo['satiety_preference_normalized'] ??
            algo['satiety_preference'] ??
            root['satiety_preference_normalized'] ??
            root['satiety_preference'] ??
            root['satietyPreference'],
      ),
      texturePreferences: _doubleMap(
        algo['texture_preferences'] ??
            root['texture_preferences'] ??
            root['texturePreferences'],
      ),
      hasCompletedOnboarding:
          (root['hasCompletedOnboarding'] ?? false) as bool,
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
      if (algorithmFeatures != null) 'algorithmFeatures': algorithmFeatures,
      'taste_vector_weights': tasteVectorWeights,
      'preferred_cooking_methods': preferredCookingMethods,
      'satiety_preference': satietyPreference,
      'texture_preferences': texturePreferences,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }
}
