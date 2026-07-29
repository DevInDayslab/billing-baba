import 'package:billing_baba/shared/utils/jwt_utils.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
