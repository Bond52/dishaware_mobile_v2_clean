import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../features/profile/services/menu_api_service.dart';
import '../features/profile/services/profile_api_service.dart';
import '../theme/da_colors.dart';
import '../ui/host/ingredients_scan_bottom_sheet.dart';
import '../utils/translate_value.dart';
import 'host_mode_menu_screen.dart';
import 'host_mode_models.dart';

class HostModeAnalysisScreen extends StatelessWidget {
  const HostModeAnalysisScreen({
    super.key,
    required this.selectedProfiles,
  });

  final List<HostGuestProfile> selectedProfiles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mode Hôte',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              'Menu pour plusieurs invités',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: _AnalysisBody(selectedProfiles: selectedProfiles),
    );
  }
}

class _AnalysisBody extends StatefulWidget {
  const _AnalysisBody({required this.selectedProfiles});

  final List<HostGuestProfile> selectedProfiles;

  @override
  State<_AnalysisBody> createState() => _AnalysisBodyState();
}

class _AnalysisBodyState extends State<_AnalysisBody> {
  bool _isGeneratingMenu = false;
  HostGuestProfile? _hostProfile;

  /// Ingrédients issus du scan IA (image).
  List<String> _detectedIngredients = [];

  /// Ingrédients ajoutés à la main (contraintes souples, optionnel).
  List<String> _manualIngredients = [];

  /// Union dédupliquée — toujours envoyée au backend (peut être vide).
  List<String> get _allIngredients => {
        ..._detectedIngredients,
        ..._manualIngredients,
      }.toList();

  /// Groupe = hôte + invités (l'hôte est inclus dans l'analyse).
  List<HostGuestProfile> get _groupProfiles {
    final list = <HostGuestProfile>[];
    if (_hostProfile != null) list.add(_hostProfile!);
    list.addAll(widget.selectedProfiles);
    return list;
  }

  @override
  void initState() {
    super.initState();
    _loadHostProfile();
  }

  Future<void> _loadHostProfile() async {
    try {
      final profile = await ProfileApiService.getMyProfile();
      if (!mounted) return;
      if (profile == null) {
        _setHostProfileFallback();
        return;
      }
      final fullName = '${profile.firstName} ${profile.lastName}'.trim();
      final initials = fullName.isEmpty
          ? 'U'
          : fullName.length == 1
              ? fullName[0].toUpperCase()
              : '${profile.firstName.isNotEmpty ? profile.firstName[0] : ''}${profile.lastName.isNotEmpty ? profile.lastName[0] : ''}'.toUpperCase();
      debugPrint('[HOST_ANALYSE] Hôte chargé: allergies=${profile.allergies.length} (${profile.allergies}), régimes=${profile.diets}, cuisines=${profile.favoriteCuisines}');
      setState(() {
        _hostProfile = HostGuestProfile(
          userId: profile.userId ?? '',
          profileId: profile.id,
          fullName: fullName.isEmpty ? 'Vous' : fullName,
          initials: initials,
          allergies: profile.allergies,
          diets: profile.diets,
          favoriteCuisines: profile.favoriteCuisines,
        );
      });
    } catch (_) {
      if (!mounted) return;
      _setHostProfileFallback();
    }
  }

  Future<void> _setHostProfileFallback() async {
    String hostUserId = '';
    try {
      hostUserId = await ApiClient.currentUserId;
    } catch (_) {}
    debugPrint('[HOST_ANALYSE] Hôte non chargé (getMyProfile en erreur ou 404), fallback userId=$hostUserId');
    if (!mounted) return;
    setState(() {
      _hostProfile = HostGuestProfile(
        userId: hostUserId,
        fullName: 'Vous',
        initials: 'V',
        allergies: const [],
        diets: const [],
        favoriteCuisines: const [],
      );
    });
  }

  /// A. Union de toutes les allergies.
  List<String> _allergiesUnion() {
    final participants = _groupProfiles;
    return participants
        .expand((p) => p.allergies)
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList();
  }

  /// B. Union de toutes les contraintes alimentaires (diets).
  List<String> _allDietsUnion() {
    final participants = _groupProfiles;
    return participants
        .expand((p) => p.diets)
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList();
  }

  /// C. Intersection des favoriteCuisines uniquement (préférences communes).
  List<String> _commonCuisinesOnly() {
    final participants = _groupProfiles;
    if (participants.isEmpty) return [];
    final lists = participants.map((p) => p.favoriteCuisines).toList();
    return lists.reduce((a, b) => a.where((c) => b.contains(c)).toList());
  }

