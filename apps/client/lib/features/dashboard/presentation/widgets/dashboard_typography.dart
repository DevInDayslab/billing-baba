import 'package:billing_baba/core/layout/dashboard_layout.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Fixed desktop typography for the dashboard (never scales with viewport).
abstract final class DashboardTypography {
  static const double titleSize = 16;
  static const double valueSize = 24;
  static const double subtitleSize = 13;
  static const double smallLabelSize = 12;

  static const TextStyle pageTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: titleSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: titleSize,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle sideWidgetTitle = cardTitle;

  static const TextStyle kpiValue = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: valueSize,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle mainValue = kpiValue;
  static const TextStyle sideWidgetValue = kpiValue;
  static const TextStyle chartValue = kpiValue;

  static const TextStyle supportingLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: subtitleSize,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle metadata = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: smallLabelSize,
    color: AppColors.textSecondary,
  );

  static const TextStyle link = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: smallLabelSize,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle tabLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: subtitleSize,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle supportStrip = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: smallLabelSize,
    color: AppColors.textSecondary,
  );

  static const TextStyle supportStripLink = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: smallLabelSize,
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

/// Legacy spacing alias — prefer [DashboardLayoutScope.of].
abstract final class DashboardSpacing {
  static const double headerGap = AppSpacing.sm;
  static const double widgetGap = AppSpacing.sm;
  static double get topBarHeight => DashboardLayout.referenceHeight *
      DashboardLayout.topBarHeightRatio;
  static double get tabBarHeight => DashboardLayout.referenceHeight *
      DashboardLayout.tabBarHeightRatio;
  static double get supportStripHeight => DashboardLayout.referenceHeight *
      DashboardLayout.supportStripHeightRatio;
}
