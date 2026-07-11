import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';

export 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart'
    show buildSaleFieldDecoration, saleFieldTextStyle;

/// POS panel border — matches list/inventory panels across the app.
const posCardBorder = listPanelCardBorder;

const posPositiveColor = listPanelPositiveColor;
const posNegativeColor = listPanelNegativeColor;
const posSelectedBackground = listPanelSelectedRowColor;

abstract final class PosStyles {
  static const panelTitleStyle = ListPanelStyles.panelTitleStyle;

  static const listHeaderStyle = ListPanelStyles.listHeaderStyle;

  static const emptyStateStyle = ListPanelStyles.emptyStateStyle;

  static const sectionTitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static const metadataStyle = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const priceStyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 13,
    color: AppColors.primary,
  );

  static const totalPayableStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.1,
  );

  static const itemNameStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const shortcutHintStyle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
  );
}

/// Shared button styles so POS actions use [AppColors.primary], not theme seed.
abstract final class PosButtonStyles {
  static final primaryFilled = FilledButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
  );

  static final primaryOutlined = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary),
  );
}

/// Compact filled field decoration for POS inputs.
InputDecoration buildPosFieldDecoration({
  String? hint,
  String? labelText,
  Widget? suffixIcon,
  Widget? prefixIcon,
}) {
  return buildSaleFieldDecoration(
    hint: hint,
    suffixIcon: suffixIcon,
    filled: true,
    compact: true,
  ).copyWith(
    labelText: labelText,
    labelStyle: saleFieldLabelStyle,
    prefixIcon: prefixIcon,
    fillColor: AppColors.background,
  );
}
