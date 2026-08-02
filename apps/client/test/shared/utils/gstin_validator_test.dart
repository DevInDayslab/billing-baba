import 'package:billing_baba/shared/utils/gstin_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Correct checksum for 27AABCU9603R1Z prefix (plan PAN; M is invalid checksum).
  const validGstin = '27AABCU9603R1ZN';

  group('GstinValidator', () {
    test('valid GSTIN', () {
      expect(GstinValidator.isValid(validGstin), isTrue);
      expect(GstinValidator.validationError(validGstin), isNull);
    });

    test('empty string', () {
      expect(GstinValidator.isValid(''), isFalse);
      expect(
        GstinValidator.validationError(''),
        'GSTIN cannot be empty',
      );
    });

    test('too short', () {
      expect(GstinValidator.isValid('123412341234'), isFalse);
      expect(
        GstinValidator.validationError('123412341234'),
        'GSTIN must contain exactly 15 characters',
      );
    });

    test('too long', () {
      expect(GstinValidator.isValid('1234123412341234'), isFalse);
      expect(
        GstinValidator.validationError('1234123412341234'),
        'GSTIN must contain exactly 15 characters',
      );
    });

    test('invalid regex', () {
      expect(GstinValidator.isValid('47AAGCG4576J1A6'), isFalse);
      expect(
        GstinValidator.validationError('47AAGCG4576J1A6'),
        'Invalid GSTIN format',
      );
    });

    test('invalid state code', () {
      expect(GstinValidator.isValid('99AABCU9603R1ZM'), isFalse);
      expect(
        GstinValidator.validationError('99AABCU9603R1ZM'),
        'Invalid state code',
      );
    });

    test('invalid checksum', () {
      expect(GstinValidator.isValid('27AABCU9603R1Z8'), isFalse);
      expect(
        GstinValidator.validationError('27AABCU9603R1Z8'),
        'Invalid GSTIN checksum',
      );
    });

    test('lowercase input normalizes to valid', () {
      expect(GstinValidator.isValid('27aabCU9603R1ZN'), isTrue);
    });

    test('leading and trailing spaces normalize to valid', () {
      expect(GstinValidator.isValid(' 27AABCU9603R1ZN '), isTrue);
    });

    test('calculateChecksum matches expected character', () {
      expect(GstinValidator.calculateChecksum('27AABCU9603R1Z'), 'N');
      expect(
        validGstin[14],
        GstinValidator.calculateChecksum(validGstin.substring(0, 14)),
      );
    });
  });
}
