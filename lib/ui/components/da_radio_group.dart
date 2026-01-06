import 'package:flutter/material.dart';
import '../../theme/da_colors.dart';

class DARadioGroup<T> extends StatelessWidget {
  final T value;
  final List<T> options;
  final ValueChanged<T?> onChanged;
  final String Function(T) labelBuilder;

  const DARadioGroup({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        return RadioListTile<T>(
          value: option,
          groupValue: value,
          onChanged: onChanged,
          activeColor: DAColors.primary,
          title: Text(
            labelBuilder(option),
            style: const TextStyle(fontSize: 14),
          ),
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }
}
