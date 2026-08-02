import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/features/business/models/create_business_input.dart';
import 'package:billing_baba/features/business/utils/create_business_validator.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('required rejects empty business name', () {
      expect(
        Validators.required('', fieldName: 'Business name'),
        'Business name is required',
      );
    });

    test('businessName rejects invalid characters', () {
      expect(
        Validators.businessName('Test@Shop'),
        "Business name can only contain letters, numbers, spaces, and . & ' - ( ) , /",
      );
    });

    test('businessName rejects names longer than 200 characters', () {
      expect(
        Validators.businessName('A' * 201),
        'Business name must be at most 200 characters',
      );
    });

    test('businessName accepts common punctuation', () {
      expect(
        Validators.businessName("M/s Sharma & Sons (Retail)"),
        isNull,
      );
    });

    test('ownerName rejects invalid characters', () {
      expect(
        Validators.ownerName('John@Doe'),
        "Owner name can only contain letters, numbers, spaces, and . & ' - ( ) , /",
      );
    });

    test('ownerName rejects names longer than 200 characters', () {
      expect(
        Validators.ownerName('A' * 201),
        'Owner name must be at most 200 characters',
      );
    });

    test('ownerName accepts hyphenated names', () {
      expect(Validators.ownerName('Ramesh Kumar-Sharma'), isNull);
    });

    test('partyName rejects invalid characters', () {
      expect(
        Validators.partyName(r'$^#%E^%*&E'),
        "Party name can only contain letters, numbers, spaces, and . & ' - ( ) , /",
      );
    });

    test('partyName rejects names longer than 200 characters', () {
      expect(
        Validators.partyName('A' * 201),
        'Party name must be at most 200 characters',
      );
    });

    test('partyName accepts common business names', () {
      expect(Validators.partyName('Sharma Traders & Co.'), isNull);
    });

    test('requiredPhone rejects invalid phone', () {
      expect(
        Validators.requiredPhone('12345'),
        'Enter a valid 10 digit phone number',
      );
    });

    test('email rejects invalid format', () {
      expect(Validators.email('not-an-email'), 'Invalid email address');
    });

    test('gstin rejects wrong length', () {
      expect(Validators.gstin('SHORT'), 'GSTIN must be exactly 15 characters');
    });

    test('gstin accepts empty optional value', () {
      expect(Validators.gstin(''), isNull);
    });

    test('upiId rejects invalid format', () {
      expect(Validators.upiId('invalid'), 'UPI ID must look like name@bank');
    });

    test('upiId accepts valid handle', () {
      expect(Validators.upiId('merchant@upi'), isNull);
    });
  });

  group('CreateBusinessValidator', () {
    test('collects multiple client-side errors', () {
      final errors = CreateBusinessValidator.validate(
        const CreateBusinessInput(
          name: '',
          ownerName: '',
          phone: '123',
          businessType: '',
          state: '',
          currency: '',
        ),
      );

      expect(errors['name'], isNotNull);
      expect(errors['owner_name'], isNotNull);
      expect(errors['phone'], isNotNull);
      expect(errors['business_type'], isNotNull);
      expect(errors['state'], isNotNull);
      expect(errors['currency'], isNotNull);
    });

    test('rejects invalid email format', () {
      final errors = CreateBusinessValidator.validate(
        const CreateBusinessInput(
          name: 'Test Co',
          ownerName: 'Owner',
          phone: '9876543210',
          email: 'not-an-email',
          businessType: 'Retail',
          state: 'Delhi',
          currency: 'INR',
        ),
      );

      expect(errors['email'], 'Invalid email address');
    });

    test('allows empty optional email', () {
      final errors = CreateBusinessValidator.validate(
        const CreateBusinessInput(
          name: 'Test Co',
          ownerName: 'Owner',
          phone: '9876543210',
          businessType: 'Retail',
          state: 'Delhi',
          currency: 'INR',
        ),
      );

      expect(errors['email'], isNull);
    });
  });

  group('ApiErrorParser', () {
    test('maps validation errors from API response', () {
      final exception = ApiErrorParser.parseValidation(
        DioException(
          requestOptions: RequestOptions(path: '/businesses'),
          response: Response(
            requestOptions: RequestOptions(path: '/businesses'),
            statusCode: 400,
            data: {
              'success': false,
              'message': 'Invalid request body',
              'code': 'VALIDATION_ERROR',
              'errors': {
                'gstin': ['Too big: expected string to have <=15 characters'],
              },
            },
          ),
        ),
      );

      expect(exception, isNotNull);
      expect(
        exception!.fieldErrors['gstin'],
        'Too big: expected string to have <=15 characters',
      );
    });
  });
}
