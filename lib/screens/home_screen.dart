import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ui/components/da_card.dart';
import '../theme/da_colors.dart';
import '../features/recommendations/data/recommendation_api.dart';
import '../features/recommendations/domain/recommended_dish.dart';
import '../features/recommendations/providers/user_dish_interactions_store.dart';
import '../features/recommendations/widgets/recommendation_card.dart';
import '../features/favorites/providers/favorites_store.dart';
import '../services/feedback_service.dart';
import '../services/favorites_service.dart';
import '../features/menus/widgets/ai_personalized_menu_card.dart';
import 'restaurants_nearby/restaurants_nearby_screen.dart';
import 'host_mode_guests_screen.dart';
import 'dish_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RecommendedDish> _recommendations = [];
  bool _isLoadingRecommendations = true;
  final Set<String> _feedbackSending = {};

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations({bool showSnackBar = false}) async {
    try {
      final items = await RecommendationApi.getRecommendations(limit: 10);
      if (!mounted) return;
      setState(() {
        _recommendations = items;
        _isLoadingRecommendations = false;
      });
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Suggestions mises à jour selon tes préférences 🌱'),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement recommandations: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingRecommendations = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    if (kDebugMode) {
      debugPrint('[HOME_REFRESH] Fetching new recommendations');
    }
    setState(() {
      _recommendations = [];
      _isLoadingRecommendations = true;
    });
    try {
      final items = await RecommendationApi.getRecommendations(
        limit: 10,
        forceRefresh: true,
      );
      if (!mounted) return;
      setState(() {
        _recommendations = items;
        _isLoadingRecommendations = false;
      });
      if (kDebugMode) {
        debugPrint('[HOME_REFRESH] Received ${items.length} new dishes');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Suggestions mises à jour selon tes préférences 🌱'),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erreur refresh recommandations: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingRecommendations = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de rafraîchir les suggestions. Réessayez.'),
        ),
      );
    }
  }

  Future<void> _sendFeedback({
    required String dishId,
    required bool liked,
  }) async {
    if (dishId.isEmpty) return;
    final currentState =
        context.read<UserDishInteractionsStore>().getState(dishId);
    if (currentState != UserInteractionState.none ||
        _feedbackSending.contains(dishId)) {
      return;
    }

    setState(() => _feedbackSending.add(dishId));

    try {
      final response = await FeedbackService.sendScopedFeedback(
        dishId: dishId,
        liked: liked,
        scope: 'dish',
        source: 'home',
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

      await _loadRecommendations();
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
      if (mounted) favoritesStore.setSending(dishId, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildGreeting(),
              const SizedBox(height: 8),
              _buildSubtitle(),
            const SizedBox(height: 16),
            const AiPersonalizedMenuCard(),
            const SizedBox(height: 24),
              _buildInsightCard(),
              const SizedBox(height: 16),
              _buildCaloricObjective(),
              const SizedBox(height: 16),
              _buildActionButtons(context),
              const SizedBox(height: 24),
              _buildRecommendationsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return const Text(
      'Bonjour, Marie',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: DAColors.foreground,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Découvrez vos recommandations du jour',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: DAColors.mutedForeground,
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF4CAF50),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Insight détecté',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nous avons remarqué que vous appréciez souvent les plats combinant carotte + citron. Nos recommandations s\'ajustent à vos préférences',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloricObjective() {
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Objectif calorique journalier',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1480 / 2000 kcal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: DAColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 1480 / 2000,
              minHeight: 8,
              backgroundColor: DAColors.muted,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Encore 520 kcal disponibles pour ce soir',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DAColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.location_on,
            label: 'Restaurants près de moi',
            color: const Color(0xFF4CAF50),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RestaurantsNearbyScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionButton(
            icon: Icons.lightbulb_outline,
            label: 'Mode Hôte',
            color: const Color(0xFF9C27B0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HostModeGuestsScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommandations pour vous',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingRecommendations)
          const Text(
            'Nous apprenons encore vos goûts',
            style: TextStyle(color: DAColors.mutedForeground),
          )
        else if (_recommendations.isEmpty)
          const Text(
            'Nous apprenons encore vos goûts',
            style: TextStyle(color: DAColors.mutedForeground),
          )
        else
          ListView.builder(
            itemCount: _recommendations.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final dish = _recommendations[index];
              final interaction = context
                  .watch<UserDishInteractionsStore>()
                  .getState(dish.dishId);
              final isLocked = interaction != UserInteractionState.none;
              final isSending = _feedbackSending.contains(dish.dishId);
              final favoritesStore = context.watch<FavoritesStore>();
              final isFavorite = favoritesStore.isFavorite(dish.dishId);
              final isFavoriteSending = favoritesStore.isSending(dish.dishId);
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
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 88),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DAColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DAColors.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

