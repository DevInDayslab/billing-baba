import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design token placeholders — finalize values from Figma.
abstract final class AppColors {
  static const primary = Color(0xFF1565C0);
  static const secondary = Color(0xFF455A64);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFD32F2F);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

/// Typography placeholders — finalize from Figma design tokens.
abstract final class AppTypography {
  static TextTheme get textTheme =>
      GoogleFonts.interTextTheme(ThemeData.light().textTheme);
}

/// Spacing design tokens.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Border radius design tokens.
abstract final class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;

  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get lgBorder => BorderRadius.circular(lg);
  static BorderRadius get xlBorder => BorderRadius.circular(xl);
}

/// Application theme configuration.
abstract final class AppTheme {
  static ThemeData get light => FlexThemeData.light(
    scheme: FlexScheme.material,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    textTheme: AppTypography.textTheme,
  );

  static ThemeData get dark => FlexThemeData.dark(
    scheme: FlexScheme.material,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: AppTypography.textTheme,
  );
}
