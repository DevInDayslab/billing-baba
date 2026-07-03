import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/utils/validators.dart';
import 'package:billing_baba/features/business/models/create_business_input.dart';
import 'package:billing_baba/features/business/utils/create_business_validator.dart';
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
