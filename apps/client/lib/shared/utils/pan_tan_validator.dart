final _panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
final _tanPattern = RegExp(r'^[A-Z]{4}[0-9]{5}[A-Z]$');

bool isValidPan(String? value) {
  if (value == null || value.trim().isEmpty) return true;
  return _panPattern.hasMatch(value.trim().toUpperCase());
}

bool isValidTan(String? value) {
  if (value == null || value.trim().isEmpty) return true;
  return _tanPattern.hasMatch(value.trim().toUpperCase());
}
