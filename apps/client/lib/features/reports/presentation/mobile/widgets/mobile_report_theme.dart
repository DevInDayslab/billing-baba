import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared visual tokens for mobile report screens.
abstract final class MobileReportTheme {
  static const accent = AppColors.primary;
  static const accentSoft = Color(0xFFE3F2FD);
  static const metricsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8F4FD),
      Color(0xFFF0F7FF),
      Color(0xFFEAF2FB),
    ],
  );
  static const chipBackground = Color(0xFFF1F5F9);
  static const chipBorder = Color(0xFFE2E8F0);
  static const divider = Color(0xFFE8ECF1);
  static const iconTint = Color(0xFF5D5FEF);
  static const iconBackground = Color(0xFFF3F4F8);
  static const exportCa = Color(0xFF1976D2);
  static const exportPdf = Color(0xFFE53935);
  static const exportExcel = Color(0xFF2E7D32);
  static const positive = Color(0xFF2E7D32);
  static const negative = Color(0xFFE53935);

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];
}
