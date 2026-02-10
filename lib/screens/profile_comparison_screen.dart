import 'package:flutter/material.dart';

import '../ui/components/da_card.dart';
import '../theme/da_colors.dart';
import '../features/profile_comparison/models/profile_comparison_models.dart';
import '../services/profile_comparison_service.dart';

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

class ProfileComparisonScreen extends StatefulWidget {
  final String? userIdA;
  final String? userIdB;

  const ProfileComparisonScreen({super.key, this.userIdA, this.userIdB});

  @override
  State<ProfileComparisonScreen> createState() =>
      _ProfileComparisonScreenState();
}

class _ProfileComparisonScreenState extends State<ProfileComparisonScreen> {
  ProfileComparisonResult? _result;
  bool _isLoading = true;
  String? _error;
  String? _resolvedA;
  String? _resolvedB;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolvedA != null || _resolvedB != null) return;

    _resolvedA = widget.userIdA;
    _resolvedB = widget.userIdB;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _resolvedA ??= args['userIdA']?.toString();
      _resolvedB ??= args['userIdB']?.toString();
    }

    if (_resolvedA != null && _resolvedB != null) {
      _fetchComparison();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Identifiants manquants pour la comparaison.';
      });
    }
  }

  Future<void> _fetchComparison() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await ProfileComparisonService.compareProfiles(
        userIdA: _resolvedA!,
        userIdB: _resolvedB!,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger la comparaison.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
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
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
              ),
            ],
          ),
          elevation: 0,
        ),
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: DAColors.mutedForeground),
          ),
        ),
      );
    }

    final viewModel = _buildViewModel();
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
            _buildProfileHeaders(viewModel.profileA, viewModel.profileB),
            const SizedBox(height: 24),
            _buildCompatibilityScore(viewModel),
            const SizedBox(height: 24),
            _buildAllergiesSection(viewModel.profileA, viewModel.profileB),
            const SizedBox(height: 24),
            _buildPreferencesSection(viewModel.profileA, viewModel.profileB),
            const SizedBox(height: 24),
            _buildDivergencesSection(viewModel.divergences),
            const SizedBox(height: 24),
            _buildFlavorsSection(viewModel.profileA, viewModel.profileB),
            const SizedBox(height: 24),
            _buildRecommendationsSection(viewModel.recommendations),
            const SizedBox(height: 24),
            _buildBottomActions(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  _ComparisonViewModel _buildViewModel() {
    final result = _result!;
    final userA = result.userA;
    final userB = result.userB;

    final profileA = _ProfileData(
      name: userA.firstName.isEmpty ? 'Utilisateur A' : userA.firstName,
      initials: userA.initials.isEmpty ? 'A' : userA.initials,
      color: const Color(0xFF4CAF50),
      allergies: const [],
      preferences: const [],
      flavors: const [],
    );
    final profileB = _ProfileData(
      name: userB.firstName.isEmpty ? 'Utilisateur B' : userB.firstName,
      initials: userB.initials.isEmpty ? 'B' : userB.initials,
      color: const Color(0xFF2196F3),
      allergies: const [],
      preferences: const [],
      flavors: const [],
    );

    final divergences = result.divergences
        .map(
          (d) => _DivergencePoint(
            category:
                d.type.isEmpty ? d.label.toUpperCase() : d.type.toUpperCase(),
            description: d.description.isEmpty ? d.label : d.description,
          ),
        )
        .toList();

    return _ComparisonViewModel(
      score: result.score,
      compatibilityLevel: result.compatibilityLevel,
      profileA: profileA,
      profileB: profileB,
      divergences: divergences,
      recommendations: result.recommendations,
    );
  }

  Widget _buildProfileHeaders(_ProfileData profileA, _ProfileData profileB) {
    return Row(
      children: [
        Flexible(child: _ProfileHeaderCard(profile: profileA)),
        const SizedBox(width: 12),
        const Icon(
          Icons.compare_arrows,
          size: 24,
          color: DAColors.mutedForeground,
        ),
        const SizedBox(width: 12),
        Flexible(child: _ProfileHeaderCard(profile: profileB)),
      ],
    );
  }

  Widget _buildCompatibilityScore(_ComparisonViewModel viewModel) {
    final scoreText = _formatScore(viewModel.score);
    final compatibilityText = _compatibilityLabel(viewModel.compatibilityLevel);
    final description = _compatibilityDescription(viewModel.compatibilityLevel);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            scoreText,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            compatibilityText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: DAColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DAColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection(_ProfileData profileA, _ProfileData profileB) {
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
            Flexible(child: _AllergyCard(profile: profileA)),
            const SizedBox(width: 12),
            Flexible(child: _AllergyCard(profile: profileB)),
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

  Widget _buildPreferencesSection(
    _ProfileData profileA,
    _ProfileData profileB,
  ) {
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
            Flexible(child: _PreferenceCard(profile: profileA)),
            const SizedBox(width: 12),
            Flexible(child: _PreferenceCard(profile: profileB)),
          ],
        ),
      ],
    );
  }

  Widget _buildDivergencesSection(List<_DivergencePoint> divergences) {
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
        ...divergences.map((divergence) {
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

  Widget _buildFlavorsSection(_ProfileData profileA, _ProfileData profileB) {
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
            Flexible(child: _FlavorCard(profile: profileA)),
            const SizedBox(width: 16),
            Flexible(child: _FlavorCard(profile: profileB)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(List<String> recommendations) {
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
          if (recommendations.isEmpty)
            const Text(
              'Aucune recommandation disponible pour le moment.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF4CAF50),
              ),
            )
          else
            ...recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RecommendationItem(text: rec),
              ),
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

  String _compatibilityLabel(String level) {
    switch (level) {
      case 'low':
        return 'Faible compatibilité';
      case 'moderate':
        return 'Compatibilité modérée';
      case 'high':
        return 'Très compatible';
      default:
        return 'Compatibilité';
    }
  }

  String _compatibilityDescription(String level) {
    switch (level) {
      case 'low':
        return 'Compatibilité culinaire faible. Quelques ajustements seront nécessaires.';
      case 'moderate':
        return 'Compatibilité culinaire modérée. Plusieurs options de menu possibles avec ajustements.';
      case 'high':
        return 'Très compatible. Beaucoup d’options adaptées dès maintenant.';
      default:
        return 'Analyse de compatibilité en cours.';
    }
  }

  String _formatScore(double score) {
    final percent = score <= 1 ? (score * 100).round() : score.round();
    return '$percent%';
  }
}

class _ComparisonViewModel {
  final double score;
  final String compatibilityLevel;
  final _ProfileData profileA;
  final _ProfileData profileB;
  final List<_DivergencePoint> divergences;
  final List<String> recommendations;

  const _ComparisonViewModel({
    required this.score,
    required this.compatibilityLevel,
    required this.profileA,
    required this.profileB,
    required this.divergences,
    required this.recommendations,
  });
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
