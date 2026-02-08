import 'package:flutter/material.dart';

import '../ui/components/da_card.dart';
import '../ui/components/da_badge.dart';
import '../theme/da_colors.dart';
import '../features/recommendations/data/recommendation_api.dart';
import '../features/recommendations/domain/recommended_dish.dart';
import 'nearby_restaurants_screen.dart';
import 'host_mode_guests_screen.dart';
import 'dish_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<RecommendedDish>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _recommendationsFuture = RecommendationApi.getRecommendations(limit: 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildGreeting(),
            const SizedBox(height: 8),
            _buildSubtitle(),
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
                  builder: (context) => const NearbyRestaurantsScreen(),
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
        FutureBuilder<List<RecommendedDish>>(
          future: _recommendationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                'Nous apprenons encore vos goûts',
                style: TextStyle(color: DAColors.mutedForeground),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text(
                'Nous apprenons encore vos goûts',
                style: TextStyle(color: DAColors.mutedForeground),
              );
            }

            final recommendations = snapshot.data!;
            return Column(
              children: recommendations.map((dish) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _RecommendationCard(dish: dish),
                );
              }).toList(),
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

class _RecommendationCard extends StatelessWidget {
  final RecommendedDish dish;

  const _RecommendationCard({required this.dish});

  @override
  Widget build(BuildContext context) {
    return DACard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DishDetailsScreen(dish: dish),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: dish.imageUrl.isEmpty
                    ? Image.asset(
                        'assets/images/default_image.png',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        dish.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Image.asset(
                            'assets/images/default_image.png',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dish.calories} kcal',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DAColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: DABadge(
                  label: '${_formatScore(dish.compatibilityScore)}% compatible',
                  variant: DABadgeVariant.success,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Voir les détails',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: DAColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _formatScore(double score) {
    if (score <= 1) {
      return (score * 100).round();
    }
    return score.round();
  }
}
