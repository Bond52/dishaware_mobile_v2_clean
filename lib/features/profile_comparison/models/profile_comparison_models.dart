class ComparisonUser {
  final String firstName;
  final String fullName;
  final String initials;
  final List<String> allergiesLabels;
  final List<String> dietsLabels;
  final List<String> favoriteCuisinesLabels;
  final List<String> favoriteIngredientsLabels;

  const ComparisonUser({
    required this.firstName,
    this.fullName = '',
    required this.initials,
    this.allergiesLabels = const [],
    this.dietsLabels = const [],
    this.favoriteCuisinesLabels = const [],
    this.favoriteIngredientsLabels = const [],
  });

  factory ComparisonUser.fromJson(Map<String, dynamic> json) {
    return ComparisonUser(
      firstName: (json['firstName'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      initials: (json['initials'] ?? '').toString(),
      allergiesLabels: _stringListFromJson(json['allergiesLabels']),
      dietsLabels: _stringListFromJson(json['dietsLabels']),
      favoriteCuisinesLabels: _stringListFromJson(json['favoriteCuisinesLabels']),
      favoriteIngredientsLabels: _stringListFromJson(json['favoriteIngredientsLabels']),
    );
  }

  static List<String> _stringListFromJson(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'fullName': fullName,
        'initials': initials,
        'allergiesLabels': allergiesLabels,
        'dietsLabels': dietsLabels,
        'favoriteCuisinesLabels': favoriteCuisinesLabels,
        'favoriteIngredientsLabels': favoriteIngredientsLabels,
      };
}

class BreakdownScores {
  final double safety;
  final double diet;
  final double taste;
  final double behavior;
  final double flexibility;

  const BreakdownScores({
    required this.safety,
    required this.diet,
    required this.taste,
    required this.behavior,
    required this.flexibility,
  });

  factory BreakdownScores.fromJson(Map<String, dynamic> json) {
    return BreakdownScores(
      safety: (json['safety'] ?? 0).toDouble(),
      diet: (json['diet'] ?? 0).toDouble(),
      taste: (json['taste'] ?? 0).toDouble(),
      behavior: (json['behavior'] ?? 0).toDouble(),
      flexibility: (json['flexibility'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'safety': safety,
        'diet': diet,
        'taste': taste,
        'behavior': behavior,
        'flexibility': flexibility,
      };
}

class Breakdown {
  final BreakdownScores raw;
  final BreakdownScores weighted;

  const Breakdown({
    required this.raw,
    required this.weighted,
  });

  factory Breakdown.fromJson(Map<String, dynamic> json) {
    return Breakdown(
      raw: BreakdownScores.fromJson(
        (json['raw'] as Map<String, dynamic>? ?? const {}),
      ),
      weighted: BreakdownScores.fromJson(
        (json['weighted'] as Map<String, dynamic>? ?? const {}),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'raw': raw.toJson(),
        'weighted': weighted.toJson(),
      };
}

class Divergence {
  final String type;
  final String label;
  final String description;

  const Divergence({
    required this.type,
    required this.label,
    required this.description,
  });

  factory Divergence.fromJson(Map<String, dynamic> json) {
    return Divergence(
      type: (json['type'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'label': label,
        'description': description,
      };
}

class ProfileComparisonResult {
  final double score;
  final String compatibilityLevel;
  final ComparisonUser userA;
  final ComparisonUser userB;
  final Breakdown breakdown;
  final List<Divergence> divergences;
  final List<String> recommendations;

  const ProfileComparisonResult({
    required this.score,
    required this.compatibilityLevel,
    required this.userA,
    required this.userB,
    required this.breakdown,
    required this.divergences,
    required this.recommendations,
  });

  factory ProfileComparisonResult.fromJson(Map<String, dynamic> json) {
    final users = (json['users'] as Map<String, dynamic>? ?? const {});
    return ProfileComparisonResult(
      score: (json['score'] ?? 0).toDouble(),
      compatibilityLevel: (json['compatibilityLevel'] ?? '').toString(),
      userA: ComparisonUser.fromJson(
        (users['A'] as Map<String, dynamic>? ?? const {}),
      ),
      userB: ComparisonUser.fromJson(
        (users['B'] as Map<String, dynamic>? ?? const {}),
      ),
      breakdown: Breakdown.fromJson(
        (json['breakdown'] as Map<String, dynamic>? ?? const {}),
      ),
      divergences: (json['divergences'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(Divergence.fromJson)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'compatibilityLevel': compatibilityLevel,
        'users': {
          'A': userA.toJson(),
          'B': userB.toJson(),
        },
        'breakdown': breakdown.toJson(),
        'divergences': divergences.map((e) => e.toJson()).toList(),
        'recommendations': recommendations,
      };
}
