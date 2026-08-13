import 'package:flutter/material.dart';

/// Clears zero-like decimal placeholders when a field gains focus.
abstract final class ClearZeroDecimalOnFocus {
  static bool isZeroDecimal(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final parsed = double.tryParse(trimmed.replaceAll(',', ''));
    return parsed != null && parsed == 0;
  }

  static void bind({
    required TextEditingController controller,
    required FocusNode focusNode,
  }) {
    focusNode.addListener(() {
      if (focusNode.hasFocus && isZeroDecimal(controller.text)) {
        controller.clear();
      }
    });
  }
}
