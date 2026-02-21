import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/da_colors.dart';
import '../../../ui/components/da_card.dart';
import '../../../ui/components/da_button.dart';
import '../../../services/profile_share_service.dart';
import '../../../services/profile_comparison_service.dart';
import '../../profile_comparison/models/profile_comparison_models.dart';
import '../../profile_comparison/models/received_share_profile.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile.dart';

class ProfileComparisonScreen extends StatefulWidget {
  const ProfileComparisonScreen({super.key});

  @override
  State<ProfileComparisonScreen> createState() =>
      _ProfileComparisonScreenState();
}

class _ProfileComparisonScreenState extends State<ProfileComparisonScreen> {
  bool _isLoading = true;
  bool _isComparing = false;
  String? _error;
  List<ReceivedShareProfile> _sharedProfiles = [];
  ProfileComparisonResult? _result;

  @override
  void initState() {
    super.initState();
    _loadSharedProfiles();
  }

  Future<void> _loadSharedProfiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profiles = await ProfileShareService.getReceivedShares();
      if (!mounted) return;
      setState(() {
        _sharedProfiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur chargement partages: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger les profils partagés.';
        _isLoading = false;
      });
    }
  }

  Future<void> _compareWith(ReceivedShareProfile profile) async {
    if (_isComparing) return;
    setState(() {
      _isComparing = true;
      _error = null;
    });
    try {
      final currentUserId = await ProfileComparisonService.currentUserId;
      final result = await ProfileComparisonService.compareProfiles(
        userIdA: currentUserId,
        userIdB: profile.userId,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _isComparing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger la comparaison.';
        _isComparing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final profileProvider = context.read<ProfileProvider>();
    final currentUserProfile = profileProvider.profile;
    final profileA = _profileDataFromUserProfile(currentUserProfile);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeadersRow(profileA),
          const SizedBox(height: 24),
          if (_error != null && _result == null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFC62828)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFC62828),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DAButton(
              label: 'Réessayer',
              variant: DAButtonVariant.secondary,
              onPressed: _loadSharedProfiles,
            ),
            const SizedBox(height: 24),
          ],
          if (_result == null) ...[
            _buildProfileSelectionSection(),
            const SizedBox(height: 24),
            _buildCompatibilityNeutral(),
            const SizedBox(height: 24),
            _buildAllergiesSection(profileA, _emptyProfileB, isNeutral: true),
            const SizedBox(height: 24),
            _buildPreferencesSection(profileA, _emptyProfileB),
            const SizedBox(height: 24),
            _buildDivergencesSection(const [], isNeutral: true),
            const SizedBox(height: 24),
            _buildFlavorsSection(profileA, _emptyProfileB),
            const SizedBox(height: 24),
            _buildRecommendationsSection(const [], isNeutral: true),
          ] else ...[
            ..._buildComparisonSections(_buildViewModel()),
          ],
          const SizedBox(height: 24),
          _buildPrimaryButton(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static const _ProfileData _emptyProfileB = _ProfileData(
    name: '—',
    initials: '—',
    color: Color(0xFF2196F3),
    allergies: [],
    preferences: [],
    flavors: [],
  );

  _ProfileData _profileDataFromUserProfile(UserProfile? p) {
    if (p == null) {
      return const _ProfileData(
        name: 'Mon profil',
        initials: '?',
        color: Color(0xFF4CAF50),
        allergies: [],
        preferences: [],
        flavors: [],
      );
    }
    final fullName = '${p.firstName} ${p.lastName}'.trim();
    final name = fullName.isEmpty ? 'Mon profil' : fullName;
    final initials = name.isNotEmpty
        ? name.split(RegExp(r'\s+')).map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
        : '?';
    return _ProfileData(
      name: name,
      initials: initials.length >= 2 ? initials.substring(0, 2) : (initials.isEmpty ? '?' : initials),
      color: const Color(0xFF4CAF50),
      allergies: List<String>.from(p.allergies),
      preferences: List<String>.from(p.diets),
      flavors: p.tasteProfile.isNotEmpty
          ? [p.tasteProfile]
          : (p.favoriteCuisines.isNotEmpty ? p.favoriteCuisines : []),
    );
  }

  Widget _buildProfileHeadersRow(_ProfileData profileA) {
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
        Flexible(
          child: _result == null
              ? const _EmptyProfileCard()
              : _ProfileHeaderCard(profile: _buildViewModel().profileB),
        ),
      ],
    );
  }

  Widget _buildProfileSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choisir un profil à comparer',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        if (_sharedProfiles.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DAColors.muted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DAColors.border),
            ),
            child: const Text(
              'Aucun profil partagé pour le moment.',
              style: TextStyle(
                fontSize: 14,
                color: DAColors.mutedForeground,
              ),
            ),
          )
        else
          ..._sharedProfiles.map((profile) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DACard(
                onTap: _isComparing ? null : () => _compareWith(profile),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFE8F5E9),
                      child: Text(
                        profile.initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        profile.firstName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: DAColors.foreground,
                        ),
                      ),
                    ),
                    if (_isComparing)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(Icons.chevron_right,
                          color: DAColors.mutedForeground),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  List<Widget> _buildComparisonSections(_ComparisonViewModel viewModel) {
    final sections = <Widget>[
      _buildCompatibilityScore(viewModel),
      const SizedBox(height: 24),
      _buildAllergiesSection(viewModel.profileA, viewModel.profileB),
      const SizedBox(height: 24),
      _buildPreferencesSection(viewModel.profileA, viewModel.profileB),
    ];
    if (viewModel.divergences.isNotEmpty) {
      sections.addAll([
        const SizedBox(height: 24),
        _buildDivergencesSection(viewModel.divergences, isNeutral: false),
      ]);
    }
    sections.addAll([
      const SizedBox(height: 24),
      _buildFlavorsSection(viewModel.profileA, viewModel.profileB),
      const SizedBox(height: 24),
      _buildRecommendationsSection(viewModel.recommendations),
    ]);
    return sections;
  }

  Widget _buildCompatibilityNeutral() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF9C27B0).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '—',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9C27B0),
                  ),
                ),
                Text(
                  'compatible',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: DAColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sélectionnez un profil à comparer pour afficher la compatibilité.',
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

  _ComparisonViewModel _buildViewModel() {
    final result = _result!;
    final userA = result.userA;
    final userB = result.userB;

    // ——— LOG TEMPORAIRE: source des données (backend vs Flutter) ———
    debugPrint('[COMPARE_UI] ---------- VIEWMODEL (données affichées) ----------');
    debugPrint('[COMPARE_UI] score affiché: ${result.score} (source: API)');
    debugPrint('[COMPARE_UI] compatibilityLevel: ${result.compatibilityLevel}');
    debugPrint('[COMPARE_UI] recommandations: ${result.recommendations.length} éléments (source: ${result.recommendations.isEmpty ? "liste vide depuis API" : "API"})');

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

    debugPrint('[COMPARE_UI] divergences après mapping UI: ${divergences.length}');
    for (var i = 0; i < divergences.length; i++) {
      final d = divergences[i];
      debugPrint('[COMPARE_UI]   affichée[$i]: category="${d.category}", description="${d.description}"');
    }
    debugPrint('[COMPARE_UI] ------------------------------------------------');

    return _ComparisonViewModel(
      score: result.score,
      compatibilityLevel: result.compatibilityLevel,
      profileA: profileA,
      profileB: profileB,
      divergences: divergences,
      recommendations: result.recommendations,
    );
  }


  Widget _buildCompatibilityScore(_ComparisonViewModel viewModel) {
    final scoreText = _formatScore(viewModel.score);
    final description = _compatibilityDescription(viewModel.compatibilityLevel);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF9C27B0).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  scoreText,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9C27B0),
                  ),
                ),
                const Text(
                  'compatible',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: DAColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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

  Widget _buildAllergiesSection(
    _ProfileData profileA,
    _ProfileData profileB, {
    bool isNeutral = false,
  }) {
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
                child: Text(
                  isNeutral
                      ? 'Sélectionnez un profil à comparer pour afficher les allergies communes.'
                      : 'Aucune allergie commune • Les deux profils peuvent partager un repas en évitant tous les allergènes listés',
                  style: const TextStyle(
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

  Widget _buildDivergencesSection(
    List<_DivergencePoint> divergences, {
    bool isNeutral = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 22,
              color: Color(0xFFFF9800),
            ),
            const SizedBox(width: 8),
            const Text(
              'Points de divergence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DAColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (divergences.isEmpty && isNeutral)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.5)),
            ),
            child: const Text(
              'Sélectionnez un profil pour afficher les points de divergence.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: DAColors.mutedForeground,
              ),
            ),
          )
        else
          ...divergences.map((divergence) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF9800).withOpacity(0.6),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            divergence.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: DAColors.foreground,
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

  Widget _buildRecommendationsSection(
    List<String> recommendations, {
    bool isNeutral = false,
  }) {
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
            Text(
              isNeutral
                  ? 'Sélectionnez un profil pour voir les recommandations.'
                  : 'Aucune recommandation disponible pour le moment.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF4CAF50),
              ),
            )
          else
            ...recommendations.map(
              (rec) => _RecommendationItem(text: rec),
            ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Voir les plats compatibles'),
      ),
    );
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

class _EmptyProfileCard extends StatelessWidget {
  const _EmptyProfileCard();

  @override
  Widget build(BuildContext context) {
    return DACard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DAColors.muted,
              shape: BoxShape.circle,
              border: Border.all(color: DAColors.border, width: 1.5),
            ),
            child: const Icon(
              Icons.person_add_outlined,
              size: 28,
              color: DAColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sélectionner un profil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DAColors.mutedForeground,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
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
  }
}

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
