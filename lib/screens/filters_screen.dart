import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/filter_payload.dart';        // ✅ sans s
import '../data/mock_user_profile.dart';
import '../providers/filters_provider.dart';   // ✅ Provider

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  double _maxCalories = 500;

  // 🔹 Données de référence
  final List<String> _availableCuisines = [
    "Africaine",
    "Asiatique",
    "Européenne",
    "Méditerranéenne",
    "Américaine",
  ];

  final List<String> _availableDishTypes = [
    "Salade",
    "Pâtes",
    "Sandwich",
    "Bowl",
    "Pizza",
    "Plat chaud",
  ];

  // 🔹 État sélectionné
  final Set<String> _selectedCuisines = {};
  final Set<String> _selectedDishTypes = {};

  void _submitFilters() {
    final payload = FiltersPayload(
      maxCalories: _maxCalories.round(),
      cuisines: _selectedCuisines.toList(),
      dishTypes: _selectedDishTypes.toList(),
      excludedAllergens: userAllergens,
    );

    // ✅ Enregistrement GLOBAL dans le Provider
    context.read<FiltersProvider>().setFilters(payload);

    debugPrint("Filtres enregistrés dans le Provider : ${payload.toJson()}");

    // ✅ Navigation vers SuggestionsScreen
    context.go('/suggestions');
  }

  // 🔹 Widget générique pour les chips
  Widget _buildFilterChips({
    required List<String> items,
    required Set<String> selectedItems,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return FilterChip(
          label: Text(item),
          selected: selectedItems.contains(item),
          onSelected: (isSelected) {
            setState(() {
              isSelected
                  ? selectedItems.add(item)
                  : selectedItems.remove(item);
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choisir mon dîner")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔸 Calories
            const Text(
              "Calories maximum",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _maxCalories,
              min: 300,
              max: 800,
              divisions: 20,
              label: "${_maxCalories.round()} kcal",
              onChanged: (value) {
                setState(() => _maxCalories = value);
              },
            ),
            Text("≤ ${_maxCalories.round()} kcal"),

            const SizedBox(height: 24),

            // 🔸 Cuisine
            const Text(
              "Type de cuisine",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFilterChips(
              items: _availableCuisines,
              selectedItems: _selectedCuisines,
            ),

            const SizedBox(height: 24),

            // 🔸 Type de plat
            const Text(
              "Type de plat",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFilterChips(
              items: _availableDishTypes,
              selectedItems: _selectedDishTypes,
            ),

            const SizedBox(height: 24),

            // 🔸 Allergies (lecture seule)
            const Text(
              "Allergènes exclus",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...userAllergens.map((a) => Text("🚫 $a")),

            const SizedBox(height: 32),

            // 🔸 CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitFilters,
                child: const Text("Me proposer un dîner"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
