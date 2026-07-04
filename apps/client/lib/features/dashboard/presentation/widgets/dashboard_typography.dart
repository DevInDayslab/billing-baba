import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared typography and spacing for dashboard cards.
abstract final class DashboardTypography {
  static const pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const mainValue = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const supportingLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const metadata = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const link = TextStyle(
    fontSize: 13,
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
