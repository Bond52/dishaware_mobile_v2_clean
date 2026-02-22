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
    required this.hasCompletedOnboarding,
  });

  static List<String> _stringList(dynamic v) {
    if (v == null) return [];
    if (v is! List) return [];
    return v.map((e) => e.toString()).toList();
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
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }
}
