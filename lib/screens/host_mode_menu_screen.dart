import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/da_colors.dart';
import 'host_mode_models.dart';

class HostModeMenuScreen extends StatelessWidget {
  const HostModeMenuScreen({
    super.key,
    required this.selectedProfiles,
    required this.menuResult,
  });

  final List<HostGuestProfile> selectedProfiles;
  final GroupMenuResult menuResult;

  @override
  Widget build(BuildContext context) {
    final totalPlats = menuResult.totalPlats;
    debugPrint('[GROUP_MENU_UI] menu reçu');
    debugPrint('[GROUP_MENU_UI] nombre plats calculé: $totalPlats');

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
                  _buildMenuGeneratedCard(platCount: totalPlats),
                  const SizedBox(height: 24),
                  _MenuCard(
                    label: 'Entrée',
                    value: menuResult.menu.starter,
                    icon: Icons.restaurant,
                  ),
                  const SizedBox(height: 12),
                  _MenuCard(
                    label: 'Plat principal',
                    value: menuResult.menu.main,
                    icon: Icons.dinner_dining,
                  ),
                  if (menuResult.menu.alternative != null &&
                      menuResult.menu.alternative!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _MenuCard(
                      label: 'Alternative',
                      value: menuResult.menu.alternative,
                      icon: Icons.restaurant_menu,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _MenuCard(
                    label: 'Dessert',
                    value: menuResult.menu.dessert,
                    icon: Icons.cake,
                  ),
                  if (menuResult.explanation.trim().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _ExplanationCard(text: menuResult.explanation),
                  ],
                  if (menuResult.adjustments.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _AdjustmentsSection(adjustments: menuResult.adjustments),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomActions(context),
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
            number: 3,
            label: 'Menu',
            isActive: true,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGeneratedCard({required int platCount}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menu généré',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$platCount plat${platCount > 1 ? 's' : ''} compatible${platCount > 1 ? 's' : ''} avec votre groupe',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onModifyGroup(BuildContext context) {
    Navigator.of(context).pop();
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _onModifyGroup(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Modifier le groupe'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Confirmer le menu'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;

  const _MenuCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final display = (value != null && value!.trim().isNotEmpty)
        ? value!.trim()
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: DAColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  display,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DAColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final String text;

  const _ExplanationCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DAColors.muted.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DAColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: Color(0xFF1976D2)),
              const SizedBox(width: 8),
              const Text(
                'Explication',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DAColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
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
}

class _AdjustmentsSection extends StatelessWidget {
  final List<String> adjustments;

  const _AdjustmentsSection({required this.adjustments});

  @override
  Widget build(BuildContext context) {
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
            'Ajustements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 12),
          ...adjustments.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
