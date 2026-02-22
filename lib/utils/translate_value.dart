/// Traduit les valeurs (allergies, régimes, cuisines) en français pour l'affichage.
String translateValue(String value) {
  if (value.trim().isEmpty) return value;
  switch (value.toLowerCase().trim()) {
    case 'peanut':
    case 'peanuts':
      return 'Arachide';
    case 'tree nut':
    case 'tree nuts':
    case 'nuts':
      return 'Fruits à coque';
    case 'vegan':
      return 'Végane';
    case 'vegetarian':
    case 'lacto ovo vegetarian':
      return 'Végétarien';
    case 'italian':
      return 'Italienne';
    case 'mediterranean':
    case 'european':
      return 'Méditerranéenne';
    case 'chinese':
      return 'Chinoise';
    case 'asian':
      return 'Asiatique';
    case 'gluten':
    case 'gluten free':
      return value.toLowerCase().contains('free') ? 'Sans gluten' : 'Gluten';
    case 'dairy':
    case 'lactose':
      return 'Lactose';
    case 'shellfish':
      return 'Crustacés';
    case 'fish':
      return 'Poisson';
    case 'egg':
    case 'eggs':
      return 'Œuf';
    case 'soy':
      return 'Soja';
    case 'sesame':
      return 'Sésame';
    default:
      return value;
  }
}
