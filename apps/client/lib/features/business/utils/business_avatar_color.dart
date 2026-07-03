import 'package:flutter/material.dart';

/// Deterministic avatar background from a business id or name.
Color businessAvatarColor(String seed) {
  const palette = [
    Color(0xFF1976D2),
    Color(0xFF388E3C),
    Color(0xFF7B1FA2),
    Color(0xFFD32F2F),
    Color(0xFFF57C00),
    Color(0xFF0097A7),
    Color(0xFF5D4037),
    Color(0xFF455A64),
  ];

  var hash = 0;
  for (final unit in seed.codeUnits) {
    hash = (hash + unit) & 0x7fffffff;
  }
  return palette[hash % palette.length];
}
