class CompatibleDish {
  final String id;
  final String name;
  final int calories;
  final double score;
  final String imageUrl;
  final List<String> adjustments;

  const CompatibleDish({
    required this.id,
    required this.name,
    required this.calories,
    required this.score,
    required this.imageUrl,
    required this.adjustments,
  });

  factory CompatibleDish.fromJson(Map<String, dynamic> json) {
    final rawCalories = json['calories'] ?? json['kcal'] ?? 0;
    final calories = rawCalories is num
        ? rawCalories.round()
        : int.tryParse(rawCalories.toString()) ?? 0;
    final rawScore = json['score'] ?? json['compatibilityScore'] ?? 0;
    final score = rawScore is num ? rawScore.toDouble() : 0.0;
    return CompatibleDish(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      calories: calories,
      score: score,
      imageUrl: (json['image'] ?? json['imageUrl'] ?? '').toString(),
      adjustments: (json['adjustments'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final double rating;
  final double distanceMeters;
  final String address;
  final bool isPartner;
  final bool isMenuReady;
  final List<CompatibleDish> sureLike;
  final List<CompatibleDish> discover;
  final List<CompatibleDish> adjustments;
  /// Types de cuisine (ex. chinese, indian) — utilisé pour le classement.
  final List<String> cuisines;
  /// Données optionnelles renvoyées par le backend (score, détails…).
  final Map<String, dynamic>? scoreDetails;
  /// Score 0–1 après [applyCompatibilityRanking] ou renseigné par l’API.
  final double? compatibilityScore;
  final String? explanation;

  const Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.distanceMeters,
    required this.address,
    required this.isPartner,
    required this.isMenuReady,
    required this.sureLike,
    required this.discover,
    required this.adjustments,
    this.cuisines = const [],
    this.scoreDetails,
    this.compatibilityScore,
    this.explanation,
  });

  Restaurant copyWith({
    String? id,
    String? name,
    double? rating,
    double? distanceMeters,
    String? address,
    bool? isPartner,
    bool? isMenuReady,
    List<CompatibleDish>? sureLike,
    List<CompatibleDish>? discover,
    List<CompatibleDish>? adjustments,
    List<String>? cuisines,
    Map<String, dynamic>? scoreDetails,
    double? compatibilityScore,
    String? explanation,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      address: address ?? this.address,
      isPartner: isPartner ?? this.isPartner,
      isMenuReady: isMenuReady ?? this.isMenuReady,
      sureLike: sureLike ?? this.sureLike,
      discover: discover ?? this.discover,
      adjustments: adjustments ?? this.adjustments,
      cuisines: cuisines ?? this.cuisines,
      scoreDetails: scoreDetails ?? this.scoreDetails,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      explanation: explanation ?? this.explanation,
    );
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final rawRating = json['rating'] ?? json['score'] ?? 0;
    final rating = rawRating is num ? rawRating.toDouble() : 0.0;

    final distanceRaw =
        json['distanceMeters'] ?? json['distance'] ?? json['distanceKm'] ?? 0;
    double distanceMeters = 0;
    if (distanceRaw is num) {
      distanceMeters =
          json['distanceKm'] != null ? distanceRaw * 1000 : distanceRaw.toDouble();
    } else {
      distanceMeters = double.tryParse(distanceRaw.toString()) ?? 0;
    }

    final isPartner = json['isPartner'] == true ||
        json['partner'] == true ||
        json['dishawarePartner'] == true;

    final menuReady = json['menuReady'] == true ||
        json['hasMenu'] == true ||
        json['menuStatus'] == 'ready';

    final recommendations =
        json['recommendations'] is Map<String, dynamic> ? json['recommendations'] : {};
    final sureLikeList = _parseDishList(
      recommendations['sureLike'] ??
          recommendations['youWillLove'] ??
          recommendations['topPicks'] ??
          [],
    );
    final discoverList = _parseDishList(
      recommendations['discover'] ??
          recommendations['mustTry'] ??
          recommendations['discoverAbsolutely'] ??
          [],
    );
    final adjustmentsList = _parseDishList(
      recommendations['adjustments'] ??
          recommendations['withAdjustments'] ??
          recommendations['adaptable'] ??
          [],
    );

    final address =
        (json['address'] ?? json['location']?['address'] ?? '').toString();

    final cuisinesRaw = json['cuisines'] ??
        json['types'] ??
        json['categories'] ??
        json['cuisineTypes'];
    final List<String> cuisinesList = [];
    if (cuisinesRaw is List) {
      for (final e in cuisinesRaw) {
        final s = e.toString().trim();
        if (s.isNotEmpty) cuisinesList.add(s);
      }
    } else if (cuisinesRaw is String && cuisinesRaw.trim().isNotEmpty) {
      cuisinesList.addAll(
        cuisinesRaw.split(RegExp(r'[,;|]')).map((s) => s.trim()).where((s) => s.isNotEmpty),
      );
    }

    Map<String, dynamic>? scoreDetails;
    final sd = json['scoreDetails'] ?? json['compatibility'];
    if (sd is Map<String, dynamic>) {
      scoreDetails = Map<String, dynamic>.from(sd);
    }

    return Restaurant(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      rating: rating,
      distanceMeters: distanceMeters,
      address: address,
      isPartner: isPartner,
      isMenuReady: menuReady ||
          sureLikeList.isNotEmpty ||
          discoverList.isNotEmpty ||
          adjustmentsList.isNotEmpty,
      sureLike: sureLikeList,
      discover: discoverList,
      adjustments: adjustmentsList,
      cuisines: cuisinesList,
      scoreDetails: scoreDetails,
    );
  }

  int get compatibleCount =>
      sureLike.length + discover.length + adjustments.length;

  static List<CompatibleDish> _parseDishList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(CompatibleDish.fromJson)
          .toList();
    }
    return [];
  }
}
