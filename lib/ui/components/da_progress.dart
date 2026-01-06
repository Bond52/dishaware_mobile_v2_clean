import 'package:flutter/material.dart';
import '../../theme/da_colors.dart';

class DAProgress extends StatelessWidget {
  final double value; // 0.0 → 1.0
  final String? label;

  const DAProgress({
    super.key,
    required this.value,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: DAColors.muted,
            valueColor: const AlwaysStoppedAnimation(DAColors.primary),
          ),
        ),
      ],
    );
  }
}
