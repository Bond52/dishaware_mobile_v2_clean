import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/components/da_card.dart';
import '../ui/components/da_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🧪 Mock data
    final mockRecommendations = [
      {
        'name': 'Bowl méditerranéen',
        'calories': 420,
        'match': 95,
      },
      {
        'name': 'Saumon grillé',
        'calories': 380,
        'match': 88,
      },
      {
        'name': 'Poulet légumes',
        'calories': 450,
        'match': 82,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Recommandé pour vous',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          ...mockRecommendations.map((dish) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DACard(
                child: ListTile(
                  title: Text(dish['name'] as String),
                  subtitle: Text('${dish['calories']} kcal'),
                  trailing: DABadge(
                    label: '${dish['match']}%',
                    variant: DABadgeVariant.secondary,
                  ),
                  onTap: () {
                    // mock navigation
                    context.push('/dish/1');
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
