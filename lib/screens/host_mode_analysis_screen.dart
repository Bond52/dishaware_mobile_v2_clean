import 'package:flutter/material.dart';

import '../theme/da_colors.dart';
import 'host_mode_menu_screen.dart';

class HostModeAnalysisScreen extends StatelessWidget {
  const HostModeAnalysisScreen({super.key});

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
                  _buildGroupSummaryCard(),
                  const SizedBox(height: 24),
                  _buildAllergiesSection(),
                  const SizedBox(height: 24),
                  _buildPreferencesSection(),
                  const SizedBox(height: 24),
                  _buildAttentionPointsSection(),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HostModeMenuScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Générer le menu'),
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

  Widget _buildGroupSummaryCard() {
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Résumé du groupe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: DAColors.foreground,
                    ),
                  ),
                  Text(
                    '3 invités',
                    style: TextStyle(
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
                  value: '3',
                  label: 'Allergies',
                  color: const Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  value: '1',
                  label: 'Préférence commune',
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  value: '8',
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

  Widget _buildAllergiesSection() {
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PillTag(label: 'Arachides', color: const Color(0xFFD32F2F)),
            _PillTag(label: 'Fruits à coque', color: const Color(0xFFD32F2F)),
            _PillTag(label: 'Lactose', color: const Color(0xFFD32F2F)),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PillTag(label: 'Végétarien', color: const Color(0xFF4CAF50)),
          ],
        ),
      ],
    );
  }

  Widget _buildAttentionPointsSection() {
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
          _AttentionPoint(text: '2/3 personnes végétariennes'),
          _AttentionPoint(text: 'Plusieurs allergies à considérer'),
          _AttentionPoint(text: 'Préférences de cuisine variées'),
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
