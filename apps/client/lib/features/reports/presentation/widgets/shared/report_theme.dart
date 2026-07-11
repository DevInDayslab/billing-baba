import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const reportCardBorder = Color(0xFFE0E0E0);
const reportAddRed = Color(0xFFE53935);
const reportTeal = Color(0xFF00695C);
const reportActiveBlue = Color(0xFF1976D2);
const reportSummaryTint = Color(0xFFF4F7F9);
const reportTableHeaderBg = Color(0xFFF5F7FA);
const reportFooterBlue = Color(0xFF1A60FF);

const TextStyle reportTableHeaderStyle = TextStyle(
  fontFamily: AppTypography.fontFamily,
  fontSize: AppTypography.labelMediumSize,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
  letterSpacing: 0.4,
);

const TextStyle reportTableDataStyle = TextStyle(
  fontFamily: AppTypography.fontFamily,
  fontSize: AppTypography.bodySmallSize,
  color: AppColors.textPrimary,
);
