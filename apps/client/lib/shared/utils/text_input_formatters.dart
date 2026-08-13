import 'package:flutter/services.dart';

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
