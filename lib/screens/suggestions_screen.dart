import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/filter_payload.dart';
import '../providers/filters_provider.dart';
import '../models/dish_suggestion.dart';
import 'dish_detail_screen.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  bool _isLoading = true;
  List<DishSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final filters = context.read<FiltersProvider>().filters;

    if (filters == null) {
      setState(() => _isLoading = false);
      return;
    }

    // ⏳ Simulation délai IA
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // 🧪 MOCK IA TEMPORAIRE (IDs alignés avec backend)
    setState(() {
      _suggestions = [
        DishSuggestion(
          id: 'mock-1',
          name: "Sandwich asiatique au poulet",
          calories: 490,
          cuisine: "Asiatique",
          dishType: "Sandwich",
          description:
              "Poulet grillé, légumes croquants et sauce soja légère",
          ingredients: [
            "Pain",
            "Poulet",
            "Carottes",
            "Concombre",
            "Sauce soja",
          ],
          imageUrl: "",
        ),
        DishSuggestion(
          id: 'mock-2',
          name: "Bowl africain végétarien",
          calories: 450,
          cuisine: "Africaine",
          dishType: "Bowl",
          description:
              "Riz, pois chiches, légumes rôtis et sauce épicée douce",
          ingredients: [
            "Riz",
            "Pois chiches",
            "Courgettes",
            "Poivrons",
            "Épices africaines",
          ],
          imageUrl: "",
        ),
      ];

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = context.watch<FiltersProvider>().filters;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Suggestions de plats"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading ? _buildLoading() : _buildContent(filters),
      ),
    );
  }

  // 🔄 État loading
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            "Analyse de vos préférences alimentaires…",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // 📋 Contenu après chargement
  Widget _buildContent(FiltersPayload? filters) {
    if (filters == null) {
      return const Center(
        child: Text("Aucun filtre disponible."),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filtres appliqués",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text("Calories max : ${filters.maxCalories} kcal"),
          Text("Cuisine : ${filters.cuisines.join(', ')}"),
          Text("Type de plat : ${filters.dishTypes.join(', ')}"),
          Text(
            "Allergènes exclus : ${filters.excludedAllergens.join(', ')}",
          ),
          const SizedBox(height: 32),
          const Text(
            "Suggestions IA",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_suggestions.isEmpty)
            const Center(
              child: Text(
                "Aucune suggestion trouvée.",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ..._suggestions.map(_buildSuggestionCard),
        ],
      ),
    );
  }

  // 🍽️ Carte cliquable → détail du plat
  Widget _buildSuggestionCard(DishSuggestion dish) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          debugPrint("➡️ Ouverture recette ID = ${dish.id}");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DishDetailScreen(
                recipeId: dish.id,
              ),
            ),
          );
        },
        child: ListTile(
          title: Text(dish.name),
          subtitle: Text(dish.description),
          trailing: Text("${dish.calories} kcal"),
        ),
      ),
    );
  }
}
