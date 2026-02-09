import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/da_colors.dart';
import '../../ui/components/da_badge.dart';
import '../../ui/components/da_button.dart';
import '../../ui/components/da_card.dart';
import '../../features/restaurants/models/restaurant.dart';
import '../../services/restaurant_service.dart';

class RestaurantsNearbyScreen extends StatefulWidget {
  const RestaurantsNearbyScreen({super.key});

  @override
  State<RestaurantsNearbyScreen> createState() =>
      _RestaurantsNearbyScreenState();
}

class _RestaurantsNearbyScreenState extends State<RestaurantsNearbyScreen>
    with TickerProviderStateMixin {
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _expandedId;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final position = await _getPosition();
      debugPrint(
        '📍 Position récupérée: ${position.latitude}, ${position.longitude} (accuracy: ${position.accuracy}m)',
      );
      final items = await RestaurantService.fetchNearbyRestaurants(
        lat: position.latitude,
        lng: position.longitude,
        radius: 1000,
      ).timeout(const Duration(seconds: 12));
      debugPrint('🍽️ Restaurants reçus: ${items.length}');
      if (!mounted) return;
      setState(() {
        _restaurants = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Position indisponible ou service indisponible. Activez la localisation.';
        _isLoading = false;
      });
    }
  }

  Future<Position> _getPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
    } on Exception {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        debugPrint(
          '📍 Position (lastKnown): ${lastKnown.latitude}, ${lastKnown.longitude} (accuracy: ${lastKnown.accuracy}m)',
        );
        return lastKnown;
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Restaurants près de moi'),
            SizedBox(height: 2),
            Text(
              'Basé sur votre position actuelle',
              style: TextStyle(fontSize: 12, color: DAColors.mutedForeground),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: RestaurantSkeletonCard(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: DAColors.mutedForeground),
              ),
              const SizedBox(height: 12),
              DAButton(
                label: 'Réessayer',
                variant: DAButtonVariant.secondary,
                onPressed: _loadRestaurants,
              ),
            ],
          ),
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return const Center(
        child: Text(
          'Aucun restaurant détecté autour de vous pour le moment',
          style: TextStyle(color: DAColors.mutedForeground),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        final restaurantKey =
            restaurant.id.isNotEmpty ? restaurant.id : 'index_$index';
        final isExpanded = restaurantKey == _expandedId;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RestaurantAccordionCard(
            restaurant: restaurant,
            isExpanded: isExpanded,
            onTap: () {
              setState(() {
                _expandedId = isExpanded ? null : restaurantKey;
              });
            },
          ),
        );
      },
    );
  }
}

class RestaurantAccordionCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool isExpanded;
  final VoidCallback onTap;

  const RestaurantAccordionCard({
    super.key,
    required this.restaurant,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DACard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        children: [
          _buildCollapsedHeader(),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: isExpanded ? _buildExpandedContent(context) : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedHeader() {
    final badgeLabel = restaurant.isPartner
        ? 'Restaurant partenaire DishAware'
        : 'Analyse du menu en cours';
    final badgeVariant = restaurant.isPartner
        ? DABadgeVariant.success
        : DABadgeVariant.secondary;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DAColors.foreground,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      color: DAColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.location_on,
                      size: 16, color: DAColors.mutedForeground),
                  const SizedBox(width: 4),
                  Text(
                    _formatDistance(restaurant.distanceMeters),
                    style: const TextStyle(
                      fontSize: 12,
                      color: DAColors.mutedForeground,
                    ),
                  ),
                  if (restaurant.compatibleCount > 0) ...[
                    const SizedBox(width: 12),
                    Text(
                      '${restaurant.compatibleCount} plats',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DAColors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              DABadge(label: badgeLabel, variant: badgeVariant),
            ],
          ),
        ),
        Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: DAColors.mutedForeground,
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    if (!restaurant.isMenuReady) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _MenuAnalyzingCard(),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (restaurant.address.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 18, color: DAColors.mutedForeground),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    restaurant.address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: DAColors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (restaurant.isPartner)
            _PartnerBanner(onPresence: () {}),
          if (restaurant.isPartner) const SizedBox(height: 12),
          if (restaurant.sureLike.isNotEmpty)
            _RecommendationSection(
              title: 'Vous allez sûrement aimer',
              subtitle: 'Basé sur vos préférences et votre historique',
              backgroundColor: const Color(0xFFE8F5E9),
              icon: Icons.check_circle,
              iconColor: const Color(0xFF4CAF50),
              dishes: restaurant.sureLike.take(2).toList(),
              scoreColor: const Color(0xFF4CAF50),
            ),
          if (restaurant.discover.isNotEmpty) ...[
            const SizedBox(height: 12),
            _RecommendationSection(
              title: 'À découvrir absolument',
              subtitle:
                  'Nouveaux profils de saveurs qui pourraient vous plaire',
              backgroundColor: const Color(0xFFF3E5F5),
              icon: Icons.auto_awesome,
              iconColor: const Color(0xFF9C27B0),
              dishes: restaurant.discover.take(1).toList(),
              scoreColor: const Color(0xFF7C3AED),
            ),
          ],
          if (restaurant.adjustments.isNotEmpty) ...[
            const SizedBox(height: 12),
            _RecommendationSection(
              title: 'Avec quelques ajustements',
              subtitle: 'Plats adaptables à vos préférences',
              backgroundColor: const Color(0xFFE3F2FD),
              icon: Icons.info,
              iconColor: const Color(0xFF2196F3),
              dishes: restaurant.adjustments.take(2).toList(),
              scoreColor: const Color(0xFF2563EB),
              showAdjustments: true,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DAButton(
                  label: 'Voir le menu complet',
                  variant: DAButtonVariant.primary,
                  onPressed: () {},
                ),
              ),
              if (restaurant.isPartner) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: DAButton(
                    label: 'Signaler ma présence',
                    variant: DAButtonVariant.secondary,
                    onPressed: () {},
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PartnerBanner extends StatelessWidget {
  final VoidCallback onPresence;

  const _PartnerBanner({required this.onPresence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00B98D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Restaurant partenaire DishAware',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Menu adapté à vos préférences disponible.\nVous pouvez signaler votre présence pour une expérience optimale.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onPresence,
            icon: const Icon(Icons.person_pin_circle, color: Colors.white),
            label: const Text(
              'Signaler ma présence',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuAnalyzingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFF3F4F6),
            child: Icon(Icons.auto_awesome, color: Color(0xFF9CA3AF)),
          ),
          SizedBox(height: 10),
          Text(
            'Analyse du menu en cours',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: DAColors.foreground,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Nous analysons le menu de ce restaurant pour vous proposer des recommandations personnalisées.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: DAColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final List<CompatibleDish> dishes;
  final Color scoreColor;
  final bool showAdjustments;

  const _RecommendationSection({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.dishes,
    required this.scoreColor,
    this.showAdjustments = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: DAColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...dishes.map(
            (dish) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CompatibleDishTile(
                dish: dish,
                scoreColor: scoreColor,
                showAdjustments: showAdjustments,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompatibleDishTile extends StatelessWidget {
  final CompatibleDish dish;
  final Color scoreColor;
  final bool showAdjustments;

  const CompatibleDishTile({
    super.key,
    required this.dish,
    required this.scoreColor,
    required this.showAdjustments,
  });

  @override
  Widget build(BuildContext context) {
    return DACard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: dish.imageUrl.isEmpty
                ? Image.asset(
                    'assets/images/default_image.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    dish.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/default_image.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${dish.calories} kcal',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DAColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_formatScore(dish.score)}% compatible',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
                if (showAdjustments && dish.adjustments.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...dish.adjustments.map(
                    (adjustment) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 12, color: Color(0xFF2563EB)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              adjustment,
                              style: const TextStyle(
                                fontSize: 11,
                                color: DAColors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantSkeletonCard extends StatelessWidget {
  const RestaurantSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 16, width: 140, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 10),
          Container(height: 12, width: 220, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          Container(height: 20, width: 180, color: const Color(0xFFE5E7EB)),
        ],
      ),
    );
  }
}

String _formatDistance(double meters) {
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
  return '${meters.round()} m';
}

int _formatScore(double score) {
  if (score <= 1) return (score * 100).round();
  return score.round();
}
