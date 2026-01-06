import 'package:flutter/material.dart';
import '../models/dish_suggestion.dart';
import '../api/recipe_service.dart';
import '../api/order_service.dart';

class DishDetailScreen extends StatefulWidget {
  final String recipeId;

  // 🔑 CONTEXTE IMPORTANT
  final bool fromOrder;            // vient de l’historique ?
  final bool? existingFeedback;    // feedback déjà donné ?

  const DishDetailScreen({
    super.key,
    required this.recipeId,
    this.fromOrder = false,
    this.existingFeedback,
  });

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  final RecipeService _recipeService = RecipeService();
  final OrderService _orderService = OrderService();

  DishSuggestion? _dish;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isOrdering = false;

  // ⭐ Feedback
  bool? _liked;
  bool _sendingFeedback = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.existingFeedback; // 👈 récupération feedback existant
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    try {
      // 🧪 MOCK LOCAL
      if (widget.recipeId.startsWith('mock-')) {
        await Future.delayed(const Duration(milliseconds: 300));
        _dish = _mockRecipe(widget.recipeId);
        _isLoading = false;
        setState(() {});
        return;
      }

      // 🌐 API réelle
      final result =
          await _recipeService.getRecipeById(widget.recipeId);

      if (!mounted) return;

      setState(() {
        _dish = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Erreur chargement recette : $e");

      if (!mounted) return;

      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // 🧪 Mock local
  DishSuggestion _mockRecipe(String id) {
    if (id == 'mock-1') {
      return DishSuggestion(
        id: 'mock-1',
        name: "Sandwich asiatique au poulet",
        description: "Poulet grillé, légumes croquants, sauce soja",
        calories: 490,
        cuisine: "Asiatique",
        dishType: "Sandwich",
        ingredients: [
          "Pain",
          "Poulet",
          "Carottes",
          "Concombre",
          "Sauce soja",
        ],
        imageUrl: "",
      );
    }

    return DishSuggestion(
      id: 'mock-2',
      name: "Bowl africain végétarien",
      description:
          "Riz, pois chiches, légumes rôtis, sauce épicée douce",
      calories: 450,
      cuisine: "Africaine",
      dishType: "Bowl",
      ingredients: [
        "Riz",
        "Pois chiches",
        "Courgettes",
        "Poivrons",
        "Épices africaines",
      ],
      imageUrl: "",
    );
  }

  // 🛒 Commander
  Future<void> _orderDish() async {
    if (_dish == null || _isOrdering) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Commander ce dîner"),
        content: Text(
          "Souhaitez-vous commander « ${_dish!.name} » ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isOrdering = true);

    try {
      await _orderService.createOrder(
        recipeId: _dish!.id,
        userId: "user-1",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Commande créée avec succès"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isOrdering = false);
      }
    }
  }

  // 👍 👎 Feedback (mock)
  Future<void> _sendFeedback(bool liked) async {
    if (_sendingFeedback) return;

    setState(() => _sendingFeedback = true);

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() {
      _liked = liked;
      _sendingFeedback = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          liked ? "👍 Merci pour votre avis !" : "👎 Avis enregistré",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail du plat"),
      ),
      body: _buildBody(),
      bottomNavigationBar:
          _dish == null ? null : _buildOrderButton(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _dish == null) {
      return const Center(
        child: Text("Recette introuvable."),
      );
    }

    final dish = _dish!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dish.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(dish.description),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(dish.cuisine)),
              Chip(label: Text(dish.dishType)),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            "Ingrédients",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          ...dish.ingredients.map((i) => Text("• $i")),

          const SizedBox(height: 24),

          Text(
            "${dish.calories} kcal",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          // ⭐ FEEDBACK — UNIQUEMENT SI COMMANDE
          if (widget.fromOrder) ...[
            const SizedBox(height: 32),
            const Text(
              "Votre avis sur ce plat",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            if (_liked == null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sendingFeedback
                          ? null
                          : () => _sendFeedback(true),
                      icon: const Icon(Icons.thumb_up),
                      label: const Text("J’aime"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sendingFeedback
                          ? null
                          : () => _sendFeedback(false),
                      icon: const Icon(Icons.thumb_down),
                      label: const Text("J’aime pas"),
                    ),
                  ),
                ],
              )
            else
              Text(
                _liked!
                    ? "👍 Vous avez aimé ce plat"
                    : "👎 Vous n’avez pas aimé ce plat",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: _isOrdering ? null : _orderDish,
          child: _isOrdering
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Commander ce dîner"),
        ),
      ),
    );
  }
}
