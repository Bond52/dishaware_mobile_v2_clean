/// Recette renvoyée par `POST /api/dishes/recipe` dans `response.data['recipe']`.
class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String? cookingTime;
  final String? difficulty;
  final String? tips;
  final String? nutritionSummary;
  final int? calories;

  const Recipe({
    this.id = '',
    required this.title,
    this.description = '',
    this.ingredients = const [],
    this.steps = const [],
    this.cookingTime,
    this.difficulty,
    this.tips,
    this.nutritionSummary,
    this.calories,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final root = nested is Map ? Map<String, dynamic>.from(nested) : json;

    return Recipe(
      id: root['id']?.toString() ?? '',
      title: (root['name'] ?? root['title'] ?? root['dishName'] ?? '').toString(),
      description: (root['description'] ?? root['details'] ?? '').toString(),
      ingredients: _parseStringList(root['ingredients']),
      steps: _parseStringList(
        root['steps'] ?? root['instructions'] ?? root['preparationSteps'] ?? root['method'],
      ),
      cookingTime: _stringOrNull(
        root['cookingTime'] ?? root['totalTime'] ?? root['duration'] ?? root['prepTime'],
      ),
      difficulty: _stringOrNull(root['difficulty'] ?? root['level']),
      tips: _stringOrNull(root['tips'] ?? root['chefTips'] ?? root['advice']),
      nutritionSummary: _nutritionToString(root['nutrition']),
      calories: _intOrNull(root['calories'] ?? root['estimatedCalories'] ?? root['kcal']),
    );
  }

  static String? _stringOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _intOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.round();
    return int.tryParse(v.toString());
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return [];
    if (raw is String) {
      final t = raw.trim();
      return t.isEmpty ? [] : [t];
    }
    if (raw is! List) return [];
    final out = <String>[];
    for (final e in raw) {
      if (e == null) continue;
      if (e is String) {
        final s = e.trim();
        if (s.isNotEmpty) out.add(s);
        continue;
      }
      if (e is Map) {
        final m = Map<String, dynamic>.from(e);
        final text = (m['text'] ?? m['name'] ?? m['ingredient'] ?? m['step'] ?? m['description'])
            ?.toString()
            .trim();
        if (text != null && text.isNotEmpty) out.add(text);
      }
    }
    return out;
  }

  static String? _nutritionToString(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final s = raw.trim();
      return s.isEmpty ? null : s;
    }
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      final parts = <String>[];
      void add(String label, dynamic key) {
        final v = m[key];
        if (v == null) return;
        parts.add('$label: $v');
      }
      add('Calories', 'calories');
      add('Protéines', 'protein');
      add('Glucides', 'carbs');
      add('Lipides', 'fat');
      add('Fibres', 'fiber');
      if (parts.isEmpty) return m.toString();
      return parts.join(' · ');
    }
    return raw.toString();
  }
}
