import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared typography and spacing for dashboard cards.
abstract final class DashboardTypography {
  static const TextStyle pageTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.headlineMediumSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.titleMediumSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle mainValue = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.displayMediumSize,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle supportingLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.labelLargeSize,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle metadata = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.labelMediumSize,
    color: AppColors.textSecondary,
  );

  static const TextStyle link = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.bodySmallSize,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );
}

abstract final class DashboardSpacing {
  static const double cardPadding = AppSpacing.lg;
  static const double widgetGap = 20;
  static const double sectionGap = AppSpacing.lg;
  static const double titleToValue = AppSpacing.md;
  static const double valueToContent = AppSpacing.md;
  static const double headerGap = AppSpacing.md;
}

abstract final class DashboardColors {
  static const incoming = Color(0xFF2E7D32);
  static const outgoing = Color(0xFFC62828);
}
