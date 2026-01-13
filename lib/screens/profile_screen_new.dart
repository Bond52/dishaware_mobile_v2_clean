import 'package:flutter/material.dart';

import '../ui/components/da_card.dart';
import '../theme/da_colors.dart';
import 'share_profile_dialog.dart';
import 'profile_comparison_screen.dart';

class ProfileScreenNew extends StatelessWidget {
  const ProfileScreenNew({super.key});

  static const String _userName = 'Marie Dupont';
  static const String _membershipDate = 'mars 2024';
  static const int _calorieGoal = 2000;

  static const List<String> _allergies = [
    'Arachides',
    'Fruits à coque',
    'Crustacés',
  ];

  static const List<_PreferenceItem> _preferences = [
    _PreferenceItem(label: 'Végétarien', icon: Icons.eco),
    _PreferenceItem(label: 'Faible en sodium', icon: Icons.water_drop),
    _PreferenceItem(label: 'Riche en protéines', icon: Icons.favorite),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Mon Profil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: DAColors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gérez vos préférences alimentaires',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: DAColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileCard(context),
            const SizedBox(height: 24),
            _buildHealthConstraintsSection(),
            const SizedBox(height: 24),
            _buildFoodPreferencesSection(),
            const SizedBox(height: 24),
            _buildCalorieGoalSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return DACard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'MA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            _userName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Membre depuis $_membershipDate',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DAColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ShareProfileDialog.show(context);
              },
              icon: const Icon(Icons.share, size: 20),
              label: const Text('Partager mon profil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileComparisonScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.people, size: 20),
              label: const Text('Comparer avec un autre profil'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DAColors.foreground,
                side: const BorderSide(color: DAColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthConstraintsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contraintes de santé',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        DACard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, size: 20, color: Color(0xFFD32F2F)),
                  const SizedBox(width: 8),
                  const Text(
                    'Allergies alimentaires',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: DAColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allergies.map((allergy) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD32F2F).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      allergy,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  '+ Ajouter une allergie',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

  Widget _buildFoodPreferencesSection() {
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
        DACard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ..._preferences.map((pref) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          pref.icon,
                          size: 20,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pref.label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: DAColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  '+ Ajouter une préférence',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

  Widget _buildCalorieGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Objectif calorique',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        DACard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Objectif journalier',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: DAColors.foreground,
                    ),
                  ),
                  Text(
                    '$_calorieGoal kcal',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Basé sur votre profil et vos objectifs de bien-être',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: DAColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreferenceItem {
  final String label;
  final IconData icon;

  const _PreferenceItem({required this.label, required this.icon});
}
