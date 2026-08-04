import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Vyapar-aligned colors and decorations for mobile Add Item.
abstract final class MobileAddItemTheme {
  static const saveRed = Color(0xFFE53935);
  static const tabActiveRed = Color(0xFFD32F2F);
  /// Matches form surface so section gaps do not show as sky-blue bands.
  static const Color sectionBand = AppColors.surface;
  static const fieldBorder = Color(0xFFBDBDBD);
  static const inlineButtonBg = Color(0xFFE3F2FD);
  static const inlineButtonText = Color(0xFF1976D2);

  static const fieldRadius = 4.0;
  static const horizontalPadding = 16.0;
  static const fieldSpacing = 12.0;
  static const sectionSpacing = 8.0;

  static InputDecoration fieldDecoration({
    String? label,
    String? hint,
    Widget? suffix,
    Widget? suffixIcon,
    bool hasError = false,
    int maxLines = 1,
  }) {
    final borderColor = hasError ? AppColors.error : fieldBorder;
    final focusedColor = hasError ? AppColors.error : AppColors.primary;

    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.7),
        fontSize: 14,
      ),
      labelStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: maxLines > 1 ? 14 : 12,
      ),
      suffix: suffix,
      suffixIcon: suffixIcon,
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(focusedColor, width: 1.5),
      errorBorder: border(AppColors.error, width: 1.5),
      focusedErrorBorder: border(AppColors.error, width: 1.5),
    );
  }

  static ButtonStyle inlineActionStyle() {
    return TextButton.styleFrom(
      foregroundColor: inlineButtonText,
      backgroundColor: inlineButtonBg,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static Widget sectionBandDivider() {
    return const ColoredBox(
      color: sectionBand,
      child: SizedBox(height: sectionSpacing),
    );
  }

  static Widget sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
