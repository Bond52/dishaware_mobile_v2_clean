class DishFeedback {
  final String recipeId;
  final String userId;
  final bool liked; // true = 👍 / false = 👎

  DishFeedback({
    required this.recipeId,
    required this.userId,
    required this.liked,
  });

  Map<String, dynamic> toJson() {
    return {
      "recipeId": recipeId,
      "userId": userId,
      "liked": liked,
    };
  }
}
