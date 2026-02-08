import 'package:flutter/material.dart';

import '../ui/components/da_card.dart';
import '../theme/da_colors.dart';

class _ProfileData {
  final String name;
  final String initials;
  final Color color;
  final List<String> allergies;
  final List<String> preferences;
  final List<String> flavors;

  const _ProfileData({
    required this.name,
    required this.initials,
    required this.color,
    required this.allergies,
    required this.preferences,
    required this.flavors,
  });
}

class _DivergencePoint {
  final String category;
  final String description;

  const _DivergencePoint({required this.category, required this.description});
}

class ProfileComparisonScreen extends StatelessWidget {
  const ProfileComparisonScreen({super.key});

  static const _marie = _ProfileData(
    name: 'Marie Dupont',
    initials: 'MA',
    color: Color(0xFF4CAF50),
    allergies: ['Arachides', 'Fruits à coque', 'Crustacés'],
    preferences: ['Végétarien', 'Méditerranéen', 'Faible en sodium'],
    flavors: ['Carotte + Citron', 'Quinoa', 'Avocat'],
  );

  static const _thomas = _ProfileData(
    name: 'Thomas Martin',
    initials: 'TM',
    color: Color(0xFF2196F3),
    allergies: ['Lactose'],
    preferences: ['Riche en protéines', 'Asiatique', 'Épicé'],
    flavors: ['Poulet', 'Riz', 'Gingembre'],
  );

  static const List<_DivergencePoint> _divergences = [
    _DivergencePoint(
      category: 'PRÉFÉRENCE',
      description:
          'Marie est végétarienne, Thomas préfère les plats riches en protéines animales',
    ),
    _DivergencePoint(
      category: 'GOÛT',
      description: 'Marie évite l\'épicé fort, Thomas aime les plats épicés',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparaison de profils',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              'Analyse de compatibilité',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeaders(),
            const SizedBox(height: 24),
            _buildCompatibilityScore(),
            const SizedBox(height: 24),
            _buildAllergiesSection(),
            const SizedBox(height: 24),
            _buildPreferencesSection(),
            const SizedBox(height: 24),
            _buildDivergencesSection(),
            const SizedBox(height: 24),
            _buildFlavorsSection(),
            const SizedBox(height: 24),
            _buildRecommendationsSection(),
            const SizedBox(height: 24),
            _buildBottomActions(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaders() {
    return Row(
      children: [
        Flexible(child: _ProfileHeaderCard(profile: _marie)),
        const SizedBox(width: 12),
        const Icon(
          Icons.compare_arrows,
          size: 24,
          color: DAColors.mutedForeground,
        ),
        const SizedBox(width: 12),
        Flexible(child: _ProfileHeaderCard(profile: _thomas)),
      ],
    );
  }

  Widget _buildCompatibilityScore() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            '68%',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'compatible',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: DAColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Compatibilité culinaire modérée. Plusieurs options de menu possibles avec ajustements.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DAColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Allergies',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: _AllergyCard(profile: _marie)),
            const SizedBox(width: 12),
            Flexible(child: _AllergyCard(profile: _thomas)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                size: 20,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: const Text(
                  'Aucune allergie commune - Les deux profils peuvent partager un repas en évitant tous les allergènes listés',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Préférences alimentaires',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: _PreferenceCard(profile: _marie)),
            const SizedBox(width: 12),
            Flexible(child: _PreferenceCard(profile: _thomas)),
          ],
        ),
      ],
    );
  }

  Widget _buildDivergencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Points de divergence',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
        const SizedBox(height: 16),
        ..._divergences.map((divergence) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.close, size: 18, color: Color(0xFFFF9800)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          divergence.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF9800),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          divergence.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: DAColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFlavorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saveurs préférées',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: _FlavorCard(profile: _marie)),
            const SizedBox(width: 16),
            Flexible(child: _FlavorCard(profile: _thomas)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: const Text(
                  'Recommandations pour un menu compatible',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RecommendationItem(
            text: 'Plats végétariens riches en protéines (tofu, légumineuses)',
          ),
          const SizedBox(height: 8),
          _RecommendationItem(
            text: 'Cuisine méditerranéenne avec option épices à part',
          ),
          const SizedBox(height: 8),
          _RecommendationItem(
            text: 'Éviter : lactose, arachides, fruits à coque',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Retour'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 3,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Voir les plats compatibles',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final _ProfileData profile;

  const _ProfileHeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: profile.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                profile.initials,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DAColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllergyCard extends StatelessWidget {
  final _ProfileData profile;

  const _AllergyCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          ...profile.allergies.map((allergy) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      allergy,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: DAColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  final _ProfileData profile;

  const _PreferenceCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 8,
            children: profile.preferences.map((pref) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: profile.color == const Color(0xFF4CAF50)
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: profile.color.withOpacity(0.3)),
                ),
                child: Text(
                  pref,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: profile.color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FlavorCard extends StatelessWidget {
  final _ProfileData profile;

  const _FlavorCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          ...profile.flavors.asMap().entries.map((entry) {
            final isLast = entry.key == profile.flavors.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.favorite, size: 16, color: profile.color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: DAColors.foreground,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final String text;

  const _RecommendationItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6, right: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4CAF50),
            ),
          ),
        ),
      ],
    );
  }
}
