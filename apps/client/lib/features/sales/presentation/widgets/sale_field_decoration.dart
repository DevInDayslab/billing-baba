import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const saleFieldBorderColor = Color(0xFFE0E0E0);
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
}) {
  final borderColor = hasError ? saleFieldErrorColor : saleFieldBorderColor;
  final focusedBorderColor = hasError
      ? saleFieldErrorColor
      : saleFieldFocusColor;

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: Colors.grey.shade400,
      fontSize: compact ? 13 : 14,
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: compact ? 8 : 12,
      vertical: compact ? 6 : 10,
    ),
    isDense: true,
    filled: filled,
    fillColor: filled ? const Color(0xFFF9F9F9) : null,
    suffixIcon: suffixIcon,
    suffix: suffix,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: saleFieldErrorColor),
    ),
  );
}

/// Trigger shell for picker/dropdown fields that mirrors [buildSaleFieldDecoration].
class SaleFieldTrigger extends StatelessWidget {
  const SaleFieldTrigger({
    required this.child,
    required this.onTap,
    this.hasError = false,
    this.compact = false,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool hasError;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 6 : 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: hasError ? saleFieldErrorColor : saleFieldBorderColor,
          ),
        ),
        child: child,
      ),
    );
  }
}
