import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingStep2 extends StatelessWidget {
  const OnboardingStep2({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    final calories = onboardingProvider.data.dailyCalories.toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Étape 2 sur 16',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B4A58),
                ),
              ),
              Spacer(),
              Text(
                '13%',
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
              widthFactor: 0.13,
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
              color: const Color(0xFFDFF8EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.track_changes,
              size: 32,
              color: Color(0xFF00A57A),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Votre objectif calorique',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B1B2B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Définissez votre apport calorique journalier idéal',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF5A6A78),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Calories par jour',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2A37),
                ),
              ),
              const Spacer(),
              Text(
                '${calories.round()}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00A57A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF0B0F1A),
              inactiveTrackColor: const Color(0xFFE3E6EA),
              thumbColor: Colors.white,
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              min: 1200,
              max: 3500,
              divisions: 46,
              value: calories,
              label: '${calories.round()}',
              onChanged: (value) =>
                  onboardingProvider.updateDailyCalories(value.round()),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Text(
                '1200',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7A88)),
              ),
              Spacer(),
              Text(
                '3500',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7A88)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF5FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB6D4FF)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.lightbulb_outline, color: Color(0xFF3B82F6)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Conseil : La moyenne se situe entre 1800–2400 kcal/jour selon votre activité',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
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
