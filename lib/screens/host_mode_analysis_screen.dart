import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../features/profile/services/menu_api_service.dart';
import '../features/profile/services/profile_api_service.dart';
import '../theme/da_colors.dart';
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
      String hostUserId = '';
      try {
        hostUserId = await ApiClient.currentUserId;
      } catch (_) {}
      debugPrint('[HOST_ANALYSE] Hôte non chargé (getMyProfile en erreur), fallback userId=$hostUserId');
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
  }

  /// Union de toutes les allergies de chaque profil.
  List<String> _allergiesUnion() {
    final allAllergies = _groupProfiles
        .expand((p) => p.allergies)
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList();
    return allAllergies;
  }

  /// Intersection des régimes + intersection des cuisines (préférences communes).
  List<String> _commonPreferences() {
    final profiles = _groupProfiles;
    if (profiles.isEmpty) return [];
    final commonDiets = _intersection(profiles.map((p) => p.diets).toList());
    final commonCuisines = _intersection(profiles.map((p) => p.favoriteCuisines).toList());
    final combined = <String>[...commonDiets, ...commonCuisines];
    return combined.toSet().toList();
  }

  static List<String> _intersection(List<List<String>> lists) {
    final nonEmpty = lists.where((l) => l.isNotEmpty).toList();
    if (nonEmpty.isEmpty) return [];
    Set<String> inter = nonEmpty.first.toSet();
    for (final list in nonEmpty.skip(1)) {
      inter = inter.intersection(list.toSet());
    }
    return inter.toList();
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
    final common = _commonPreferences();
    final hasVaried = _groupProfiles.any((p) =>
        p.diets.isNotEmpty && common.isEmpty);
    if (hasVaried || _groupProfiles.any((p) => p.diets.isNotEmpty)) {
      if (common.isEmpty && total > 1) {
        points.add('Préférences de cuisine variées');
      }
    }
    if (points.isEmpty) {
      points.add('Aucun point particulier');
    }
    return points;
  }

  Future<void> _onGenerateMenu() async {
    if (_isGeneratingMenu) return;
    setState(() => _isGeneratingMenu = true);
    final profileIds = _groupProfiles
        .map((p) => p.profileId ?? p.userId)
        .where((id) => id.isNotEmpty)
        .toList();
    debugPrint('[HOST_ANALYSE] POST menu/consensus/group profileIds: $profileIds');
    try {
      final response =
          await MenuApiService.generateGroupConsensusMenu(profileIds);
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
      if (statusCode == 400 &&
          profileIds.length > 1 &&
          _hostProfile?.profileId != null &&
          _hostProfile!.profileId!.isNotEmpty) {
        try {
          final fallbackResponse = await MenuApiService.generateGroupConsensusMenu(
            [_hostProfile!.profileId!],
          );
          if (!mounted) return;
          setState(() => _isGeneratingMenu = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Menu généré pour votre profil. Le serveur n\'a pas reconnu les profils invités.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (context) => HostModeMenuScreen(
                selectedProfiles: widget.selectedProfiles,
                menuResult: fallbackResponse,
              ),
            ),
          );
          return;
        } catch (_) {
          if (!mounted) return;
        }
      }
      setState(() => _isGeneratingMenu = false);
      String message = 'Impossible de générer le menu.';
      if (statusCode == 404) {
        message =
            'Endpoint menu groupe non disponible (POST /menu/consensus/group).';
      } else if (statusCode == 400) {
        message =
            'Le serveur n\'a pas reconnu un ou plusieurs profils (IDs invalides). '
            'Le backend doit accepter les profileIds envoyés.';
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
    final profiles = _groupProfiles;
    final participantCount = profiles.length;
    final allergies = _allergiesUnion();
    final commonPrefs = _commonPreferences();
    final commonCuisines = _intersection(profiles.map((p) => p.favoriteCuisines).toList());
    final attentionPoints = _attentionPoints();

    debugPrint('[ANALYSE_GROUP] participants: $participantCount');
    debugPrint('[ANALYSE_GROUP] allergies: $allergies');
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
                  allergiesCount: allergies.length,
                  commonCount: commonPrefs.length,
                ),
                const SizedBox(height: 24),
                _buildAllergiesSection(allergies),
                const SizedBox(height: 24),
                _buildPreferencesSection(commonPrefs),
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
          child: SizedBox(
            width: double.infinity,
            height: 44,
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
                  : const Text('Générer le menu'),
            ),
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
    required int commonCount,
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
                  value: '$commonCount',
                  label: 'Préférence commune',
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  value: '—',
                  label: 'Plats compatibles',
                  color: const Color(0xFF2196F3),
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
                  ...allergies.map((l) =>
                      _PillTag(label: l, color: const Color(0xFFD32F2F))),
                ],
              ),
      ],
    );
  }

  Widget _buildPreferencesSection(List<String> commonPrefs) {
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
        commonPrefs.isEmpty
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
                  ...commonPrefs.map((l) =>
                      _PillTag(label: l, color: const Color(0xFF4CAF50))),
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
