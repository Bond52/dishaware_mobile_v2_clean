class ConsensusMenu {
  final String starter;
  final String main;
  final String alternative;
  final String dessert;
  final String explanation;
  final String adjustmentA;
  final String adjustmentB;

  const ConsensusMenu({
    required this.starter,
    required this.main,
    required this.alternative,
    required this.dessert,
    required this.explanation,
    required this.adjustmentA,
    required this.adjustmentB,
  });

  factory ConsensusMenu.fromJson(Map<String, dynamic> json) {
    final map = _flattenMenuJson(json);
    return ConsensusMenu(
      starter: _str(map, ['starter', 'entree', 'entrée', 'start', 'firstCourse', 'first_course']),
      main: _str(map, ['main', 'plat', 'platPrincipal', 'plat_principal', 'mainCourse', 'main_course', 'principal']),
      alternative: _str(map, ['alternative', 'alternatif', 'option', 'optionnel']),
      dessert: _str(map, ['dessert', 'desserts']),
      explanation: _str(map, ['explanation', 'explication']),
      adjustmentA: _str(map, ['adjustmentA', 'ajustementA', 'adjustment_a']),
      adjustmentB: _str(map, ['adjustmentB', 'ajustementB', 'adjustment_b']),
    );
  }

  static String _str(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
    }
    return '';
  }

  /// Fusionne la racine avec menu/dishes/courses/result pour accepter plusieurs formats API.
  static Map<String, dynamic> _flattenMenuJson(Map<String, dynamic> json) {
    final out = Map<String, dynamic>.from(json);
    for (final key in ['menu', 'dishes', 'courses', 'result', 'consensus', 'data']) {
      final nested = json[key];
      if (nested is Map<String, dynamic>) {
        for (final e in nested.entries) {
          if (e.value != null && (e.value is! String || (e.value as String).trim().isNotEmpty)) {
            out[e.key] ??= e.value;
          }
        }
      }
    }
    // Format tableau: dishes: [{ type: "starter", name: "..." }, ...]
    final list = json['dishes'] ?? json['courses'] ?? json['items'];
    if (list is List) {
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final type = (item['type'] ?? item['course'] ?? item['category'] ?? '').toString().toLowerCase();
        final name = (item['name'] ?? item['label'] ?? item['title'] ?? item['dish'] ?? '').toString().trim();
        if (name.isEmpty) continue;
        if (type.contains('entree') || type.contains('starter') || type == 'entrée') {
          out['starter'] ??= name;
        } else if (type.contains('main') || type.contains('plat') || type.contains('principal')) {
          out['main'] ??= name;
        } else if (type.contains('alt') || type.contains('option')) {
          out['alternative'] ??= name;
        } else if (type.contains('dessert')) {
          out['dessert'] ??= name;
        }
      }
    }
    return out;
  }
}
