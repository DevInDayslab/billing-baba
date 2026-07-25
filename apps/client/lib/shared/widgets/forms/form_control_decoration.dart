import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/shared/widgets/forms/form_spacing.dart';
import 'package:flutter/material.dart';

/// Input decoration sized exactly for [FormSpacing.inputHeight] controls.
InputDecoration buildFormControlDecoration({
  String? hint,
  Widget? suffixIcon,
  Widget? suffix,
  bool hasError = false,
  bool filled = false,
}) {
  // font 14 + borders ≈ 22; remaining vertical pad fills 44px control height.
  const verticalPad = (FormSpacing.inputHeight - 22) / 2;

  return buildSaleFieldDecoration(
    hint: hint,
    suffixIcon: suffixIcon,
    suffix: suffix,
    hasError: hasError,
    filled: filled,
  ).copyWith(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: verticalPad,
    ),
  );
}
