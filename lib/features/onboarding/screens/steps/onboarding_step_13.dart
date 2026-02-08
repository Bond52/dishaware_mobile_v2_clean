import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingStep13 extends StatelessWidget {
  const OnboardingStep13({super.key});

  static const List<_Option> _options = [
    _Option('Prudent', 'Valeurs sûres', '🛡️'),
    _Option('Curieux', 'Ouvert à la découverte', '🔎'),
    _Option('Aventurier', 'Toujours prêt à tester', '🚀'),
  ];

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    final selected = onboardingProvider.data.explorationAttitude;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Étape 13 sur 16',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B4A58),
                ),
              ),
              Spacer(),
              Text(
                '81%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B4A58),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFE3E6EA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.81,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00A57A),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onboardingProvider.skipStep,
              child: const Text(
                'Passer →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5B6A78),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.explore_outlined,
              size: 32,
              color: Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Quand tu choisis un nouveau restaurant, tu es plutôt :',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B1B2B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Votre attitude face à la nouveauté',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF5A6A78),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = _options[index];
                final isSelected = selected == option.title;
                return _SelectableCard(
                  title: option.title,
                  subtitle: option.subtitle,
                  emoji: option.emoji,
                  selected: isSelected,
                  onTap: () => onboardingProvider
                      .setExplorationAttitude(option.title),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => context.go('/onboarding/confirmation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009E73),
                disabledBackgroundColor: const Color(0xFFB7DCCF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Terminer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: onboardingProvider.previousStep,
              child: const Text(
                'Retour',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2A37),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F9F2) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF00A57A) : const Color(0xFFE1E4E8),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE1E4E8)),
                color: selected ? const Color(0xFF00A57A) : Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(emoji, style: const TextStyle(fontSize: 20)),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7A88),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option {
  final String title;
  final String subtitle;
  final String emoji;

  const _Option(this.title, this.subtitle, this.emoji);
}
