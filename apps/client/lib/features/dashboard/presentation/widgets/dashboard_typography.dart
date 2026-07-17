import 'package:billing_baba/core/layout/dashboard_layout.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Fixed dashboard typography — no viewport scaling.
abstract final class DashboardTypography {
  static const TextStyle pageTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.subtitleSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.subtitleSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle sideWidgetTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.bodySize,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle kpiValue = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.headlineSize,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle mainValue = kpiValue;

  static const TextStyle sideWidgetValue = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.titleSize,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  static const TextStyle chartValue = kpiValue;

  static const TextStyle supportingLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.bodySize,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle metadata = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.captionSize,
    color: AppColors.textSecondary,
  );

  static const TextStyle link = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.captionSize,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle tabLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.bodySize,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle supportStrip = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.captionSize,
    color: AppColors.textSecondary,
  );

  static const TextStyle supportStripLink = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: AppTypography.captionSize,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );
}

abstract final class DashboardColors {
  static const incoming = Color(0xFF2E7D32);
  static const outgoing = Color(0xFFC62828);
  static const incomingBg = Color(0xFFE8F5E9);
  static const outgoingBg = Color(0xFFFCE4EC);
  static const divider = Color(0xFFEEEEEE);
  static const border = Color(0xFFE0E0E0);
}

abstract final class DashboardDecor {
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(
        alpha: DashboardLayout.cardShadowOpacity,
      ),
      blurRadius: DashboardLayout.cardShadowBlur,
    ),
  ];

  static BorderRadius get cardRadius =>
      BorderRadius.circular(DashboardLayout.cardRadius);
}

/// Fixed chrome heights for dashboard shell widgets.
abstract final class DashboardSpacing {
  static const double headerGap = AppSpacing.sm;
  static const double widgetGap = AppSpacing.sm;
  static const double topBarHeight = DashboardLayout.topBarHeight;
  static const double tabBarHeight = DashboardLayout.tabBarHeight;
  static const double supportStripHeight = DashboardLayout.supportStripHeight;
}
