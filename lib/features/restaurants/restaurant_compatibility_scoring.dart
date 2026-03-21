import '../profile/models/user_profile.dart';
import 'models/restaurant.dart';

/// Normalise pour comparaisons (cuisines / préférences).
String normalizePreferenceToken(String s) =>
    s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

/// Quelques équivalences FR ↔ libellés API courants.
String? _canonicalCuisineKey(String raw) {
  final n = normalizePreferenceToken(raw);
  const map = <String, String>{
    'indienne': 'indian',
    'indian': 'indian',
    'india': 'indian',
    'mexicaine': 'mexican',
    'mexican': 'mexican',
    'mexique': 'mexican',
    'italienne': 'italian',
    'italian': 'italian',
    'italie': 'italian',
    'japonaise': 'japanese',
    'japanese': 'japanese',
    'japon': 'japanese',
    'chinoise': 'chinese',
    'chinese': 'chinese',
    'chine': 'chinese',
    'asiatique': 'asian',
    'asian': 'asian',
    'française': 'french',
    'french': 'french',
    'france': 'french',
    'américaine': 'american',
    'american': 'american',
    'méditerranéenne': 'mediterranean',
    'mediterranean': 'mediterranean',
    'thaïlandaise': 'thai',
    'thai': 'thai',
    'libanaise': 'lebanese',
    'lebanese': 'lebanese',
    'coréenne': 'korean',
    'korean': 'korean',
    'vietnamienne': 'vietnamese',
    'vietnamese': 'vietnamese',
  };
  return map[n] ?? n;
}

/// Tags / préférences utilisateur pour le matching (cuisines, régimes, goûts).
List<String> buildUserPreferenceTags(UserProfile? profile) {
  if (profile == null) return [];
  final keys = <String>{};
  void add(String? s) {
    if (s == null || s.isEmpty) return;
    final n = normalizePreferenceToken(s);
    keys.add(n);
    final c = _canonicalCuisineKey(s);
    if (c != null) keys.add(c);
  }

  for (final c in profile.favoriteCuisines) {
    add(c);
  }
  for (final d in profile.diets) {
    add(d);
  }
  for (final i in profile.favoriteIngredients) {
    add(i);
  }
  add(profile.tasteProfile);
  add(profile.texturePreference);
  if (profile.explorationAttitude.isNotEmpty) {
    add(profile.explorationAttitude);
  }
  return keys.toList();
}

/// Développe les cuisines du restaurant en clés comparables.
List<String> _restaurantCuisineKeys(Restaurant r) {
  return r.cuisines.map((c) => _canonicalCuisineKey(c) ?? normalizePreferenceToken(c)).toList();
}

double? _backendCompatibilityScore(Map<String, dynamic>? scoreDetails) {
  if (scoreDetails == null) return null;
  final v = scoreDetails['compatibilityScore'] ??
      scoreDetails['overallScore'] ??
      scoreDetails['score'];
  if (v is num) return v.toDouble().clamp(0.0, 1.0);
  return null;
}

/// Score 0–1 : cuisines, note, distance (mètres).
double computeRestaurantScore(Restaurant r, List<String> userPrefs) {
  final backend = _backendCompatibilityScore(r.scoreDetails);
  if (backend != null) return backend;

  final userNorm = userPrefs.map(normalizePreferenceToken).toSet();
  final userCanon = userPrefs.map((p) => _canonicalCuisineKey(p) ?? normalizePreferenceToken(p)).toSet();

  if (r.cuisines.isEmpty) {
    return 0.2;
  }

  final rKeys = _restaurantCuisineKeys(r);
  int matches = 0;
  for (final c in rKeys) {
    final cn = normalizePreferenceToken(c);
    if (userNorm.contains(cn) || userCanon.contains(cn)) {
      matches++;
      continue;
    }
    for (final u in userNorm) {
      if (u.length >= 3 && (cn.contains(u) || u.contains(cn))) {
        matches++;
        break;
      }
    }
  }

  double score = 0;
  score += matches * 0.4;
  score += (r.rating.clamp(0, 5) / 5.0) * 0.2;
  final d = r.distanceMeters.clamp(0.0, 2000.0);
  score += (1.0 - (d / 2000.0)) * 0.2;

  return score.clamp(0.0, 1.0);
}

String buildExplanation(Restaurant r, List<String> userPrefs) {
  if (r.cuisines.isEmpty) {
    return 'Informations limitées sur ce restaurant';
  }

  final rKeys = _restaurantCuisineKeys(r);
  final userNorm = userPrefs.map(normalizePreferenceToken).toList();
  final userCanon = userPrefs
      .map((p) => _canonicalCuisineKey(p) ?? normalizePreferenceToken(p))
      .toList();

  String? firstMatchedLabel;
  for (var i = 0; i < r.cuisines.length; i++) {
    final label = r.cuisines[i];
    final key = i < rKeys.length ? rKeys[i] : normalizePreferenceToken(label);
    final kn = normalizePreferenceToken(key);
    if (userNorm.contains(kn) ||
        userCanon.contains(kn) ||
        userNorm.any((u) => u.length >= 3 && (kn.contains(u) || u.contains(kn)))) {
      firstMatchedLabel = label;
      break;
    }
  }

  if (firstMatchedLabel != null && firstMatchedLabel.isNotEmpty) {
    return 'Ce restaurant correspond à votre préférence pour la cuisine $firstMatchedLabel';
  }
  return 'Basé sur votre profil et votre localisation';
}

/// Applique scores + explications et trie par compatibilité décroissante.
List<Restaurant> applyCompatibilityRanking(
  List<Restaurant> restaurants,
  UserProfile? profile,
) {
  final userPrefs = buildUserPreferenceTags(profile);
  final scored = restaurants.map((r) {
    final score = computeRestaurantScore(r, userPrefs);
    final expl = buildExplanation(r, userPrefs);
    return r.copyWith(
      compatibilityScore: score,
      explanation: expl,
    );
  }).toList()
    ..sort((a, b) => (b.compatibilityScore ?? 0).compareTo(a.compatibilityScore ?? 0));
  return scored;
}
