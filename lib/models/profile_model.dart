class ProfileModel {
  final String name;
  final int caloriesMax;

  final List<String> allergies;
  final List<String> forbiddenIngredients;
  final List<String> cuisines;
  final List<String> dishes;

  ProfileModel({
    required this.name,
    required this.caloriesMax,
    required this.allergies,
    required this.forbiddenIngredients,
    required this.cuisines,
    required this.dishes,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? 'Utilisateur',
      caloriesMax: json['caloriesMax'] ?? 0,
      allergies: List<String>.from(json['allergies'] ?? []),
      forbiddenIngredients:
          List<String>.from(json['forbiddenIngredients'] ?? []),
      cuisines: List<String>.from(json['cuisines'] ?? []),
      dishes: List<String>.from(json['dishes'] ?? []),
    );
  }
}
