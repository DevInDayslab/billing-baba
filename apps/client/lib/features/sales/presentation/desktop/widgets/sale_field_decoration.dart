import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const saleFieldBorderColor = Color(0xFFE0E0E0);
const saleCompactFieldBorderColor = Color(0xFFBDBDBD);

/// Compact table-cell / header control height (qty, price, invoice header).
const saleCompactFieldHeight = 30.0;

/// Standard form control height — TextField and select/dropdown triggers share
/// this so sale/purchase invoice forms and party edit dialogs look consistent.
const saleFieldHeight = 36.0;

const _compactBorderRadius = 4.0;
const saleFieldFocusColor = Color(0xFF42A5F5);
const saleFieldErrorColor = Color(0xFFD32F2F);
const saleFieldTextStyle = TextStyle(
  fontSize: 14,
  color: AppColors.textPrimary,
);
const saleFieldLabelStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w500,
  color: AppColors.textSecondary,
);

/// Compact Vyapar-style field decoration shared across the Add Sale page.
InputDecoration buildSaleFieldDecoration({
  String? hint,
  Widget? suffixIcon,
  Widget? suffix,
  bool hasError = false,
  bool filled = false,
  bool compact = false,
  bool borderless = false,
}) {
  final fieldHeight = compact ? saleCompactFieldHeight : saleFieldHeight;
  // fontSize 14 ≈ 14px glyph; +2 border; remainder is vertical padding.
  final verticalPadding = (fieldHeight - 14 - 2) / 2;

  if (borderless) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: compact ? 12 : 14,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 12,
        vertical: compact ? 8 : verticalPadding,
      ),
      isDense: true,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      suffixIcon: suffixIcon,
      suffix: suffix,
    );
  }

  final borderColor = hasError
      ? saleFieldErrorColor
      : (compact ? saleCompactFieldBorderColor : saleFieldBorderColor);
  final focusedBorderColor = hasError
      ? saleFieldErrorColor
      : saleFieldFocusColor;
  final borderRadius = compact ? _compactBorderRadius : 6.0;

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: Colors.grey.shade400,
      fontSize: compact ? 12 : 14,
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: compact ? 6 : 12,
      vertical: compact ? (saleCompactFieldHeight - 12 - 2) / 2 : verticalPadding,
    ),
    isDense: true,
    constraints: BoxConstraints.tightFor(height: fieldHeight),
    filled: compact || filled,
    fillColor: compact
        ? Colors.white
        : (filled ? const Color(0xFFF9F9F9) : null),
    suffixIcon: suffixIcon,
    suffix: suffix,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: const BorderSide(color: saleFieldErrorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: const BorderSide(color: saleFieldErrorColor, width: 1.5),
    ),
  );
}

/// Fixed-height shell so compact text fields, dropdowns, and date triggers align.
class SaleCompactFieldBox extends StatelessWidget {
  const SaleCompactFieldBox({
    required this.child,
    this.width,
    super.key,
  });

  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      height: saleCompactFieldHeight,
      child: child,
    );

    if (width != null) {
      return SizedBox(width: width, child: field);
    }
    return field;
  }
}

/// Trigger shell for picker/dropdown fields that mirrors [buildSaleFieldDecoration].
class SaleFieldTrigger extends StatelessWidget {
  const SaleFieldTrigger({
    required this.child,
    required this.onTap,
    this.hasError = false,
    this.compact = false,
    this.borderless = false,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool hasError;
  final bool compact;
  final bool borderless;

  @override
  Widget build(BuildContext context) {
    final fieldHeight = compact ? saleCompactFieldHeight : saleFieldHeight;

    if (borderless) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: SizedBox(
            width: double.infinity,
            height: fieldHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: fieldHeight,
        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 12),
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: compact ? Colors.white : null,
          borderRadius: BorderRadius.circular(
            compact ? _compactBorderRadius : 6,
          ),
          border: Border.all(
            color: hasError
                ? saleFieldErrorColor
                : (compact
                      ? saleCompactFieldBorderColor
                      : saleFieldBorderColor),
          ),
        ),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }
}
