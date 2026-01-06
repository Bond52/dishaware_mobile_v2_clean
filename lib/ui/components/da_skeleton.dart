import 'package:flutter/material.dart';
import '../../theme/da_colors.dart';

class DASkeleton extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? radius;

  const DASkeleton({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: DAColors.muted,
        borderRadius: radius ?? BorderRadius.circular(8),
      ),
    );
  }
}