  int _vegetarianCount() {
    const vegKeywords = ['végétarien', 'vegetarien', 'vegan', 'végan'];
    return _groupProfiles.where((p) {
      final d = p.diets.map((e) => e.toLowerCase()).toList();
      return vegKeywords.any((k) => d.any((x) => x.contains(k)));
    }).length;
  }

  List<String> _attentionPoints() {
    final points = <String>[];
    final allergies = _allergiesUnion();
    if (allergies.length > 1) {
      points.add('Plusieurs allergies à considérer');
    }
    final total = _groupProfiles.length;
    final vegCount = _vegetarianCount();
    if (vegCount > 0 && vegCount < total) {
      points.add('$vegCount/$total personnes végétariennes');
    }
    final commonCuisines = _commonCuisinesOnly();
    if (commonCuisines.isEmpty && total > 1 && _groupProfiles.any((p) => p.favoriteCuisines.isNotEmpty)) {
      points.add('Préférences de cuisine variées');
    }
    if (points.isEmpty) {
      points.add('Aucun point particulier');
    }
    return points;
  }

  Future<void> _openIngredientsSheet() async {
    final result = await showIngredientsScanSheet(
      context,
      initialDetected: List<String>.from(_detectedIngredients),
      initialManual: List<String>.from(_manualIngredients),
    );
    if (result == null || !mounted) return;
    setState(() {
      _detectedIngredients = List<String>.from(result['detected'] ?? const []);
      _manualIngredients = List<String>.from(result['manual'] ?? const []);
    });
  }

  /// Valeurs pour `guest_profiles` : **tous les participants** (hôte + invités), par **`userId`**.
  ///
  /// Le backend local renvoie « Au moins 2 profils requis » si moins de 2 profils sont résolus :
  /// il semble résoudre par `userId`, pas par `_id` Mongo — d’où l’envoi des `userId` plutôt que des ObjectId.
  List<String> _buildGuestProfilesPayload() {
    final out = <String>{};
    for (final p in _groupProfiles) {
      final u = p.userIdForApi;
      if (u != null && u.isNotEmpty) out.add(u);
    }
    return out.toList();
  }

