import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingStep5 extends StatelessWidget {
  const OnboardingStep5({super.key});

  static const List<String> _cuisines = [
    'Française',
    'Italienne',
    'Japonaise',
    'Chinoise',
    'Indienne',
    'Mexicaine',
    'Thaïlandaise',
    'Méditerranéenne',
    'Américaine',
    'Espagnole',
    'Libanaise',
    'Coréenne',
  ];

  static const Map<String, String> _cuisineIcons = {
    'Française': '🥖',
    'Italienne': '🍝',
    'Japonaise': '🍣',
    'Chinoise': '🥢',
    'Indienne': '🍛',
    'Mexicaine': '🌮',
    'Thaïlandaise': '🍜',
    'Méditerranéenne': '🫒',
    'Américaine': '🍔',
    'Espagnole': '🥘',
    'Libanaise': '🧆',
    'Coréenne': '🥟',
  };

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    final selected = onboardingProvider.data.cuisinePreferences;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Étape 5 sur 16',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B4A58),
                ),
              ),
              Spacer(),
              Text(
                '31%',
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
              widthFactor: 0.31,
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
              color: const Color(0xFFF0E4FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.public,
              size: 32,
              color: Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Vos cuisines préférées',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B1B2B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Quelles cuisines du monde aimez-vous explorer ?',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF5A6A78),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: _cuisines.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final cuisine = _cuisines[index];
                final isSelected = selected.contains(cuisine);
                return GestureDetector(
                  onTap: () => onboardingProvider.toggleCuisinePreference(
                    cuisine,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE8F9F2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00A57A)
                            : const Color(0xFFE1E4E8),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _cuisineIcons[cuisine] ?? '🍽️',
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cuisine,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0B1B2B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onboardingProvider.nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009E73),
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
