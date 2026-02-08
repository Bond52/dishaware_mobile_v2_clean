import 'package:flutter/material.dart';
import '../../theme/da_colors.dart';

enum DABadgeVariant {
  defaultBadge,
  secondary,
  success,      // ✅ AJOUT SANS RÉGRESSION
  destructive,
  outline,
}

class DABadge extends StatelessWidget {
  final String label;
  final DABadgeVariant variant;

  const DABadge({
    super.key,
    required this.label,
    this.variant = DABadgeVariant.defaultBadge,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    BorderSide? border;

    switch (variant) {
      case DABadgeVariant.success:
        // ✅ SAFE : même rendu que secondary pour l’instant
        background = DAColors.secondary;
        foreground = DAColors.secondaryForeground;
        break;

      case DABadgeVariant.secondary:
        background = DAColors.secondary;
        foreground = DAColors.secondaryForeground;
        break;

      case DABadgeVariant.destructive:
        background = DAColors.destructive.withOpacity(0.1);
        foreground = DAColors.destructive;
        break;

      case DABadgeVariant.outline:
        background = Colors.transparent;
        foreground = DAColors.primary;
        border = const BorderSide(color: DAColors.border);
        break;

      case DABadgeVariant.defaultBadge:
      default:
        background = DAColors.muted;
        foreground = DAColors.foreground;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: border != null ? Border.fromBorderSide(border) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}
