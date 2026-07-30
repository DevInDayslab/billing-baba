/// Parses API decimal fields that may arrive as JSON strings or numbers.
String decimalStringFromJson(Object? value) {
  if (value == null) return '0';
  if (value is String) return value;
  if (value is num) return value.toString();
  return value.toString();
}

/// Nullable variant of [decimalStringFromJson].
String? nullableDecimalStringFromJson(Object? value) {
  if (value == null) return null;
  return decimalStringFromJson(value);
}
