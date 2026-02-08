import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingStep7 extends StatelessWidget {
  const OnboardingStep7({super.key});

  static const List<String> _activityLevels = [
    'Sédentaire',
    'Léger',
    'Modéré',
    'Actif',
    'Très actif',
  ];

  static const Map<String, String> _activitySubtitles = {
    'Sédentaire': 'Peu ou pas d’exercice',
    'Léger': '1-3 jours/semaine',
    'Modéré': '3-5 jours/semaine',
    'Actif': '6-7 jours/semaine',
    'Très actif': 'Sport intense quotidien',
  };

  static const Map<String, String> _activityIcons = {
    'Sédentaire': '🪑',
    'Léger': '🚶',
    'Modéré': '🏃',
    'Actif': '💪',
    'Très actif': '🏋️',
  };

  static const List<String> _orderFrequencies = [
    'Occasionnellement',
    '1-2 fois / semaine',
    '3-4 fois / semaine',
    'Quotidiennement',
  ];

  static const Map<String, String> _orderSubtitles = {
    'Occasionnellement': 'Selon vos envies',
    '1-2 fois / semaine': 'Rythme modéré',
    '3-4 fois / semaine': 'Régulier',
    'Quotidiennement': 'Très fréquent',
  };

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    final data = onboardingProvider.data;
    final canFinish =
        data.activityLevel.isNotEmpty && data.orderFrequency.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Étape 7 sur 16',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B4A58),
                ),
              ),
              Spacer(),
              Text(
                '44%',
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
              widthFactor: 0.44,
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
              color: const Color(0xFFE1ECFF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.monitor_heart_outlined,
              size: 32,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Dernières informations',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B1B2B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pour personnaliser au mieux vos recommandations',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF5A6A78),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Icon(Icons.show_chart, color: Color(0xFF00A57A), size: 18),
              SizedBox(width: 8),
              Text(
                'Niveau d’activité physique',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B1B2B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._activityLevels.map(
            (level) => _SelectableCard(
              title: level,
              subtitle: _activitySubtitles[level] ?? '',
              emoji: _activityIcons[level] ?? '🏃',
              selected: data.activityLevel == level,
              onTap: () => onboardingProvider.setActivityLevel(level),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fréquence de commande',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B1B2B),
            ),
          ),
          const SizedBox(height: 8),
          ..._orderFrequencies.map(
            (value) => _SelectableCard(
              title: value,
              subtitle: _orderSubtitles[value] ?? '',
              emoji: '🗓️',
              selected: data.orderFrequency == value,
              onTap: () => onboardingProvider.setOrderFrequency(value),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canFinish ? onboardingProvider.nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009E73),
                disabledBackgroundColor: const Color(0xFFB7DCCF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Continuer',
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
        margin: const EdgeInsets.only(bottom: 12),
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
