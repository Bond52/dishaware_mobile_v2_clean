import 'package:flutter/material.dart';

// UI DishAware
import '../ui/components/da_card.dart';
import '../ui/components/da_button.dart';
import '../ui/components/da_badge.dart';
import '../ui/components/da_progress.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===============================
            // 👋 HEADER
            // ===============================
            const Text(
              'Bonjour, Marie',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Découvrez vos recommandations du jour',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // ===============================
            // 🧠 INSIGHT DÉTECTÉ
            // ===============================
            DACard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.lightbulb_outline, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insight détecté',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vous appréciez souvent les plats combinant carotte + citron.\n'
                          'Nos recommandations s’ajustent à vos préférences.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===============================
            // 🔥 OBJECTIF CALORIQUE
            // ===============================
            const Text(
              'Objectif calorique journalier',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('1480 / 2000 kcal'),
                Text('Encore 520 kcal'),
              ],
            ),
            const SizedBox(height: 6),
            const DAProgress(value: 0.74),

            const SizedBox(height: 24),

            // ===============================
            // ⚡ ACTIONS RAPIDES
            // ===============================
            Row(
              children: [
                Expanded(
                  child: DAButton(
                    label: 'Restaurants près de moi',
                    variant: DAButtonVariant.secondary,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DAButton(
                    label: 'Mode Hôte',
                    variant: DAButtonVariant.secondary,
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ===============================
            // 🍽️ RECOMMANDATIONS
            // ===============================
            const Text(
              'Recommandations pour vous',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _RecommendationCard(
              title: 'Bowl Buddha Avocat & Quinoa',
              subtitle: 'Green Kitchen • 25 min',
              kcal: '420 kcal',
              match: '95% compatible',
            ),

            const SizedBox(height: 16),

            _RecommendationCard(
              title: 'Saumon Grillé, Légumes de Saison',
              subtitle: 'Fresh & Co • 30 min',
              kcal: '380 kcal',
              match: '92% compatible',
            ),

            const SizedBox(height: 16),

            _RecommendationCard(
              title: 'Poulet légumes',
              subtitle: 'Healthy Corner • 20 min',
              kcal: '340 kcal',
              match: '88% compatible',
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// 🍽️ CARD RECOMMANDATION (MOCK)
// =======================================================
class _RecommendationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String kcal;
  final String match;

  const _RecommendationCard({
    required this.title,
    required this.subtitle,
    required this.kcal,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return DACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://picsum.photos/400/200',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DABadge(
                label: match,
                variant: DABadgeVariant.success,
              ),
              DABadge(
                label: kcal,
                variant: DABadgeVariant.secondary,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
