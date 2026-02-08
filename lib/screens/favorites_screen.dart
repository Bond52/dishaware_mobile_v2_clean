import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/da_colors.dart';
import '../features/favorites/providers/favorites_store.dart';
import '../features/recommendations/providers/user_dish_interactions_store.dart';
import '../features/recommendations/widgets/recommendation_card.dart';
import '../features/recommendations/domain/recommended_dish.dart';
import '../services/feedback_service.dart';
import '../services/favorites_service.dart';
import 'dish_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Set<String> _feedbackSending = {};

  @override
  Widget build(BuildContext context) {
    final favoritesStore = context.watch<FavoritesStore>();
    final favorites = favoritesStore.favorites;
    return Scaffold(
      appBar: AppBar(title: const Text('Vos favoris'), elevation: 0),
      body: favorites.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final dish = favorites[index];
                final interaction = context
                    .watch<UserDishInteractionsStore>()
                    .getState(dish.dishId);
                final isLocked = interaction != UserInteractionState.none;
                final isSending = _feedbackSending.contains(dish.dishId);
                final isFavorite = favoritesStore.isFavorite(dish.dishId);
                final isFavoriteSending =
                    favoritesStore.isSending(dish.dishId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RecommendationCard(
                    dish: dish,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DishDetailsScreen(dish: dish),
                        ),
                      );
                    },
                    onToggleFavorite: () => _toggleFavorite(dish),
                    isFavorite: isFavorite,
                    isFavoriteSending: isFavoriteSending,
                    interaction: interaction,
                    isFeedbackLocked: isLocked,
                    isFeedbackSending: isSending,
                    onLike: () => _sendFeedback(
                      dishId: dish.dishId,
                      liked: true,
                    ),
                    onDislike: () => _sendFeedback(
                      dishId: dish.dishId,
                      liked: false,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DAColors.muted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 40,
                color: DAColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Vos favoris',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: DAColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ajoutez des plats en favoris pour les retrouver ici.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: DAColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4CAF50), width: 1),
              ),
              child: const Text(
                'Aucun favori pour le moment',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendFeedback({
    required String dishId,
    required bool liked,
  }) async {
    if (dishId.isEmpty) return;
    if (_feedbackSending.contains(dishId)) return;

    final currentState =
        context.read<UserDishInteractionsStore>().getState(dishId);
    if (currentState != UserInteractionState.none) return;

    setState(() => _feedbackSending.add(dishId));

    try {
      final response = await FeedbackService.sendScopedFeedback(
        dishId: dishId,
        liked: liked,
        scope: 'dish',
        source: 'favorites',
      );
      if (!mounted) return;

      final message = response['message']?.toString().toLowerCase() ?? '';
      final alreadyRecorded = message.contains('déjà');
      final learningApplied = response['learningApplied'] == true;

      if (learningApplied || alreadyRecorded) {
        context.read<UserDishInteractionsStore>().setStateForDish(
              dishId,
              liked
                  ? UserInteractionState.liked
                  : UserInteractionState.disliked,
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              liked
                  ? 'On affine tes recommandations'
                  : 'On évitera ce type de plat',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur feedback: $e');
    } finally {
      if (mounted) {
        setState(() => _feedbackSending.remove(dishId));
      }
    }
  }

  Future<void> _toggleFavorite(RecommendedDish dish) async {
    final dishId = dish.dishId;
    if (dishId.isEmpty) return;

    final favoritesStore = context.read<FavoritesStore>();
    if (favoritesStore.isSending(dishId)) return;

    final wasFavorite = favoritesStore.isFavorite(dishId);
    favoritesStore.toggleFavorite(dish);
    favoritesStore.setSending(dishId, true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFavorite ? 'Retiré des favoris' : 'Ajouté aux favoris',
        ),
      ),
    );

    try {
      await FavoritesService.toggleFavorite(dishId: dishId);
    } catch (e) {
      debugPrint('❌ Erreur favoris: $e');
      if (mounted) {
        favoritesStore.toggleFavorite(dish);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de mettre à jour les favoris.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        favoritesStore.setSending(dishId, false);
      }
    }
  }
}
