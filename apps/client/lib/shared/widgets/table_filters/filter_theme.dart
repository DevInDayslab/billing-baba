import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared visual tokens for table filter popovers — matches existing Sales UI.
abstract final class TableFilterTheme {
  static const popoverBorder = Color(0xFFE0E0E0);
  static const popoverElevation = 8.0;
  static const popoverShadowColor = Color(0x1A000000);
  static const clearButtonBg = Color(0xFFEEEEEE);
  static const hoverColor = Color(0xFFF5F5F5);

  /// Soft blue tint for dropdown option hover / selected states.
  static final Color optionHoverColor = AppColors.primary.withValues(
    alpha: 0.08,
  );
  static final Color optionSelectedColor = AppColors.primary.withValues(
    alpha: 0.12,
  );
  static const fieldHeight = 36.0;
  static const popoverWidth = 260.0;
  static const amountPopoverWidth = 280.0;
  static const datePopoverWidth = 300.0;
  static const selectPopoverWidth = 220.0;
  static const checkboxPopoverWidth = 240.0;

  static const defaultPopoverHeight = 220.0;
  static const datePopoverHeight = 320.0;
  static const multiSelectPopoverHeight = 300.0;
  static const rangeSliderPopoverHeight = 260.0;
  static const booleanPopoverHeight = 200.0;

  static const defaultHeaderStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const sectionLabelStyle = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const fieldTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static InputDecoration fieldDecoration({
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? prefixText,
    Widget? prefixWidget,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary.withValues(alpha: 0.75),
      ),
      prefixText: prefixText,
      prefixStyle: fieldTextStyle,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: const BorderSide(color: popoverBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: const BorderSide(color: popoverBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      suffixIcon: suffixIcon,
    );
  }
}
