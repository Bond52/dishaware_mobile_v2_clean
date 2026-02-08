import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import 'steps/onboarding_step_1.dart';
import 'steps/onboarding_step_2.dart';
import 'steps/onboarding_step_3.dart';
import 'steps/onboarding_step_4.dart';
import 'steps/onboarding_step_5.dart';
import 'steps/onboarding_step_6.dart';
import 'steps/onboarding_step_7.dart';
import 'steps/onboarding_step_8.dart';
import 'steps/onboarding_step_9.dart';
import 'steps/onboarding_step_10.dart';
import 'steps/onboarding_step_11.dart';
import 'steps/onboarding_step_12.dart';
import 'steps/onboarding_step_13.dart';

class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _buildStep(onboardingProvider.currentStep),
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 1:
        return const OnboardingStep1();
      case 2:
        return const OnboardingStep2();
      case 3:
        return const OnboardingStep3();
      case 4:
        return const OnboardingStep4();
      case 5:
        return const OnboardingStep5();
      case 6:
        return const OnboardingStep6();
      case 7:
        return const OnboardingStep7();
      case 8:
        return const OnboardingStep8();
      case 9:
        return const OnboardingStep9();
      case 10:
        return const OnboardingStep10();
      case 11:
        return const OnboardingStep11();
      case 12:
        return const OnboardingStep12();
      case 13:
      default:
        return const OnboardingStep13();
    }
  }
}
