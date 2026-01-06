import 'package:flutter/material.dart';
import '../../theme/da_colors.dart';

class DASwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  const DASwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: DAColors.foreground,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: DAColors.primary,
        ),
      ],
    );
  }
}
