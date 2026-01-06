import 'package:flutter/material.dart';
import 'da_colors.dart';
import 'da_typography.dart';

class DATheme {
  static const double radius = 10; // 0.625rem ≈ 10px

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: DAColors.background,
      colorScheme: const ColorScheme.light(
        primary: DAColors.primary,
        secondary: DAColors.secondary,
        error: DAColors.destructive,
        background: DAColors.background,
      ),
      textTheme: DATypography.textTheme,
   cardTheme: CardThemeData(
  color: DAColors.card,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
    side: const BorderSide(color: DAColors.border),
  ),
),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DAColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: DAColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: DAColors.border,
        thickness: 1,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: DAColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: DAColors.darkPrimary,
        secondary: DAColors.darkSecondary,
        error: DAColors.destructive,
        background: DAColors.darkBackground,
      ),
      textTheme: DATypography.textTheme.apply(
        bodyColor: DAColors.darkForeground,
        displayColor: DAColors.darkForeground,
      ),
 cardTheme: CardThemeData(
  color: DAColors.card,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
    side: const BorderSide(color: DAColors.border),
  ),
),

    );
  }
}
