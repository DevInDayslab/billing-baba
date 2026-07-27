import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Visual tokens for the mobile notifications screen (reference-matched).
abstract final class MobileNotificationsTheme {
  static const headerBackground = AppColors.surface;

  /// Light blue body background (#EBF5FF).
  static const contentBackground = Color(0xFFEBF5FF);

  /// Raspberry-red accent for tabs and CTA (#E84855).
  static const accentRed = Color(0xFFE84855);

  /// Active tab blush fill (#FFF3F3).
  static const activeTabBackground = Color(0xFFFFF3F3);

  /// Inactive tab border (#E2E6EC).
  static const inactiveTabBorder = Color(0xFFE2E6EC);

  /// Inactive tab label (#8B939E).
  static const inactiveTabText = Color(0xFF8B939E);

  /// Empty-state icon (#A8B0BB).
  static const emptyIcon = Color(0xFFA8B0BB);

  /// Empty-state message (#8B939E).
  static const emptyMessage = Color(0xFF8B939E);

  static const double appBarTitleSize = 20;
  static const FontWeight appBarTitleWeight = FontWeight.w600;

  static const double tabFontSize = 13;
  static const FontWeight tabFontWeight = FontWeight.w600;
  static const double tabBorderWidth = 1;

  static const double bannerRadius = 16;
  static const double bannerShadowBlur = 8;
  static const double bannerShadowYOffset = 2;
  static const double bannerShadowOpacity = 0.06;

  static const double enableButtonRadius = 12;
  static const double enableButtonMinHeight = 40;
  static const double enableButtonFontSize = 12;

  static const double bannerTitleSize = 16;
  static const FontWeight bannerTitleWeight = FontWeight.w600;

  static const double emptyCircleSize = 96;
  static const double emptyIconSize = 42;
  static const double emptyMessageSize = 15;

  static const EdgeInsets screenHorizontalPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
  );

  static const EdgeInsets tabSectionPadding = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.sm,
    AppSpacing.lg,
    AppSpacing.lg,
  );

  static const EdgeInsets bannerOuterPadding = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.lg,
    AppSpacing.lg,
    0,
  );

  static const EdgeInsets bannerInnerPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: 14,
  );

  static List<BoxShadow> get bannerShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: bannerShadowOpacity),
      blurRadius: bannerShadowBlur,
      offset: const Offset(0, bannerShadowYOffset),
    ),
  ];
}
