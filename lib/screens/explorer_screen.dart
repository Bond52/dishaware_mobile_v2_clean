import 'package:flutter/material.dart';

import '../theme/da_colors.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorer les plats'), elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: DAColors.muted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search,
                  size: 40,
                  color: DAColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Explorer les plats',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: DAColors.foreground,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Recherchez parmi des centaines de plats adaptés à vos besoins',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: DAColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                ),
                child: const Text(
                  'Cette fonctionnalité sera disponible prochainement',
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
      ),
    );
  }
}
