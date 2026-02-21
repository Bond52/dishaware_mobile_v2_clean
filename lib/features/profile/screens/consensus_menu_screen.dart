import 'package:flutter/material.dart';
import '../../../theme/da_colors.dart';
import '../models/consensus_menu.dart';

class ConsensusMenuScreen extends StatelessWidget {
  final ConsensusMenu menu;

  const ConsensusMenuScreen({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu consensus'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MenuCard(
              icon: Icons.restaurant,
              title: 'Entrée',
              value: menu.starter,
            ),
            const SizedBox(height: 12),
            _MenuCard(
              icon: Icons.dinner_dining,
              title: 'Plat principal',
              value: menu.main,
            ),
            const SizedBox(height: 12),
            if (menu.alternative.isNotEmpty) ...[
              _MenuCard(
                icon: Icons.restaurant_menu,
                title: 'Alternative',
                value: menu.alternative,
              ),
              const SizedBox(height: 12),
            ],
            _MenuCard(
              icon: Icons.cake,
              title: 'Dessert',
              value: menu.dessert,
            ),
            const SizedBox(height: 20),
            if (menu.explanation.isNotEmpty) ...[
              _SectionTitle(icon: Icons.info_outline, title: 'Explication'),
              const SizedBox(height: 8),
              _InfoCard(text: menu.explanation),
              const SizedBox(height: 20),
            ],
            if (menu.adjustmentA.isNotEmpty || menu.adjustmentB.isNotEmpty) ...[
              _SectionTitle(icon: Icons.tune, title: 'Ajustements'),
              const SizedBox(height: 8),
              if (menu.adjustmentA.isNotEmpty)
                _AdjustmentCard(label: 'Profil A', text: menu.adjustmentA),
              if (menu.adjustmentA.isNotEmpty && menu.adjustmentB.isNotEmpty)
                const SizedBox(height: 8),
              if (menu.adjustmentB.isNotEmpty)
                _AdjustmentCard(label: 'Profil B', text: menu.adjustmentB),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1BEE7).withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DAColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: DAColors.foreground,
                    height: 1.35,
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DAColors.foreground,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String text;

  const _InfoCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1BEE7).withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.45,
          color: DAColors.foreground,
        ),
      ),
    );
  }
}

class _AdjustmentCard extends StatelessWidget {
  final String label;
  final String text;

  const _AdjustmentCard({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: DAColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
