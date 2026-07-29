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

  /// Account UUID from the API access token (`account_id` claim).
  static String? accountId(String? token) {
    if (token == null || token.isEmpty) return null;
    final payload = decodePayload(token);
    final id = payload?['account_id'];
    if (id == null) return null;
    final value = id.toString().trim();
    return value.isEmpty ? null : value;
  }

  /// Membership user UUID when the token is business-scoped (`user_id` claim).
  static String? membershipUserId(String? token) {
    if (token == null || token.isEmpty) return null;
    final payload = decodePayload(token);
    final id = payload?['user_id'];
    if (id == null) return null;
    final value = id.toString().trim();
    return value.isEmpty ? null : value;
  }

  /// Stable session user id matching API `buildUserResponse`:
  /// membership `user_id` when present, otherwise `account_id`.
  static String? sessionUserId(String? token) =>
      membershipUserId(token) ?? accountId(token);

  static String? phone(String? token) {
    if (token == null || token.isEmpty) return null;
    final payload = decodePayload(token);
    final value = payload?['phone'];
    if (value == null) return null;
    final phone = value.toString().trim();
    return phone.isEmpty ? null : phone;
  }

  /// Whether [cachedAccountId] belongs to the same account as the session.
  ///
  /// Cache keys historically used either `account_id` or membership/`user.id`;
  /// treat all of those as the same account so offline restore never wipes the list.
  static bool isSameAccountCacheKey({
    required String cachedAccountId,
    required String? sessionUserId,
    String? accessToken,
  }) {
    if (cachedAccountId.isEmpty) return false;
    if (sessionUserId == 'offline') return true;
    if (sessionUserId != null &&
        sessionUserId.isNotEmpty &&
        cachedAccountId == sessionUserId) {
      return true;
    }
    final account = accountId(accessToken);
    if (account != null && cachedAccountId == account) return true;
    final membership = membershipUserId(accessToken);
    if (membership != null && cachedAccountId == membership) return true;
    return false;
  }

  /// Returns true when the JWT `exp` claim is in the past (with optional leeway).
  static bool isExpired(
    String? token, {
    Duration leeway = const Duration(seconds: 30),
  }) {
    if (token == null || token.isEmpty) return true;

    final payload = decodePayload(token);
    final exp = payload?['exp'];
    if (exp is! num) return false;

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      exp.toInt() * 1000,
      isUtc: true,
    );
    return DateTime.now().toUtc().add(leeway).isAfter(expiresAt);
  }
}
