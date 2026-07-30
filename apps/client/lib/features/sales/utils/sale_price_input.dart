import 'package:flutter/services.dart';

/// Shared price input helpers for sales line-item tables.
abstract final class SalePriceInput {
  static final List<TextInputFormatter> formatters = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
  ];

  static const TextInputType keyboardType = TextInputType.numberWithOptions(
    decimal: true,
  );

  static double parse(String value) => double.tryParse(value.trim()) ?? 0;

  static String format(double price, {String zeroValue = ''}) {
    if (price == 0) return zeroValue;
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }
    return price.toString();
  }
}
