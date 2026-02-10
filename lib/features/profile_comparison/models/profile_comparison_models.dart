class ComparisonUser {
  final String firstName;
  final String initials;

  const ComparisonUser({
    required this.firstName,
    required this.initials,
  });

  factory ComparisonUser.fromJson(Map<String, dynamic> json) {
    return ComparisonUser(
      firstName: (json['firstName'] ?? '').toString(),
      initials: (json['initials'] ?? '').toString(),
    );
  }
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
}
