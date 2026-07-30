import 'dart:convert';

import 'package:billing_baba/shared/utils/jwt_utils.dart';
import 'package:flutter_test/flutter_test.dart';

String _jwt(Map<String, dynamic> claims) {
  String enc(Object value) {
    final raw = value is String ? value : jsonEncode(value);
    return base64Url.encode(utf8.encode(raw)).replaceAll('=', '');
  }

  return '${enc({'alg': 'none'})}.${enc(claims)}.sig';
}

void main() {
  // exp = 2000000000 (2033-05-18)
  const validToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjIwMDAwMDAwMDB9.signature';
  // exp = 1 (1970-01-01)
  const expiredToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjF9.signature';

  test('isExpired returns true for missing token', () {
    expect(JwtUtils.isExpired(null), isTrue);
    expect(JwtUtils.isExpired(''), isTrue);
  });

  test('isExpired detects expired JWT exp claim', () {
    expect(JwtUtils.isExpired(expiredToken), isTrue);
    expect(JwtUtils.isExpired(validToken), isFalse);
  });

  test('sessionUserId prefers user_id over account_id', () {
    final token = _jwt({
      'exp': 2000000000,
      'account_id': 'acct-1',
      'user_id': 'user-1',
    });
    expect(JwtUtils.accountId(token), 'acct-1');
    expect(JwtUtils.membershipUserId(token), 'user-1');
    expect(JwtUtils.sessionUserId(token), 'user-1');
  });

  test('sessionUserId falls back to account_id when unscoped', () {
    final token = _jwt({
      'exp': 2000000000,
      'account_id': 'acct-1',
      'phone': '919999999999',
    });
    expect(JwtUtils.sessionUserId(token), 'acct-1');
    expect(JwtUtils.phone(token), '919999999999');
    expect(JwtUtils.sessionUserId(token), isNot(equals('offline')));
  });

  test('isSameAccountCacheKey accepts account_id or membership user_id', () {
    final token = _jwt({
      'exp': 2000000000,
      'account_id': 'acct-1',
      'user_id': 'user-1',
    });

    expect(
      JwtUtils.isSameAccountCacheKey(
        cachedAccountId: 'acct-1',
        sessionUserId: 'user-1',
        accessToken: token,
      ),
      isTrue,
    );
    expect(
      JwtUtils.isSameAccountCacheKey(
        cachedAccountId: 'user-1',
        sessionUserId: 'user-1',
        accessToken: token,
      ),
      isTrue,
    );
    expect(
      JwtUtils.isSameAccountCacheKey(
        cachedAccountId: 'other',
        sessionUserId: 'user-1',
        accessToken: token,
      ),
      isFalse,
    );
    expect(
      JwtUtils.isSameAccountCacheKey(
        cachedAccountId: 'acct-1',
        sessionUserId: 'offline',
        accessToken: token,
      ),
      isTrue,
    );
  });
}
