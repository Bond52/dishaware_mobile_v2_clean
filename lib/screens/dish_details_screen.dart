import 'package:flutter/material.dart';

import '../ui/components/da_card.dart';
import '../ui/components/da_badge.dart';
import '../theme/da_colors.dart';
import '../features/recommendations/domain/recommended_dish.dart';
import '../services/feedback_service.dart';

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

class DishDetailsScreen extends StatefulWidget {
  final RecommendedDish? dish;

  const DishDetailsScreen({super.key, this.dish});

  @override
  State<DishDetailsScreen> createState() => _DishDetailsScreenState();
}

class _DishDetailsScreenState extends State<DishDetailsScreen> {
  bool? _conceptLiked;
  bool? _preparationLiked;
  bool _sendingConcept = false;
  bool _sendingPreparation = false;

  static const String _fallbackDishName = 'Plat';
  static const int _fallbackCalories = 0;

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
    final dish = widget.dish;
    final hasTags =
        (dish?.cuisines.isNotEmpty ?? false) || (dish?.diets.isNotEmpty ?? false);
    final hasWhy = dish?.explanation.isNotEmpty ?? false;
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
                  if (hasTags) ...[
                    const SizedBox(height: 16),
                    _buildTagsCard(),
                  ],
                  if (hasWhy) ...[
                    const SizedBox(height: 16),
                    _buildWhyThisDishCard(),
                  ],
                  const SizedBox(height: 16),
                  _buildIngredientsCard(),
                  const SizedBox(height: 16),
                  _buildFeedbackInfoCard(),
                  const SizedBox(height: 16),
                  _buildPreferenceQuestionCard(
                    title: 'Aimez-vous ce type de plat ?',
                    subtitle:
                        'Le concept "Bowl Buddha Avocat & Quinoa" en général',
                    feedbackType: 'concept',
                    likedState: _conceptLiked,
                    isSending: _sendingConcept,
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceQuestionCard(
                    title: 'Cette préparation vous plaît ?',
                    subtitle: 'La version de Green Kitchen',
                    feedbackType: 'preparation',
                    likedState: _preparationLiked,
                    isSending: _sendingPreparation,
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
    final dish = widget.dish;
    final imageUrl = dish?.imageUrl ?? '';
    final calories = dish?.calories ?? _fallbackCalories;
    final compatibilityScore = dish?.score;

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
    final dish = widget.dish;
    final dishName = dish?.name ?? _fallbackDishName;
    final score = dish?.score ?? 0;
    final scoreLabel = _scoreLabel(score);

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
        Text(
          '${_formatScore(score)}% compatible • $scoreLabel',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: DAColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildTagsCard() {
    final dish = widget.dish;
    final cuisines = dish?.cuisines ?? [];
    final diets = dish?.diets ?? [];
    if (cuisines.isEmpty && diets.isEmpty) {
      return const SizedBox.shrink();
    }
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations générales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          if (diets.isNotEmpty) ...[
            const Text(
              'Régimes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DAColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: diets
                  .map((diet) => DABadge(label: diet))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (cuisines.isNotEmpty) ...[
            const Text(
              'Cuisines',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DAColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cuisines
                  .map((cuisine) => DABadge(label: cuisine))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWhyThisDishCard() {
    final dish = widget.dish;
    final explanation = dish?.explanation ?? [];
    if (explanation.isEmpty) {
      return const SizedBox.shrink();
    }
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pourquoi ce plat ?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          ...explanation.map((item) {
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
                      item,
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

  Widget _buildIngredientsCard() {
    final dish = widget.dish;
    final ingredients = dish?.ingredients ?? [];
    final preview = dish?.ingredientsPreview ?? [];
    final List<String> items;
    if (ingredients.isNotEmpty) {
      items = ingredients;
    } else if (preview.isNotEmpty) {
      items = preview.length > 5 ? preview.take(5).toList() : preview;
    } else {
      items = [];
    }

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
          if (items.isEmpty)
            const Text(
              'Les ingrédients détaillés seront bientôt disponibles.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: DAColors.mutedForeground,
              ),
            )
          else
            ...items.map((ingredient) {
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
    required String feedbackType,
    required bool? likedState,
    required bool isSending,
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
          if (likedState == null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSending
                        ? null
                        : () => _sendFeedback(
                              feedbackType: feedbackType,
                              liked: true,
                            ),
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
                    onPressed: isSending
                        ? null
                        : () => _sendFeedback(
                              feedbackType: feedbackType,
                              liked: false,
                            ),
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
            )
          else
            Text(
              likedState
                  ? '👍 Merci ! DishAware apprend ce que vous aimez.'
                  : '👎 Merci ! DishAware apprend ce que vous aimez.',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: DAColors.mutedForeground,
              ),
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

  Future<void> _sendFeedback({
    required String feedbackType,
    required bool liked,
  }) async {
    final dishId = widget.dish?.dishId ?? '';
    if (dishId.isEmpty) {
      debugPrint('⚠️ dishId manquant, feedback ignoré');
      return;
    }

    if (feedbackType == 'concept') {
      setState(() => _sendingConcept = true);
    } else {
      setState(() => _sendingPreparation = true);
    }

    try {
      await FeedbackService.sendFeedback(
        dishId: dishId,
        feedbackType: feedbackType,
        liked: liked,
      );
      if (!mounted) return;
      setState(() {
        if (feedbackType == 'concept') {
          _conceptLiked = liked;
        } else {
          _preparationLiked = liked;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci ! DishAware apprend ce que vous aimez.'),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erreur envoi feedback: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Action enregistrée localement.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (feedbackType == 'concept') {
            _sendingConcept = false;
          } else {
            _sendingPreparation = false;
          }
        });
      }
    }
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

  String _scoreLabel(double score) {
    final percent = _formatScore(score);
    if (percent < 34) return 'Compatibilité faible';
    if (percent < 67) return 'Compatibilité moyenne';
    return 'Compatibilité élevée';
  }
}

