/// Barcode format validation and confidence checks for product matching.
abstract final class BarcodeConfidence {
  static final _nonDigit = RegExp(r'\D');
  static final _barcodeLikePattern = RegExp(r'^[\d\s-]+$');

  /// Strips non-digit characters from a barcode value.
  static String normalize(String barcode) => barcode.replaceAll(_nonDigit, '');

  /// Whether [query] looks like a hardware-scanned barcode (numeric, 8+ digits).
  static bool isBarcodeLike(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return false;
    if (!_barcodeLikePattern.hasMatch(trimmed)) return false;
    return normalize(trimmed).length >= 8;
  }

  /// Whether [barcode] is eligible for Open Food Facts / Gemini lookup.
  ///
  /// External catalogs use standard GTINs, so invalid check digits are rejected.
  static bool isEligibleForExternalLookup(String barcode) {
    final digits = normalize(barcode);
    if (digits.length < 8) return false;
    return hasValidGtinChecksum(digits);
  }

  /// GS1 check-digit validation for GTIN-8/12/13/14 barcodes.
  static bool hasValidGtinChecksum(String barcode) {
    final digits = normalize(barcode);
    if (![8, 12, 13, 14].contains(digits.length)) return false;

    final body = digits.substring(0, digits.length - 1);
    final checkDigit = int.tryParse(digits[digits.length - 1]);
    if (checkDigit == null) return false;

    var sum = 0;
    for (var i = 0; i < body.length; i++) {
      final digit = int.tryParse(body[body.length - 1 - i]);
      if (digit == null) return false;
      sum += digit * (i.isEven ? 3 : 1);
    }

    final calculated = (10 - (sum % 10)) % 10;
    return calculated == checkDigit;
  }

  /// Whether [candidate] is an exact normalized match for [scanned].
  static bool isExactBarcodeMatch(String scanned, String? candidate) {
    final expected = normalize(scanned);
    if (expected.isEmpty) return false;
    final actual = normalize(candidate ?? '');
    return actual.isNotEmpty && actual == expected;
  }
}
