import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InventoryErrorMapper.validationMessage', () {
    test('returns field-specific barcode message', () {
      const error = ApiValidationException(
        message: 'Invalid request body',
        fieldErrors: {
          'barcode': 'An item with this barcode already exists',
        },
      );

      expect(
        InventoryErrorMapper.validationMessage(error),
        'Barcode / item code: An item with this barcode already exists',
      );
    });

    test('returns multiple field messages in priority order', () {
      const error = ApiValidationException(
        message: 'Invalid request body',
        fieldErrors: {
          'opening_quantity': 'Opening quantity must be zero or more',
          'name': 'Item name is required',
        },
      );

      expect(
        InventoryErrorMapper.validationMessage(error),
        'Item name is required\n'
            'Opening quantity must be zero or more',
      );
    });
  });

  group('InventoryErrorMapper.messageForSaveItem', () {
    test('maps inventory exception message directly', () {
      expect(
        InventoryErrorMapper.messageForSaveItem(
          const InventoryException('Please select a base unit.'),
        ),
        'Please select a base unit.',
      );
    });

    test('maps offline exception to connection message', () {
      expect(
        InventoryErrorMapper.messageForSaveItem(
          const InventoryOfflineException(),
        ),
        contains("You're offline"),
      );
    });
  });
}
