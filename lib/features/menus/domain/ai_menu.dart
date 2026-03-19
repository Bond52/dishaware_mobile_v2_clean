import '../../../ui/components/menu_debug_prompt_section.dart';

class AiMenuItem {
  final String label;
  final String name;
  final String description;
  final int calories;

  const AiMenuItem({
    required this.label,
    required this.name,
    required this.description,
    required this.calories,
  });

  factory AiMenuItem.fromJson(Map<String, dynamic> json, String label) {
    final rawCalories = json['estimatedCalories'] ?? json['calories'] ?? json['kcal'] ?? 0;
    final calories = rawCalories is num
        ? rawCalories.round()
        : int.tryParse(rawCalories.toString()) ?? 0;
    return AiMenuItem(
      label: label,
      name: (json['name'] ?? json['title'] ?? '').toString(),
      description: (json['description'] ?? json['details'] ?? '').toString(),
      calories: calories,
    );
  }
}

class AiMenu {
  final AiMenuItem? entree;
  final AiMenuItem? plat;
  final AiMenuItem? dessert;
  final int? totalEstimatedCalories;
  final String? debugPrompt;

  const AiMenu({
    required this.entree,
    required this.plat,
    required this.dessert,
    this.totalEstimatedCalories,
    this.debugPrompt,
  });

  factory AiMenu.fromJson(Map<String, dynamic> json) {
    final fromRoot = parseMenuDebugPrompt(json);

    final menuRoot = json['menu'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['menu'] as Map)
        : Map<String, dynamic>.from(json);

    final innerMenu = menuRoot['menu'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(menuRoot['menu'] as Map)
        : menuRoot;

    final fromMenuRoot = parseMenuDebugPrompt(menuRoot);
    final fromInner = parseMenuDebugPrompt(innerMenu);

    final entreeJson =
        innerMenu['entree'] ?? innerMenu['entry'] ?? innerMenu['starter'];
    final platJson = innerMenu['plat'] ??
        innerMenu['main'] ??
        innerMenu['mainCourse'];
    final dessertJson = innerMenu['dessert'];
    final totalCalories = (menuRoot['totalEstimatedCalories'] ??
            menuRoot['totalCalories'] ??
            json['totalEstimatedCalories']) ??
        0;
    final parsedTotal = totalCalories is num
        ? totalCalories.round()
        : int.tryParse(totalCalories.toString());

    return AiMenu(
      entree: entreeJson is Map<String, dynamic>
          ? AiMenuItem.fromJson(entreeJson, 'ENTRÉE')
          : null,
      plat: platJson is Map<String, dynamic>
          ? AiMenuItem.fromJson(platJson, 'PLAT')
          : null,
      dessert: dessertJson is Map<String, dynamic>
          ? AiMenuItem.fromJson(dessertJson, 'DESSERT')
          : null,
      totalEstimatedCalories: parsedTotal,
      debugPrompt: fromRoot ?? fromMenuRoot ?? fromInner,
    );
  }

  int get totalCalories =>
      totalEstimatedCalories ??
      (entree?.calories ?? 0) + (plat?.calories ?? 0) + (dessert?.calories ?? 0);
}
