import 'package:flutter/material.dart';
import '../../theme/da_colors.dart';

class DAAvatar extends StatelessWidget {
  final String name;
  final double size;

  const DAAvatar({
    super.key,
    required this.name,
    this.size = 48,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: DAColors.accent,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size / 2.5,
          fontWeight: FontWeight.w600,
          color: DAColors.foreground,
        ),
      ),
    );
  }
}
