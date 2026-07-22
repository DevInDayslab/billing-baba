/// Masks sensitive values before they are written to logs.
abstract final class LogSanitizer {
  static const _sensitiveHeaderKeys = {
    'authorization',
    'cookie',
    'x-api-key',
    'x-auth-token',
  };

  static const _sensitiveBodyKeys = {
    'otp',
    'password',
    'access_token',
    'access-token',
    'accesstoken',
    'refresh_token',
    'refresh-token',
    'token',
    'secret',
    'reqid',
    'req_id',
  };

  static Map<String, String> sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, String>{};
    for (final entry in headers.entries) {
      final key = entry.key;
      final value = entry.value?.toString() ?? '';
      if (_sensitiveHeaderKeys.contains(key.toLowerCase())) {
        sanitized[key] = _maskToken(value);
      } else {
        sanitized[key] = value;
      }
    }
    return sanitized;
  }

  static String sanitizeBody(Object? body) {
    if (body == null) return '(empty)';
    if (body is Map) {
      return _sanitizeMap(body).toString();
    }
    if (body is List) {
      return body.map(_sanitizeValue).toList().toString();
    }
    return _sanitizeValue(body).toString();
  }

  static String truncate(String value, {int maxLength = 500}) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}…(${value.length} chars total)';
  }

  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) return '****';
    if (digits.length <= 10) {
      return '${digits.substring(0, 2)}****${digits.substring(digits.length - 4)}';
    }
    return '${digits.substring(0, 2)}****${digits.substring(digits.length - 4)}';
  }

  static String _maskToken(String value) {
    if (value.isEmpty) return '(empty)';
    const bearerPrefix = 'Bearer ';
    if (value.startsWith(bearerPrefix)) {
      return '$bearerPrefix${_mask(value.substring(bearerPrefix.length))}';
    }
    return _mask(value);
  }

  static String _mask(String value) {
    if (value.length <= 8) return '***';
    return '${value.substring(0, 4)}…${value.substring(value.length - 4)}';
  }

  static Map<String, dynamic> _sanitizeMap(Map<dynamic, dynamic> map) {
    final sanitized = <String, dynamic>{};
    for (final entry in map.entries) {
      final key = entry.key.toString();
      if (_sensitiveBodyKeys.contains(key.toLowerCase())) {
        sanitized[key] = '***';
      } else if (entry.value is Map) {
        sanitized[key] = _sanitizeMap(entry.value as Map<dynamic, dynamic>);
      } else {
        sanitized[key] = _sanitizeValue(entry.value);
      }
    }
    return sanitized;
  }

  static Object? _sanitizeValue(Object? value) {
    if (value is Map) return _sanitizeMap(value);
    if (value is List) return value.map(_sanitizeValue).toList();
    return value;
  }
}
