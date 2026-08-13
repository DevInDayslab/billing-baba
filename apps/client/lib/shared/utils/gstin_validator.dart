/// GSTIN validation using the official GST mod-36 checksum algorithm.
///
/// Checksum logic ported from the GSTN reference implementation
/// (gstin-validator / GSTIN_Validation_SampleCode).
abstract final class GstinValidator {
  static const _codepointChars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  static final _pattern = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
  );

  static const _errorEmpty = 'GSTIN cannot be empty';
  static const _errorLength = 'GSTIN must contain exactly 15 characters';
  static const _errorFormat = 'Invalid GSTIN format';
  static const _errorStateCode = 'Invalid state code';
  static const _errorChecksum = 'Invalid GSTIN checksum';

  static String normalize(String gstin) => gstin.trim().toUpperCase();

  static bool isValid(String gstin) => validate(gstin).isValid;

  static String? validationError(String gstin) => validate(gstin).error;

  static GstinValidationResult validate(String gstin) {
    final trimmed = gstin.trim();
    if (trimmed.isEmpty) {
      return const GstinValidationResult(isValid: false, error: _errorEmpty);
    }

    final normalized = trimmed.toUpperCase();
    if (normalized.length != 15) {
      return const GstinValidationResult(
        isValid: false,
        error: _errorLength,
      );
    }

    if (!validatePattern(normalized)) {
      return const GstinValidationResult(isValid: false, error: _errorFormat);
    }

    if (!validateStateCode(normalized)) {
      return const GstinValidationResult(
        isValid: false,
        error: _errorStateCode,
      );
    }

    return const GstinValidationResult(isValid: true);
  }

  /// Full validation including mod-36 checksum (optional; not used on save).
  static GstinValidationResult validateStrict(String gstin) {
    final structural = validate(gstin);
    if (!structural.isValid) return structural;

    final normalized = normalize(gstin);
    if (!validateChecksum(normalized)) {
      return const GstinValidationResult(
        isValid: false,
        error: _errorChecksum,
      );
    }

    return const GstinValidationResult(isValid: true);
  }

  static bool isStrictlyValid(String gstin) => validateStrict(gstin).isValid;

  static bool validatePattern(String gstin) => _pattern.hasMatch(gstin);

  static bool validateStateCode(String gstin) {
    if (gstin.length < 2) return false;
    final code = int.tryParse(gstin.substring(0, 2));
    if (code == null) return false;
    return code >= 1 && code <= 38;
  }

  static bool validateChecksum(String gstin) {
    if (gstin.length != 15) return false;
    return gstin[14] == calculateChecksum(gstin.substring(0, 14));
  }

  static String calculateChecksum(String gstin14Chars) {
    const mod = _codepointChars.length;
    var factor = 2;
    var sum = 0;
    // Reference algorithm sums indices 0..length-2 on a 15-character GSTIN.
    final lastIndex = gstin14Chars.length >= 15
        ? gstin14Chars.length - 2
        : gstin14Chars.length - 1;

    for (var i = lastIndex; i >= 0; i--) {
      final char = gstin14Chars[i];
      final codePoint = _codepointChars.indexOf(char);
      if (codePoint < 0) {
        throw ArgumentError('Invalid character in GSTIN: $char');
      }

      var digit = factor * codePoint;
      factor = factor == 2 ? 1 : 2;
      digit = (digit ~/ mod) + (digit % mod);
      sum += digit;
    }

    final checkCodePoint = (mod - (sum % mod)) % mod;
    return _codepointChars[checkCodePoint];
  }
}

class GstinValidationResult {
  const GstinValidationResult({required this.isValid, this.error});

  final bool isValid;
  final String? error;
}
