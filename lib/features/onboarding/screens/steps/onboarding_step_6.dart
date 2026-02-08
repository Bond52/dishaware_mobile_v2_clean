import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingStep6 extends StatefulWidget {
  const OnboardingStep6({super.key});

  @override
  State<OnboardingStep6> createState() => _OnboardingStep6State();
}

class _OnboardingStep6State extends State<OnboardingStep6> {
  final TextEditingController _controller = TextEditingController();

  static const List<String> _suggestions = [
    'Avocat',
    'Quinoa',
    'Saumon',
    'Poulet',
    'Tomate',
    'Brocoli',
    'Carotte',
    'Citron',
    'Ail',
    'Basilic',
    'Parmesan',
    'Œufs',
    'Champignons',
    'Épinards',
    'Patate douce',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    final favorites = onboardingProvider.data.favoriteIngredients;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Étape 6 sur 16',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B4A58),
                ),
              ),
              Spacer(),
              Text(
                '38%',
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
              widthFactor: 0.38,
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
              color: const Color(0xFFFFE4EE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 32,
              color: Color(0xFFE11D48),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ingrédients favoris',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B1B2B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Quels ingrédients aimez-vous particulièrement ?',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF5A6A78),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ajouter un ingrédient',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Ex: Avocat, Quinoa...',
              hintStyle: const TextStyle(color: Color(0xFF8B97A3)),
              filled: true,
              fillColor: const Color(0xFFF4F5F7),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) {
              onboardingProvider.addFavoriteIngredient(_controller.text);
              _controller.clear();
            },
          ),
          const SizedBox(height: 12),
          if (favorites.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: favorites
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE1E4E8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () =>
                                onboardingProvider.removeFavoriteIngredient(
                              item,
                            ),
                            child: const Icon(Icons.close, size: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 16),
          const Text(
            'Suggestions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions
                    .map(
                      (item) => GestureDetector(
                        onTap: () =>
                            onboardingProvider.addFavoriteIngredient(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE1E4E8)),
                          ),
                          child: Text(
                            '+ $item',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2A37),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
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
