import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const inventoryCardBorder = Color(0xFFE0E0E0);
const inventoryTabActiveColor = Color(0xFF1565C0);
const inventoryPrimaryOrange = Color(0xFFFF9800);
const inventorySelectedRowColor = Color(0xFFE3F2FD);
const inventoryNegativeColor = Color(0xFFD32F2F);
const inventoryPositiveColor = Color(0xFF2E7D32);

abstract final class InventoryStyles {
  static const listHeaderStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const panelTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static const emptyStateStyle = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}
