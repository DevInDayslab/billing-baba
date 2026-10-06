import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';

/// Input decoration sized exactly for [saleFieldHeight] / form controls.
InputDecoration buildFormControlDecoration({
  String? hint,
  String? labelText,
  Widget? suffixIcon,
  Widget? suffix,
  bool hasError = false,
  bool filled = false,
  bool fixedHeight = true,
  EdgeInsetsGeometry? contentPadding,
}) {
  return buildSaleFieldDecoration(
    hint: hint,
    labelText: labelText,
    suffixIcon: suffixIcon,
    suffix: suffix,
    hasError: hasError,
    filled: filled,
    fixedHeight: fixedHeight,
    contentPadding: contentPadding,
  );
}
