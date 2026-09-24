import 'package:flutter/services.dart';

/// Opening balance, credit limit, loyalty points, and similar amount fields.
final nonNegativeDecimalInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'^\d*\.?\d*'),
);

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
