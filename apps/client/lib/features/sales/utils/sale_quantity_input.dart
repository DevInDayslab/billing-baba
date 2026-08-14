import 'package:flutter/services.dart';

/// Shared quantity input helpers for sales forms (integer quantities only).
abstract final class SaleQuantityInput {
  static final List<TextInputFormatter> integerFormatters = [
    FilteringTextInputFormatter.digitsOnly,
  ];

  static final List<TextInputFormatter> decimalFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
  ];

  static const TextInputType integerKeyboardType = TextInputType.number;

  static const TextInputType decimalKeyboardType =
      TextInputType.numberWithOptions(
        decimal: true,
      );

  static double parse(String value) {
    final parsed = int.tryParse(value.trim());
    return (parsed ?? 0).toDouble();
  }

  static String format(double qty, {String zeroValue = ''}) {
    if (qty == 0) return zeroValue;
    return qty.truncate().toString();
  }
}
