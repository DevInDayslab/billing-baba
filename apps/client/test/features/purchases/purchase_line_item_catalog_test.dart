import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/utils/purchase_line_item_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('selectCatalogItemOnPurchaseLines', () {
    PurchaseLineItem line({
      required String id,
      String? itemId,
      String itemName = '',
      double qty = 0,
    }) {
      return PurchaseLineItem(
        id: id,
        itemId: itemId,
        itemName: itemName,
        qty: qty,
        pricePerUnit: 50,
      );
    }

    test('clubs duplicate item into existing row', () {
      final items = [
        line(id: 'a', itemId: 'item-1', itemName: 'Bolt', qty: 4),
        line(id: 'b'),
      ];
      final applied = line(
        id: 'b',
        itemId: 'item-1',
        itemName: 'Bolt',
        qty: 1,
      );

      final result = selectCatalogItemOnPurchaseLines(
        items: items,
        targetIndex: 1,
        appliedLine: applied,
        nextLineId: () => 'new',
      );

      expect(result[0].qty, 5);
      expect(result, hasLength(2));
      expect(isEmptyPurchaseLineDraft(result[1]), isTrue);
    });

    test('creates new line when product is unique', () {
      final items = [line(id: 'a')];
      final applied = line(
        id: 'a',
        itemId: 'item-9',
        itemName: 'Nut',
        qty: 2,
      );

      final result = selectCatalogItemOnPurchaseLines(
        items: items,
        targetIndex: 0,
        appliedLine: applied,
        nextLineId: () => 'new',
      );

      expect(result[0].itemId, 'item-9');
      expect(result[0].qty, 2);
      expect(result, hasLength(2));
    });
  });
}
