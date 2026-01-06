class DishSuggestion {
  final String id;
  final String name;
  final int calories;
  final String cuisine;
  final String dishType;
  final String description;
  final List<String> ingredients;
  final String imageUrl;

  DishSuggestion({
    required this.id,
    required this.name,
    required this.calories,
    required this.cuisine,
    required this.dishType,
    required this.description,
    required this.ingredients,
    required this.imageUrl,
  });

  factory DishSuggestion.fromJson(Map<String, dynamic> json) {
    return DishSuggestion(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      cuisine: json['cuisine'],
      dishType: json['dishType'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      imageUrl: json['imageUrl'],
    );
  }
}
