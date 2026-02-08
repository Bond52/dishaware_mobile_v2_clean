import 'package:flutter/material.dart';

import '../ui/components/da_card.dart';
import '../theme/da_colors.dart';
import '../features/recommendations/domain/recommended_dish.dart';

class _PreparationTest {
  final String restaurantName;
  final String timeAgo;
  final bool liked;

  const _PreparationTest({
    required this.restaurantName,
    required this.timeAgo,
    required this.liked,
  });
}

class DishDetailsScreen extends StatelessWidget {
  final RecommendedDish? dish;

  const DishDetailsScreen({super.key, this.dish});

  static const String _fallbackDishName = 'Bowl Buddha Avocat & Quinoa';
  static const String _fallbackRestaurantName = 'Green Kitchen';
  static const int _fallbackCalories = 420;
  static const String _fallbackTime = '25 min';
  static const double _fallbackRating = 4.8;
  static const String _fallbackDescription =
      'Un bowl complet et équilibré avec quinoa bio, avocat frais, pois chiches rôtis, carottes râpées et sauce citron-tahini.';
  static const int _fallbackProteins = 18;
  static const int _fallbackCarbs = 45;
  static const int _fallbackFats = 22;

  static const List<String> _fallbackIngredients = [
    'Quinoa bio (80g)',
    'Avocat (1/2)',
    'Pois chiches rôtis (60g)',
    'Carotte râpée (50g)',
    'Épinards frais (30g)',
    'Sauce citron-tahini (25ml)',
    'Graines de sésame',
  ];

  static const List<_PreparationTest> _testedPreparations = [
    _PreparationTest(
      restaurantName: 'Green Kitchen',
      timeAgo: 'Il y a 2 jours',
      liked: true,
    ),
    _PreparationTest(
      restaurantName: 'Bio & Co',
      timeAgo: 'Il y a 1 semaine',
      liked: true,
    ),
    _PreparationTest(
      restaurantName: 'Veggie House',
      timeAgo: 'Il y a 2 semaines',
      liked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du plat'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainInfo(),
                  const SizedBox(height: 16),
                  _buildDescriptionCard(),
                  const SizedBox(height: 16),
                  _buildNutritionalValuesCard(),
                  const SizedBox(height: 16),
                  _buildIngredientsCard(),
                  const SizedBox(height: 16),
                  _buildFeedbackInfoCard(),
                  const SizedBox(height: 16),
                  _buildPreferenceQuestionCard(
                    title: 'Aimez-vous ce type de plat ?',
                    subtitle:
                        'Le concept "Bowl Buddha Avocat & Quinoa" en général',
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceQuestionCard(
                    title: 'Cette préparation vous plaît ?',
                    subtitle: 'La version de Green Kitchen',
                  ),
                  const SizedBox(height: 16),
                  _buildTestedPreparationsCard(),
                  const SizedBox(height: 16),
                  _buildOrderButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    final imageUrl = dish?.imageUrl ?? '';
    final calories = dish?.calories ?? _fallbackCalories;
    final compatibilityScore = dish?.compatibilityScore;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: imageUrl.isEmpty
              ? Image.asset(
                  'assets/images/default_image.png',
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      'assets/images/default_image.png',
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                    );
                  },
                ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '$calories kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (compatibilityScore != null)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_formatScore(compatibilityScore)}% compatible',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DAColors.foreground,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMainInfo() {
    final dishName = dish?.name ?? _fallbackDishName;
    final restaurant = (dish?.features['restaurantName'] as String?) ??
        _fallbackRestaurantName;
    final time = (dish?.features['time'] as String?) ?? _fallbackTime;
    final rating = (dish?.features['rating'] as num?)?.toDouble() ??
        _fallbackRating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dishName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.access_time,
              size: 16,
              color: DAColors.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: DAColors.mutedForeground,
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: DAColors.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          restaurant,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: DAColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    final description =
        (dish?.features['description'] as String?) ?? _fallbackDescription;
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Text(
        description,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: DAColors.foreground,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildNutritionalValuesCard() {
    final nutrition = (dish?.features['nutrition'] as Map<String, dynamic>?) ??
        {};
    final proteins = (nutrition['proteins'] ?? _fallbackProteins).toString();
    final carbs = (nutrition['carbs'] ?? _fallbackCarbs).toString();
    final fats = (nutrition['fats'] ?? _fallbackFats).toString();
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Valeurs nutritionnelles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NutritionValue(
                value: '${proteins}g',
                label: 'Protéines',
                color: const Color(0xFF4CAF50),
              ),
              _NutritionValue(
                value: '${carbs}g',
                label: 'Glucides',
                color: const Color(0xFF2196F3),
              ),
              _NutritionValue(
                value: '${fats}g',
                label: 'Lipides',
                color: const Color(0xFFD32F2F),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard() {
    final ingredients = (dish?.features['ingredients'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        _fallbackIngredients;
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingrédients',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          ...ingredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: DAColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeedbackInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, size: 20, color: Color(0xFF1976D2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Votre avis compte',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Aidez-nous à améliorer vos recommandations en distinguant le plat de sa préparation.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceQuestionCard({
    required String title,
    required String subtitle,
  }) {
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DAColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: connect feedback to tasteLearning endpoint
                  },
                  icon: const Icon(Icons.thumb_up, size: 18),
                  label: const Text('J\'aime'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DAColors.foreground,
                    side: const BorderSide(color: DAColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: connect feedback to tasteLearning endpoint
                  },
                  icon: const Icon(Icons.thumb_down, size: 18),
                  label: const Text('Je n\'aime pas'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DAColors.foreground,
                    side: const BorderSide(color: DAColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestedPreparationsCard() {
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Préparations testées',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          ..._testedPreparations.map((prep) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prep.restaurantName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: DAColors.foreground,
                          ),
                        ),
                        Text(
                          prep.timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: DAColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    prep.liked ? Icons.thumb_up : Icons.thumb_down,
                    size: 20,
                    color: prep.liked
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF9E9E9E),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Commander ce plat',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  int _formatScore(double score) {
    if (score <= 1) return (score * 100).round();
    return score.round();
  }
}

class _NutritionValue extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _NutritionValue({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: DAColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
