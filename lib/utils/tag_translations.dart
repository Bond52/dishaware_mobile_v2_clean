/// Traductions des tags Spoonacular pour l'UI uniquement.
/// Les valeurs en base restent en anglais.

const Map<String, String> tagTranslationsFr = {
  // Diets
  "gluten-free": "Sans gluten",
  "dairy-free": "Sans produits laitiers",
  "paleolithic": "Paléo",
  "lacto-ovo-vegetarian": "Lacto-ovo végétarien",
  "primal": "Primal",
  "whole-30": "Whole 30",
  "vegan": "Végan",
  "vegetarian": "Végétarien",

  // Dish types
  "main-course": "Plat principal",
  "side-dish": "Accompagnement",
  "dessert": "Dessert",
  "appetizer": "Entrée",
  "salad": "Salade",
  "soup": "Soupe",
  "snack": "Collation",
  "breakfast": "Petit-déjeuner",

  // Cuisines
  "french": "Française",
  "italian": "Italienne",
  "mexican": "Mexicaine",
  "indian": "Indienne",
  "american": "Américaine",
  "asian": "Asiatique",
  "mediterranean": "Méditerranéenne",

  // Extra éventuels
  "quick": "Rapide",
  "slow-cooked": "Mijoté",
  "healthy": "Sain",
  "light": "Léger",
};

/// Retourne la traduction française du tag si connue, sinon le tag original (anglais).
String translateTag(String tag) {
  if (tag.isEmpty) return tag;
  final normalized = tag.trim().toLowerCase().replaceAll(' ', '-');
  return tagTranslationsFr[normalized] ?? tagTranslationsFr[tag] ?? tag;
}
