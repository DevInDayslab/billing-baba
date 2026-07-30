import 'package:billing_baba/shared/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lead form validators', () {
    test('leadOwnerName allows empty optional value', () {
      expect(Validators.leadOwnerName(''), isNull);
      expect(Validators.leadOwnerName('   '), isNull);
    });

    test('leadOwnerName rejects invalid characters', () {
      expect(
        Validators.leadOwnerName('Test%%'),
        "Lead owner can only contain letters, numbers, spaces, and . & ' - ( ) , /",
      );
    });

    test('leadFirstName allows empty optional value', () {
      expect(Validators.leadFirstName(null), isNull);
    });

    test('leadFirstName rejects invalid characters', () {
      expect(
        Validators.leadFirstName('Saksham%%'),
        "First name can only contain letters, numbers, spaces, and . & ' - ( ) , /",
      );
    });

    test('leadLastName requires a value', () {
      expect(
        Validators.leadLastName(''),
        'Last name is required',
      );
    });

    test('leadLastName rejects invalid characters', () {
      expect(
        Validators.leadLastName('Kochhar%%'),
        "Last name can only contain letters, numbers, spaces, and . & ' - ( ) , /",
      );
    });

    test('leadCompany requires a value', () {
      expect(
        Validators.leadCompany(''),
        'Company is required',
      );
    });

    test('leadCompany rejects invalid characters', () {
      expect(
        Validators.leadCompany('Test%%'),
        "Company can only contain letters, numbers, spaces, and . & ' - ( ) , /",
      );
    });

    test('leadCompany accepts common business names', () {
      expect(Validators.leadCompany("M/s Sharma & Sons (Retail)"), isNull);
    });

    test('requiredPhone rejects non-numeric input', () {
      expect(
        Validators.requiredPhone('fuhuishduhkfdshjvhjfdjvhjh'),
        'Enter a valid 10 digit phone number',
      );
    });

    test('requiredPhone rejects partial numbers', () {
      expect(
        Validators.requiredPhone('12345'),
        'Enter a valid 10 digit phone number',
      );
    });

    test('requiredPhone accepts valid 10 digit number', () {
      expect(Validators.requiredPhone('9876543210'), isNull);
    });

    test('phone allows empty optional mobile', () {
      expect(Validators.phone(''), isNull);
    });

    test('phone rejects invalid mobile numbers', () {
      expect(
        Validators.phone('dhnjkjvbjdsbhbvfhb'),
        'Phone number must contain exactly 10 digits.',
      );
    });
  });
}
