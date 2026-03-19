import 'package:flutter/material.dart';

import '../../../theme/da_colors.dart';
import '../data/menu_recipe_api_service.dart';
import '../models/recipe.dart';

/// Fiche recette : `POST /dishes/recipe` avec nom + description du menu IA.
class RecipeDetailsPage extends StatefulWidget {
  final String dishName;
  /// Description du plat (corps requête + aperçu si erreur).
  final String description;
  final int? previewCalories;

  const RecipeDetailsPage({
    super.key,
    required this.dishName,
    required this.description,
    this.previewCalories,
  });

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  Recipe? _recipe;
  bool _loading = true;
  bool _error = false;
  bool _fromMemoryCache = false;

  static const _accent = Color(0xFF7C6FE3);
  static const _accentSoft = Color(0xFFF1F0FF);

  @override
  void initState() {
    super.initState();
    _load(bypassCache: false);
  }

  Future<void> _load({required bool bypassCache}) async {
    setState(() {
      _loading = true;
      _error = false;
      _fromMemoryCache = false;
    });

    try {
      final (recipe, fromCache) = await MenuRecipeApiService.fetchRecipe(
        widget.dishName,
        widget.description,
        bypassCache: bypassCache,
      );
      if (!mounted) return;
      setState(() {
        _recipe = recipe;
        _loading = false;
        _fromMemoryCache = fromCache;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  String get _menuPreviewText => widget.description.trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dishName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _accent),
            SizedBox(height: 16),
            Text(
              'Chargement de la recette…',
              style: TextStyle(color: DAColors.mutedForeground, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu, size: 56, color: DAColors.mutedForeground.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'Impossible de charger la recette',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: DAColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vérifiez votre connexion ou réessayez plus tard.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: DAColors.mutedForeground, height: 1.35),
              ),
              if (_menuPreviewText.isNotEmpty) ...[
                const SizedBox(height: 20),
                _previewFromMenuCard(),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _load(bypassCache: false),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5FD3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final r = _recipe!;
    final title = r.title.trim().isNotEmpty ? r.title : widget.dishName;

    return RefreshIndicator(
      color: _accent,
      onRefresh: () => _load(bypassCache: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (_fromMemoryCache)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: _accentSoft,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.speed, size: 20, color: _accent.withValues(alpha: 0.9)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Recette en cache — tirez pour actualiser.',
                          style: TextStyle(fontSize: 13, color: DAColors.foreground.withValues(alpha: 0.85)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          _sectionTitle(Icons.title, 'Titre'),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: DAColors.foreground,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle(Icons.description_outlined, 'Description'),
          const SizedBox(height: 8),
          Text(
            r.description.trim().isNotEmpty
                ? r.description
                : (_menuPreviewText.isNotEmpty ? _menuPreviewText : 'Aucune description fournie.'),
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle(Icons.shopping_basket_outlined, 'Ingrédients'),
          const SizedBox(height: 8),
          _ingredientsCard(r.ingredients),
          const SizedBox(height: 20),
          _sectionTitle(Icons.format_list_numbered, 'Étapes'),
          const SizedBox(height: 8),
          _stepsCard(r.steps),
          const SizedBox(height: 20),
          _sectionTitle(Icons.timer_outlined, 'Temps & difficulté'),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.schedule,
            label: 'Temps',
            value: r.cookingTime ?? '—',
          ),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.trending_up,
            label: 'Difficulté',
            value: r.difficulty ?? '—',
          ),
          const SizedBox(height: 20),
          _sectionTitle(Icons.lightbulb_outline, 'Conseils'),
          const SizedBox(height: 8),
          _mutedCard(
            child: Text(
              r.tips?.trim().isNotEmpty == true ? r.tips! : 'Aucun conseil pour ce plat.',
              style: const TextStyle(fontSize: 14, height: 1.45, color: DAColors.foreground),
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle(Icons.pie_chart_outline, 'Nutrition'),
          const SizedBox(height: 8),
          _mutedCard(
            child: Text(
              _nutritionText(r),
              style: const TextStyle(fontSize: 14, height: 1.45, color: DAColors.foreground),
            ),
          ),
        ],
      ),
    );
  }

  String _nutritionText(Recipe r) {
    final parts = <String>[];
    final kcal = r.calories ?? widget.previewCalories;
    if (kcal != null) parts.add('$kcal kcal (estimé)');
    if (r.nutritionSummary != null && r.nutritionSummary!.trim().isNotEmpty) {
      parts.add(r.nutritionSummary!.trim());
    }
    if (parts.isEmpty) return 'Non renseigné.';
    return parts.join('\n');
  }

  Widget _previewFromMenuCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DAColors.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DAColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aperçu (menu)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: DAColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _menuPreviewText,
            style: const TextStyle(fontSize: 14, height: 1.4, color: DAColors.foreground),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 22, color: _accent),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: DAColors.foreground,
          ),
        ),
      ],
    );
  }

  Widget _ingredientsCard(List<String> items) {
    if (items.isEmpty) {
      return _mutedCard(
        child: const Text(
          'Liste d’ingrédients non disponible.',
          style: TextStyle(fontSize: 14, color: DAColors.mutedForeground),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEBFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 10),
                  decoration: const BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    items[i],
                    style: const TextStyle(fontSize: 15, height: 1.35, color: DAColors.foreground),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _stepsCard(List<String> steps) {
    if (steps.isEmpty) {
      return _mutedCard(
        child: const Text(
          'Étapes de préparation non disponibles.',
          style: TextStyle(fontSize: 14, color: DAColors.mutedForeground),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEBFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    steps[i],
                    style: const TextStyle(fontSize: 15, height: 1.45, color: DAColors.foreground),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEBFF)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: _accent),
          const SizedBox(width: 12),
          Text(
            '$label : ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DAColors.mutedForeground,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DAColors.foreground),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mutedCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DAColors.muted.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DAColors.border),
      ),
      child: child,
    );
  }
}
