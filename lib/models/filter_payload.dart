class FiltersPayload {
  final int maxCalories;
  final List<String> cuisines;
  final List<String> dishTypes;
  final List<String> excludedAllergens;

  FiltersPayload({
    required this.maxCalories,
    required this.cuisines,
    required this.dishTypes,
    required this.excludedAllergens,
  });

  Map<String, dynamic> toJson() {
    return {
      "maxCalories": maxCalories,
      "cuisines": cuisines,
      "dishTypes": dishTypes,
      "excludedAllergens": excludedAllergens,
    };
  }
}
