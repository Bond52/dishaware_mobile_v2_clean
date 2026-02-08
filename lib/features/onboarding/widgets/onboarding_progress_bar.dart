import 'package:flutter/material.dart';
import '../../../ui/components/da_progress.dart';
class OnboardingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep / totalSteps).clamp(0.0, 1.0);
    return DAProgress(
      value: progress,
      label: 'Étape $currentStep sur $totalSteps',
    );
  }
}
