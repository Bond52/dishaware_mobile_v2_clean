import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9FAF4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A57A),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'DishAware',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0B1B2B),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Des plats frais et personnalisés, adaptés à vos goûts et à votre santé',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Color(0xFF4C5A67),
                  ),
                ),
                const SizedBox(height: 28),
                _BenefitRow(
                  title: 'Recommandations intelligentes',
                  subtitle: 'Basées sur vos préférences et contraintes',
                ),
                const SizedBox(height: 16),
                _BenefitRow(
                  title: 'Livraison de plats frais',
                  subtitle: 'Cuisinés par des restaurateurs partenaires',
                ),
                const SizedBox(height: 16),
                _BenefitRow(
                  title: 'Suivi personnalisé',
                  subtitle: 'Objectifs caloriques et insights nutritionnels',
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/onboarding/auth'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009E73),
                      elevation: 8,
                      shadowColor: const Color(0x33009E73),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Créer mon compte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => context.go('/onboarding/auth'),
                  child: const Text(
                    'J’ai déjà un compte',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3C4A57),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String title;
  final String subtitle;

  const _BenefitRow({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFD9F7EA),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 18,
            color: Color(0xFF009E73),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B1B2B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: Color(0xFF4C5A67),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
