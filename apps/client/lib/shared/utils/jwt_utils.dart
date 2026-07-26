import 'dart:convert';

/// Lightweight JWT payload decoding for client-side diagnostics only.
abstract final class JwtUtils {
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      var payload = parts[1];
      final padding = (4 - payload.length % 4) % 4;
      if (padding > 0) {
        payload = '$payload${'=' * padding}';
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      final json = jsonDecode(decoded);
      if (json is! Map<String, dynamic>) return null;
      return json;
    } on Object {
      return null;
    }
  }

  static String? businessId(String? token) {
    if (token == null || token.isEmpty) return null;
    final payload = decodePayload(token);
    final id = payload?['business_id'];
    if (id == null) return null;
    final value = id.toString().trim();
    return value.isEmpty ? null : value;
  }

  static String? role(String? token) {
    if (token == null || token.isEmpty) return null;
    final payload = decodePayload(token);
    final value = payload?['role'];
    if (value == null) return null;
    return value.toString();
  }
}
