import 'package:flutter/material.dart';

/// Billing Baba purple design system color tokens.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF6338E0);
  static const secondary = Color(0xFF5B4FCF);
  static const accent = Color(0xFF6B4CE6);
  static const tabActiveTint = Color(0xFFF5F1FF);

  // Semantic
  static const success = Color(0xFF2E7D32);
  static const successSoft = Color(0xFFE8F5E9);
  static const warning = Color(0xFFEF6C00);
  static const warningSoft = Color(0xFFFFF3E0);
  static const danger = Color(0xFFD32F2F);
  static const dangerSoft = Color(0xFFFFEBEE);

  // Surfaces
  static const background = Color(0xFFF8F9FB);
  static const surface = Color(0xFFFFFFFF);
  static const Color error = danger;

  // Text
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);

  // UI chrome
  static const divider = Color(0xFFE8ECF1);
  /// Outer frame and split dividers for desktop workspace panels (inventory, parties).
  static const workspacePanelBorder = Color(0xFFCFDBE6);
  static const chipBackground = Color(0xFFF0F1F5);
  static const chipInactive = Color(0xFFF0F1F5);
  static const chipBorder = Color(0xFFE2E8F0);
  static const iconBackground = Color(0xFFF3F4F8);
  static const navInactive = Color(0xFF9E9E9E);
}

/// Semantic colors exposed via [ThemeData] extensions.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.accent,
    required this.chartGradientStart,
    required this.chartGradientEnd,
  });

  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color accent;
  final Color chartGradientStart;
  final Color chartGradientEnd;

  static const light = AppSemanticColors(
    success: AppColors.success,
    successSoft: AppColors.successSoft,
    warning: AppColors.warning,
    warningSoft: AppColors.warningSoft,
    danger: AppColors.danger,
    dangerSoft: AppColors.dangerSoft,
    accent: AppColors.accent,
    chartGradientStart: Color(0xFF6338E0),
    chartGradientEnd: Color(0xFF8B6AE8),
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? danger,
    Color? dangerSoft,
    Color? accent,
    Color? chartGradientStart,
    Color? chartGradientEnd,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      accent: accent ?? this.accent,
      chartGradientStart: chartGradientStart ?? this.chartGradientStart,
      chartGradientEnd: chartGradientEnd ?? this.chartGradientEnd,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      chartGradientStart: Color.lerp(
        chartGradientStart,
        other.chartGradientStart,
        t,
      )!,
      chartGradientEnd: Color.lerp(
        chartGradientEnd,
        other.chartGradientEnd,
        t,
      )!,
    );
  }
}

extension AppSemanticColorsX on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
