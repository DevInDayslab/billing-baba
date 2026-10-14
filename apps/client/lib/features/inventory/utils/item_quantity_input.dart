import 'dart:math' as math;

import 'package:flutter/services.dart';

/// Quantity typing/display aligned with Item Settings → Quantity (decimal places).
abstract final class ItemQuantityInput {
  static const int minDecimalPlaces = 0;
  static const int maxDecimalPlaces = 4;

  static int clampDecimalPlaces(int places) {
    return places.clamp(minDecimalPlaces, maxDecimalPlaces);
  }

  static TextInputFormatter formatter(int decimalPlaces) {
    return _ItemQuantityInputFormatter(clampDecimalPlaces(decimalPlaces));
  }

  static List<TextInputFormatter> formatters(int decimalPlaces) => [
    formatter(decimalPlaces),
  ];

  static double roundToPlaces(double value, int decimalPlaces) {
    final places = clampDecimalPlaces(decimalPlaces);
    if (places == 0) return value.roundToDouble();
    final factor = math.pow(10, places).toDouble();
    return (value * factor).roundToDouble() / factor;
  }

  /// Display text for quantity fields (empty when zero).
  static String formatDisplay(double value, int decimalPlaces) {
    if (value == 0) return '';
    final places = clampDecimalPlaces(decimalPlaces);
    final rounded = roundToPlaces(value, places);
    if (places == 0 || rounded == rounded.roundToDouble()) {
      return rounded.round().toString();
    }
    var text = rounded.toStringAsFixed(places);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
    return text;
  }

  /// API / persistence string for quantity values.
  static String formatStored(double value, int decimalPlaces) {
    if (value == 0) return '0';
    final places = clampDecimalPlaces(decimalPlaces);
    final rounded = roundToPlaces(value, places);
    if (places == 0 || rounded == rounded.roundToDouble()) {
      return rounded.round().toString();
    }
    return rounded.toStringAsFixed(places);
  }
}

final class _ItemQuantityInputFormatter extends TextInputFormatter {
  _ItemQuantityInputFormatter(this.maxDecimalPlaces);

  final int maxDecimalPlaces;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    if (maxDecimalPlaces == 0) {
      if (RegExp(r'^\d+$').hasMatch(text)) return newValue;
      return oldValue;
    }

    final pattern = RegExp(
      r'^\d*\.?\d{0,' + maxDecimalPlaces.toString() + r'}$',
    );
    if (pattern.hasMatch(text)) return newValue;
    return oldValue;
  }
}
