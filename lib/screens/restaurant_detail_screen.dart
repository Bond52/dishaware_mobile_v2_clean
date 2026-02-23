import 'package:flutter/material.dart';

import '../features/restaurants/models/restaurant.dart';
import '../services/restaurant_service.dart';
import '../theme/da_colors.dart';

/// Écran détail d'un restaurant (ouvert depuis une notification ou la liste).
class RestaurantDetailScreen extends StatelessWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1B2B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Restaurant',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B1B2B),
          ),
        ),
      ),
      body: FutureBuilder<Restaurant?>(
        future: RestaurantService.fetchRestaurantById(restaurantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final restaurant = snapshot.data;
          if (restaurant == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant, size: 64, color: DAColors.primary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    const Text(
                      'Restaurant suggéré',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B1B2B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ce restaurant correspond à votre profil.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0B1B2B),
                  ),
                ),
                if (restaurant.address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (restaurant.rating > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFB800), size: 20),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B1B2B),
                        ),
                      ),
                    ],
                  ),
                ],
                if (restaurant.compatibleCount > 0) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${restaurant.compatibleCount} plat(s) compatible(s) avec votre profil',
                    style: TextStyle(
                      fontSize: 14,
                      color: DAColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