  Future<void> _onGenerateMenu() async {
    if (_isGeneratingMenu) return;

    if (widget.selectedProfiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins un invité pour générer un menu de groupe.'),
        ),
      );
      return;
    }

    final guestProfilesPayload = _buildGuestProfilesPayload();
    debugPrint(
      'Sending profile IDs (guest_profiles = userIds hôte+invités): $guestProfilesPayload',
    );

    if (guestProfilesPayload.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’envoyer le groupe : il faut l’hôte et au moins un invité '
            'avec un identifiant utilisateur valide.',
          ),
        ),
      );
      return;
    }

    if (guestProfilesPayload.length != _groupProfiles.length) {
      debugPrint(
        'Mismatch in profile mapping: ${_groupProfiles.length} membres, '
        '${guestProfilesPayload.length} userIds distincts (certains invités sans userId ?)',
      );
    }

    setState(() => _isGeneratingMenu = true);
    debugPrint(
      '[HOST_ANALYSE] POST /menu/generate-group guest_profiles: $guestProfilesPayload, '
      'ingredients: ${_allIngredients.length}',
    );
    try {
      final response = await MenuApiService.generateGroupConsensusMenu(
        guestProfilesPayload,
        ingredients: _allIngredients,
      );
      if (!mounted) return;
      setState(() => _isGeneratingMenu = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => HostModeMenuScreen(
            selectedProfiles: widget.selectedProfiles,
            menuResult: response,
          ),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final statusCode = e.response?.statusCode;
      setState(() => _isGeneratingMenu = false);
      String message = 'Impossible de générer le menu.';
      if (statusCode == 404) {
        message =
            'Endpoint menu groupe non disponible (POST /menu/generate-group).';
      } else if (statusCode == 400) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          final m = data['message'].toString().trim();
          if (m.isNotEmpty) message = m;
        } else {
          message =
              'Certains profils sont invalides. Veuillez réessayer.';
        }
        debugPrint('[HOST_ANALYSE] 400 body: ${e.response?.data}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGeneratingMenu = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de générer le menu. Réessayez.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final participants = _groupProfiles;
    final participantCount = participants.length;
    final allAllergies = _allergiesUnion();
    final allDiets = _allDietsUnion();
    final commonCuisines = _commonCuisinesOnly();
    final attentionPoints = _attentionPoints();

    debugPrint('[ANALYSE_GROUP] allergies: $allAllergies');
    debugPrint('[ANALYSE_GROUP] diets: $allDiets');
    debugPrint('[ANALYSE_GROUP] commonCuisines: $commonCuisines');

    return Column(
      children: [
        _buildStepper(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupSummaryCard(
                  participantCount: participantCount,
                  allergiesCount: allAllergies.length,
                  dietsCount: allDiets.length,
                  commonCuisinesCount: commonCuisines.length,
                ),
                const SizedBox(height: 24),
                _buildAllergiesSection(allAllergies),
                const SizedBox(height: 24),
                _buildDietsSection(allDiets),
                const SizedBox(height: 24),
                _buildPreferencesSection(commonCuisines),
                const SizedBox(height: 24),
                _buildAttentionPointsSection(attentionPoints),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_allIngredients.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '🥕 ${_allIngredients.length} ingrédients ajoutés',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6A5FD3),
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _isGeneratingMenu ? null : _openIngredientsSheet,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F1FF),
                  foregroundColor: const Color(0xFF6A5FD3),
                  side: const BorderSide(color: Color(0xFF6A5FD3), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome, size: 22),
                label: const Text(
                  'Scanner mes ingrédients',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isGeneratingMenu ? null : _onGenerateMenu,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isGeneratingMenu
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Générer le menu',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: DAColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepIndicator(
            number: 1,
            label: 'Invités',
            isActive: false,
            isCompleted: true,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFF4CAF50),
            ),
          ),
          _StepIndicator(
            number: 2,
            label: 'Analyse',
            isActive: true,
            isCompleted: false,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFFE0E0E0),
            ),
          ),
          _StepIndicator(
            number: 3,
            label: 'Menu',
            isActive: false,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSummaryCard({
    required int participantCount,
    required int allergiesCount,
    required int dietsCount,
    required int commonCuisinesCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Résumé du groupe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: DAColors.foreground,
                    ),
                  ),
                  Text(
                    participantCount <= 1
                        ? '$participantCount participant'
                        : '$participantCount participants',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: DAColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: '$allergiesCount',
                  label: 'Allergies',
                  color: const Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  value: '$dietsCount',
                  label: 'Contraintes alimentaires',
                  color: const Color(0xFFF57C00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  value: '$commonCuisinesCount',
                  label: 'Préférences communes',
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection(List<String> allergies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: Color(0xFFD32F2F),
            ),
            const SizedBox(width: 8),
            const Text(
              'Allergies à respecter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DAColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        allergies.isEmpty
            ? Text(
                'Aucune allergie',
                style: TextStyle(
                  fontSize: 14,
                  color: DAColors.mutedForeground,
                  fontStyle: FontStyle.italic,
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...allergies.map((l) => _PillTag(
                      label: translateValue(l), color: const Color(0xFFD32F2F))),
                ],
              ),
      ],
    );
  }

  Widget _buildDietsSection(List<String> diets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.restaurant_menu, size: 20, color: Color(0xFFF57C00)),
            const SizedBox(width: 8),
            const Text(
              'Contraintes alimentaires',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DAColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        diets.isEmpty
            ? Text(
                'Aucune contrainte',
                style: TextStyle(
                  fontSize: 14,
                  color: DAColors.mutedForeground,
                  fontStyle: FontStyle.italic,
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...diets.map((l) => _PillTag(
                      label: translateValue(l), color: const Color(0xFFF57C00))),
                ],
              ),
      ],
    );
  }

  Widget _buildPreferencesSection(List<String> commonCuisines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.favorite, size: 20, color: Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            const Text(
              'Préférences communes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DAColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        commonCuisines.isEmpty
            ? Text(
                'Aucune préférence commune',
                style: TextStyle(
                  fontSize: 14,
                  color: DAColors.mutedForeground,
                  fontStyle: FontStyle.italic,
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...commonCuisines.map((l) => _PillTag(
                      label: translateValue(l), color: const Color(0xFF4CAF50))),
                ],
              ),
      ],
    );
  }

  Widget _buildAttentionPointsSection(List<String> points) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Points d\'attention',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 12),
          ...points.map((text) => _AttentionPoint(text: text)),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isActive || isCompleted
                          ? Colors.white
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive || isCompleted
                ? const Color(0xFF4CAF50)
                : const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: DAColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillTag extends StatelessWidget {
  final String label;
  final Color color;

  const _PillTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _AttentionPoint extends StatelessWidget {
  final String text;

  const _AttentionPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1976D2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
