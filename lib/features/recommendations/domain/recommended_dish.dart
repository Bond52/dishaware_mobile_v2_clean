class RecommendedDish {
  final String dishId;
  final String name;
  final String imageUrl;
  final int calories;
  final double score;
  final List<String> explanation;
  final List<String> cuisines;
  final List<String> diets;
  final List<String> ingredients;
  final List<String> ingredientsPreview;

  const RecommendedDish({
    required this.dishId,
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.score,
    required this.explanation,
    required this.cuisines,
    required this.diets,
    required this.ingredients,
    required this.ingredientsPreview,
  });

  factory RecommendedDish.fromJson(Map<String, dynamic> json) {
    final rawScore = json['score'] ?? 0;
    final score = rawScore is num ? rawScore.toDouble() : 0.0;
    final rawCalories = json['calories'] ?? 0;
    final calories = rawCalories is num
        ? rawCalories.round()
        : int.tryParse(rawCalories.toString()) ?? 0;

    return RecommendedDish(
      dishId: (json['dishId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      imageUrl: (json['image'] ?? '').toString(),
      calories: calories,
      score: score,
      explanation: (json['explanation'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      cuisines: (json['cuisines'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      diets: (json['diets'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      ingredientsPreview: (json['ingredientsPreview'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
