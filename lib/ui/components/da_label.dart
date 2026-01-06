import 'package:flutter/material.dart';
import '../../theme/da_colors.dart';

class DALabel extends StatelessWidget {
  final String text;

  const DALabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: DAColors.foreground,
      ),
    );
  }
}
