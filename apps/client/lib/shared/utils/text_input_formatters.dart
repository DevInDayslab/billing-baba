import 'package:billing_baba/shared/constants/item_price_limits.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Opening balance, credit limit, loyalty points, and similar amount fields.
final nonNegativeDecimalInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'^\d*\.?\d*'),
);

/// Formats monetary and price fields with Indian-style grouping (en_IN) while typing.
const indianDecimalInputFormatter = IndianDecimalInputFormatter();

/// Item pricing fields — capped at [ItemPriceLimits.maxAmount] (99,99,99,999 rupees).
const indianItemPriceInputFormatter = IndianDecimalInputFormatter(
  maxAmount: ItemPriceLimits.maxAmount,
  maxWholeDigitCount: 9,
);

/// Parses a display value with Indian commas into a [double] (0 when empty/invalid).
double parseIndianDecimalInput(String value) =>
    double.tryParse(Validators.normalizeDecimalString(value) ?? '') ?? 0;

double parseIndianItemPriceInput(String value) =>
    ItemPriceLimits.clamp(parseIndianDecimalInput(value));

/// Formats a numeric value for price/amount text fields (Indian grouping).
String formatIndianDecimalInput(double value) {
  final isWhole = value == value.truncateToDouble();
  final raw = isWhole ? value.toInt().toString() : value.toString();
  return IndianDecimalInputFormatter.formatCleanedDecimal(raw);
}

String formatIndianItemPriceInput(double value) =>
    formatIndianDecimalInput(ItemPriceLimits.clamp(value));

final class IndianDecimalInputFormatter extends TextInputFormatter {
  const IndianDecimalInputFormatter({
    this.maxDecimalDigits = 4,
    this.maxAmount,
    this.maxWholeDigitCount,
  });

  final int maxDecimalDigits;
  final double? maxAmount;
  final int? maxWholeDigitCount;

  static final _integerFormat = NumberFormat('#,##,##0', 'en_IN');

  static final _partialPattern = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text.replaceAll(',', '');
    if (cleaned.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }
    if (!_partialPattern.hasMatch(cleaned)) {
      return oldValue;
    }

    final parts = cleaned.split('.');
    if (parts.length > 2) return oldValue;
    final intPart = parts[0];
    final decimalPart = parts.length == 2 ? parts[1] : null;
    if (decimalPart != null && decimalPart.length > maxDecimalDigits) {
      return oldValue;
    }
    if (maxWholeDigitCount != null &&
        intPart.isNotEmpty &&
        intPart.length > maxWholeDigitCount!) {
      return oldValue;
    }
    final parsed = double.tryParse(cleaned);
    if (parsed != null && maxAmount != null && parsed > maxAmount!) {
      return oldValue;
    }

    final formatted = formatCleanedDecimal(cleaned);
    final digitIndex = _digitsBeforeCursor(newValue.text, newValue.selection.end);
    final offset = _cursorForDigitIndex(formatted, digitIndex);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }

  static String formatCleanedDecimal(String cleaned) {
    if (cleaned.isEmpty) return '';

    final parts = cleaned.split('.');
    final intPart = parts[0];
    final decimalPart = parts.length == 2 ? parts[1] : null;
    final endsWithDot = cleaned.endsWith('.');

    if (intPart.isEmpty) {
      if (decimalPart != null) return '.$decimalPart';
      if (endsWithDot) return '.';
      return '';
    }

    final intValue = int.tryParse(intPart) ?? 0;
    final intFormatted = _integerFormat.format(intValue);

    if (endsWithDot && decimalPart == null) return '$intFormatted.';
    if (decimalPart != null) return '$intFormatted.$decimalPart';
    return intFormatted;
  }

  static int _digitsBeforeCursor(String text, int cursor) {
    final end = cursor.clamp(0, text.length);
    return text.substring(0, end).replaceAll(',', '').length;
  }

  static int _cursorForDigitIndex(String formatted, int digitIndex) {
    if (digitIndex <= 0) return 0;
    var digits = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (formatted[i] != ',') {
        digits++;
        if (digits >= digitIndex) return i + 1;
      }
    }
    return formatted.length;
  }
}

/// GSTIN field formatters: uppercase, alphanumeric only, max 15 chars.
final gstinInputFormatters = <TextInputFormatter>[
  UpperCaseTextFormatter(),
  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
  LengthLimitingTextInputFormatter(15),
];

/// Forces alphabetic GSTIN input to uppercase while preserving the cursor.
final class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Uppercases the first character as the user types (matches save-time naming).
final class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  const CapitalizeFirstLetterFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final first = text[0];
    final upperFirst = first.toUpperCase();
    if (first == upperFirst) return newValue;

    return TextEditingValue(
      text: '$upperFirst${text.substring(1)}',
      selection: newValue.selection,
      composing: newValue.composing,
    );
  }
}
