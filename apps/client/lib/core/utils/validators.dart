/// Common form field validators.
abstract final class Validators {
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? requiredSelection(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final pattern = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Invalid email address';
    }
    return null;
  }

  static String? requiredPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return 'Enter a valid 10 digit phone number';
    }
    return null;
  }

  static String? gstin(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length != 15) {
      return 'GSTIN must be exactly 15 characters';
    }
    return null;
  }

  static String? gstinMaxLength(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 15) {
      return 'GSTIN must be at most 15 characters';
    }
    return null;
  }

  static String? pincode(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = normalizePincode(value) ?? '';
    if (digits.length != 6) {
      return 'Pincode must be exactly 6 digits.';
    }
    return null;
  }

  /// Kept for optional phone fields elsewhere in the app.
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = normalizeIndianPhone(value);
    if (normalized == null || normalized.length != 10) {
      return 'Phone number must contain exactly 10 digits.';
    }
    return null;
  }

  /// Returns a 10-digit Indian mobile number when possible.
  static String? normalizeIndianPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (digits.length == 10) return digits;
    if (digits.length == 12 && digits.startsWith('91')) {
      return digits.substring(2);
    }
    if (digits.length > 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  static String? normalizePincode(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? null : digits;
  }
}
