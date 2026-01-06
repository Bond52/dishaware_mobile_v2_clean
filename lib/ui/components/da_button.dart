import 'package:flutter/material.dart';
import '../../theme/da_colors.dart';

enum DAButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
}

class DAButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DAButtonVariant variant;
  final bool fullWidth;

  const DAButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DAButtonVariant.primary,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    Color background;
    Color foreground;
    BorderSide? border;

    switch (variant) {
      case DAButtonVariant.secondary:
        background = DAColors.secondary;
        foreground = DAColors.secondaryForeground;
        break;
      case DAButtonVariant.outline:
        background = Colors.transparent;
        foreground = DAColors.primary;
        border = const BorderSide(color: DAColors.border);
        break;
      case DAButtonVariant.ghost:
        background = Colors.transparent;
        foreground = DAColors.primary;
        break;
      case DAButtonVariant.destructive:
        background = DAColors.destructive;
        foreground = DAColors.destructiveForeground;
        break;
      case DAButtonVariant.primary:
      default:
        background = DAColors.primary;
        foreground = DAColors.primaryForeground;
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: border ?? BorderSide.none,
          ),
          disabledBackgroundColor: background.withOpacity(0.4),
        ),
        child: Text(label),
      ),
    );
  }
}
