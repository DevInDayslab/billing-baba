import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';

/// Input decoration sized exactly for [saleFieldHeight] / form controls.
InputDecoration buildFormControlDecoration({
  String? hint,
  Widget? suffixIcon,
  Widget? suffix,
  bool hasError = false,
  bool filled = false,
}) {
  return buildSaleFieldDecoration(
    hint: hint,
    suffixIcon: suffixIcon,
    suffix: suffix,
    hasError: hasError,
    filled: filled,
  );
}
