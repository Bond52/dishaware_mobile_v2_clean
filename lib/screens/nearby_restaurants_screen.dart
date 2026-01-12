import 'package:flutter/material.dart';

import '../ui/components/da_card.dart';
import '../ui/components/da_badge.dart';
import '../ui/components/da_button.dart';
import '../theme/da_colors.dart';

class NearbyRestaurantsScreen extends StatelessWidget {
  const NearbyRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Green Kitchen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '4.8',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPartnerBanner(),
            const SizedBox(height: 16),
            _buildAddress(),
            const SizedBox(height: 24),
            _buildRecommendationSection(
              title: 'Vous allez sûrement aimer',
              subtitle: 'Basé sur vos préférences et votre historique',
              backgroundColor: const Color(0xFFE8F5E9),
              icon: Icons.check_circle,
              iconColor: const Color(0xFF4CAF50),
              dishes: [
                {
                  'name': 'Salade César Revisitée',
                  'calories': 380,
                  'score': 96,
                  'imagePath': 'assets/images/bowl.jpg',
                },
                {
                  'name': 'Bowl Méditerranéen',
                  'calories': 410,
                  'score': 94,
                  'imagePath': 'assets/images/bowl.jpg',
                },
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationSection(
              title: 'À découvrir absolument',
              subtitle:
                  'Nouveaux profils de saveurs qui pourraient vous plaire',
              backgroundColor: const Color(0xFFF3E5F5),
              icon: Icons.auto_awesome,
              iconColor: const Color(0xFF9C27B0),
              dishes: [
                {
                  'name': 'Tataki de Thon, Sésame & Gingembre',
                  'calories': 320,
                  'score': 78,
                  'imagePath': 'assets/images/salmon.jpg',
                },
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationSection(
              title: 'Avec quelques ajustements',
              subtitle: 'Plats adaptables à vos préférences',
              backgroundColor: const Color(0xFFE3F2FD),
              icon: Icons.info,
              iconColor: const Color(0xFF2196F3),
              dishes: [
                {
                  'name': 'Risotto aux Champignons',
                  'calories': 480,
                  'score': 72,
                  'imagePath': 'assets/images/stew.jpg',
                  'adjustments': [
                    'Sans parmesan (allergie)',
                    'Portion réduite',
                  ],
                },
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationSection(
              title: 'Probablement pas pour vous',
              subtitle:
                  'Contient des ingrédients que vous évitez habituellement',
              backgroundColor: const Color(0xFFF5F5F5),
              icon: Icons.info,
              iconColor: const Color(0xFF757575),
              dishes: [
                {
                  'name': 'Tarte aux Noix de Pécan',
                  'calories': 520,
                  'score': 12,
                  'imagePath': 'assets/images/stew.jpg',
                  'reasons': [
                    'Contient fruits à coque (allergie)',
                    'Trop calorique',
                  ],
                },
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerBanner() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Restaurant partenaire DishAware',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Menu adapté à vos préférences disponible.\nVous pouvez signaler votre présence pour une expérience optimale.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          DAButton(
            label: 'Signaler ma présence',
            variant: DAButtonVariant.primary,
            onPressed: () {},
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAddress() {
    return Row(
      children: [
        const Icon(
          Icons.location_on,
          size: 20,
          color: DAColors.mutedForeground,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            '24 Rue de la Paix, 75002 Paris',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DAColors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection({
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, dynamic>> dishes,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: DAColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...dishes.map((dish) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _DishCard(
                name: dish['name'] as String,
                calories: dish['calories'] as int,
                score: dish['score'] as int,
                imagePath: dish['imagePath'] as String,
                adjustments: dish['adjustments'] as List<String>?,
                reasons: dish['reasons'] as List<String>?,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  final String name;
  final int calories;
  final int score;
  final String imagePath;
  final List<String>? adjustments;
  final List<String>? reasons;

  const _DishCard({
    required this.name,
    required this.calories,
    required this.score,
    required this.imagePath,
    this.adjustments,
    this.reasons,
  });

  @override
  Widget build(BuildContext context) {
    return DACard(
      padding: const EdgeInsets.all(12),
      onTap: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$calories kcal',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: DAColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                DABadge(
                  label: '$score% compatible',
                  variant: DABadgeVariant.success,
                ),
                if (adjustments != null && adjustments!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...adjustments!.map((adjustment) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: Color(0xFF2196F3),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              adjustment,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: DAColors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                if (reasons != null && reasons!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...reasons!.map((reason) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Color(0xFF757575),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              reason,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: DAColors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
