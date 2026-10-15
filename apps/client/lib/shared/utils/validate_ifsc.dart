bool validateIfsc(String? value) {
  if (value == null || value.trim().isEmpty) return true;
  return RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value.trim().toUpperCase());
}

String normalizeIfsc(String value) => value.trim().toUpperCase();
