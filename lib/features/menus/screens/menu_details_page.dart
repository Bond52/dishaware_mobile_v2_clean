import 'package:flutter/material.dart';
import '../../../theme/da_colors.dart';
import '../domain/ai_menu.dart';

class MenuDetailsPage extends StatelessWidget {
  final AiMenu menu;

  const MenuDetailsPage({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu personnalisé'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuItemCard(item: menu.entree),
          const SizedBox(height: 12),
          _MenuItemCard(item: menu.plat),
          const SizedBox(height: 12),
          _MenuItemCard(item: menu.dessert),
          const SizedBox(height: 16),
          Text(
            'Total estimé : ${menu.totalCalories} kcal',
            style: const TextStyle(
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

class _MenuItemCard extends StatelessWidget {
  final AiMenuItem? item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEBFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item!.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C6FE3),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '≈ ${item!.calories} kcal',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A5FD3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item!.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DAColors.foreground,
            ),
          ),
          if (item!.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item!.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: DAColors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
