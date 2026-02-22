import 'package:flutter/material.dart';

import '../services/profile_share_service.dart';
import '../utils/translate_value.dart';
import '../theme/da_colors.dart';
import '../ui/components/da_card.dart';
import 'host_mode_analysis_screen.dart';
import 'host_mode_models.dart';

class HostModeGuestsScreen extends StatefulWidget {
  const HostModeGuestsScreen({super.key});

  @override
  State<HostModeGuestsScreen> createState() => _HostModeGuestsScreenState();
}

class _HostModeGuestsScreenState extends State<HostModeGuestsScreen> {
  List<HostGuestProfile> _selectedProfiles = [];

  /// Charge les profils partagés depuis GET /profile-shares/received/me (données enrichies, pas d'appel GET /profiles/:id).
  Future<List<HostGuestProfile>> _loadAvailableProfiles() async {
    final sharedProfiles = await ProfileShareService.getReceivedShares();
    return sharedProfiles.map((r) => HostGuestProfile(
      userId: r.userId,
      profileId: r.profileId,
      fullName: r.firstName,
      initials: r.initials,
      allergies: r.allergies,
      diets: r.diets,
      favoriteCuisines: r.favoriteCuisines,
    )).toList();
  }

  void _onAddGuests() async {
    final available = await _loadAvailableProfiles();
    if (!mounted) return;
    final selectedIds = _selectedProfiles.map((p) => p.userId).toSet();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddGuestsSheet(
        available: available,
        initialSelectedIds: selectedIds,
        onConfirm: (list) {
          setState(() => _selectedProfiles = list);
          Navigator.pop(ctx);
        },
      ),
    );
  }

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
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImportCard(),
                  const SizedBox(height: 24),
                  _buildGuestsHeader(),
                  const SizedBox(height: 16),
                  ..._selectedProfiles.map((guest) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GuestCard(
                        name: guest.fullName,
                        allergies: guest.allergies,
                        preferences: [...guest.diets, ...guest.favoriteCuisines],
                      ),
                    );
                  }),
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
                onPressed: _selectedProfiles.length >= 1
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => HostModeAnalysisScreen(
                              selectedProfiles: _selectedProfiles,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  disabledForegroundColor: const Color(0xFF9E9E9E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Analyser le groupe'),
              ),
            ),
          ),
        ],
      ),
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
          _StepIndicator(number: 1, label: 'Invités', isActive: true),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFFE0E0E0),
            ),
          ),
          _StepIndicator(number: 2, label: 'Analyse', isActive: false),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFFE0E0E0),
            ),
          ),
          _StepIndicator(number: 3, label: 'Menu', isActive: false),
        ],
      ),
    );
  }

  Widget _buildImportCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.file_upload, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Importer des profils',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DAColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoutez les profils culinaires de vos invités pour générer un menu adapté à tous',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DAColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Parcourir les fichiers'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Invités ajoutés (${_selectedProfiles.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
        TextButton(
          onPressed: _onAddGuests,
          child: const Text(
            '+ Ajouter',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4CAF50),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddGuestsSheet extends StatefulWidget {
  final List<HostGuestProfile> available;
  final Set<String> initialSelectedIds;
  final void Function(List<HostGuestProfile>) onConfirm;

  const _AddGuestsSheet({
    required this.available,
    required this.initialSelectedIds,
    required this.onConfirm,
  });

  @override
  State<_AddGuestsSheet> createState() => _AddGuestsSheetState();
}

class _AddGuestsSheetState extends State<_AddGuestsSheet> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DAColors.muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sélectionner des invités',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ),
              ),
              Expanded(
                child: widget.available.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun profil partagé avec vous.',
                          style: TextStyle(color: DAColors.mutedForeground),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: widget.available.length,
                        itemBuilder: (_, i) {
                          final p = widget.available[i];
                          final selected = _selectedIds.contains(p.userId);
                          return CheckboxListTile(
                            value: selected,
                            onChanged: (_) {
                              setState(() {
                                if (selected) {
                                  _selectedIds.remove(p.userId);
                                } else {
                                  _selectedIds.add(p.userId);
                                }
                              });
                            },
                            title: Text(
                              p.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: DAColors.foreground,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (p.allergies.isNotEmpty)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        size: 14,
                                        color: Color(0xFFD32F2F),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          p.allergies.map(translateValue).join(', '),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFD32F2F),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (p.diets.isNotEmpty)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: Color(0xFF4CAF50),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          p.diets.map(translateValue).join(', '),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF4CAF50),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            secondary: CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFF4CAF50),
                              child: Text(
                                p.initials,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            activeColor: const Color(0xFF4CAF50),
                          );
                        },
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        final list = widget.available
                            .where((p) => _selectedIds.contains(p.userId))
                            .toList();
                        widget.onConfirm(list);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Valider'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;

  const _StepIndicator({
    required this.number,
    required this.label,
    required this.isActive,
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
            color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF9E9E9E),
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
            color: isActive ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}

class _GuestCard extends StatelessWidget {
  final String name;
  final List<String> allergies;
  final List<String> preferences;

  const _GuestCard({
    required this.name,
    required this.allergies,
    required this.preferences,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return DACard(
      padding: const EdgeInsets.all(16),
      onTap: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF4CAF50),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ),
                if (allergies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Color(0xFFD32F2F),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          allergies.map(translateValue).join(', '),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (preferences.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          preferences.map(translateValue).join(', '),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
