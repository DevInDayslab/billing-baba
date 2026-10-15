import 'package:billing_baba/shared/utils/validate_ifsc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validateIfsc accepts valid code', () {
    expect(validateIfsc('HDFC0001234'), isTrue);
    expect(normalizeIfsc('hdfc0001234'), 'HDFC0001234');
  });

  test('validateIfsc rejects invalid code', () {
    expect(validateIfsc('HDFC001234'), isFalse);
  });
}
