import 'package:billing_baba/core/forms/transaction_form_validation.dart';
import 'package:billing_baba/core/forms/transaction_party_link.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveValidationMessage', () {
    test('returns first failing field message', () {
      expect(
        buildTransactionValidationError(
          hasValidLineItems: true,
          hasValidPhone: false,
          requirePhone: true,
        ),
        'Phone is required',
      );

      expect(
        buildTransactionValidationError(
          hasValidLineItems: false,
          requirePhone: true,
        ),
        kLineItemsValidationMessage,
      );
    });
  });

  group('hasValidNamedLineItems', () {
    test('requires name and quantity by default', () {
      expect(
        hasValidNamedLineItems<SaleLineItem>(
          items: const [
            SaleLineItem(id: '1', itemName: 'Oil', qty: 1),
          ],
          nameOf: (item) => item.itemName,
          qtyOf: (item) => item.qty,
        ),
        isTrue,
      );

      expect(
        hasValidNamedLineItems<SaleLineItem>(
          items: const [
            SaleLineItem(id: '1', itemName: 'Oil'),
          ],
          nameOf: (item) => item.itemName,
          qtyOf: (item) => item.qty,
        ),
        isFalse,
      );
    });
  });

  group('transactionPartyHasError', () {
    test('aligns UI error with linked party requirement', () {
      expect(
        transactionPartyHasError(
          showValidationErrors: true,
          partyId: null,
          partyName: 'Demo Party',
        ),
        isTrue,
      );

      expect(
        transactionPartyHasError(
          showValidationErrors: true,
          partyId: 'party-1',
          partyName: 'Demo Party',
        ),
        isFalse,
      );
    });
  });

  group('party link helpers', () {
    test('clears party id when name changes without picker selection', () {
      expect(
        shouldClearPartyIdOnNameEdit(
          newName: 'Other Party',
          previousName: 'Demo Party',
          currentPartyId: 'party-1',
        ),
        isTrue,
      );

      expect(
        unlinkedPartyNameChange(
          newName: 'Other Party',
          previousName: 'Demo Party',
          currentPartyId: 'party-1',
        ).clearPartyId,
        isTrue,
      );
    });
  });

  group('formatLineItemQty', () {
    test('drops trailing decimal for whole numbers', () {
      expect(formatLineItemQty(0), '');
      expect(formatLineItemQty(2), '2');
      expect(formatLineItemQty(2.5), '2.5');
    });
  });
}
