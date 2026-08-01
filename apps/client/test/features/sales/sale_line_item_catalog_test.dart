import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/utils/sale_line_item_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('preserveCatalogFieldsOnStaleLineUpdate', () {
    test('keeps catalog price when stale qty update drops itemId', () {
      const current = SaleLineItem(
        id: 'line-1',
        itemId: 'item-1',
        itemName: 'CASHEW',
        qty: 12,
        unit: 'PCS',
        pricePerUnit: 250,
        catalogUnitPrice: 250,
      );
      const incoming = SaleLineItem(
        id: 'line-1',
        itemName: 'CASHEW',
        qty: 12,
        unit: 'NONE',
        pricePerUnit: 0,
      );

      final merged = preserveCatalogFieldsOnStaleLineUpdate(current, incoming);

      expect(merged.itemId, 'item-1');
      expect(merged.pricePerUnit, 250);
      expect(merged.unit, 'PCS');
      expect(merged.qty, 12);
    });

    test('does not preserve when item name changes', () {
      const current = SaleLineItem(
        id: 'line-1',
        itemId: 'item-1',
        itemName: 'CASHEW',
        pricePerUnit: 250,
      );
      const incoming = SaleLineItem(
        id: 'line-1',
        itemName: 'ALMOND',
        qty: 1,
      );

      final merged = preserveCatalogFieldsOnStaleLineUpdate(current, incoming);

      expect(merged.itemId, isNull);
      expect(merged.pricePerUnit, 0);
    });
  });

  group('selectCatalogItemOnSaleLines', () {
    SaleLineItem line({
      required String id,
      String? itemId,
      String itemName = '',
      double qty = 0,
      String serialNo = '',
      String batchNo = '',
    }) {
      return SaleLineItem(
        id: id,
        itemId: itemId,
        itemName: itemName,
        qty: qty,
        serialNo: serialNo,
        batchNo: batchNo,
        pricePerUnit: 100,
      );
    }

    test('clubs duplicate item into existing row', () {
      final items = [
        line(id: 'a', itemId: 'item-1', itemName: 'Widget', qty: 2),
        line(id: 'b'),
      ];

      final applied = line(
        id: 'b',
        itemId: 'item-1',
        itemName: 'Widget',
        qty: 1,
      );

      final result = selectCatalogItemOnSaleLines(
        items: items,
        targetIndex: 1,
        appliedLine: applied,
        nextLineId: () => 'new',
      );

      expect(result, hasLength(2));
      expect(result[0].qty, 3);
      expect(result[0].itemId, 'item-1');
      expect(isEmptySaleLineDraft(result[1]), isTrue);
    });

    test('creates new line when product is unique', () {
      final items = [line(id: 'a'), line(id: 'b')];
      final applied = line(
        id: 'b',
        itemId: 'item-2',
        itemName: 'Gadget',
        qty: 1,
      );

      final result = selectCatalogItemOnSaleLines(
        items: items,
        targetIndex: 1,
        appliedLine: applied,
        nextLineId: () => 'new',
      );

      expect(result[1].itemId, 'item-2');
      expect(result[1].qty, 1);
      expect(result, hasLength(3));
      expect(isEmptySaleLineDraft(result[2]), isTrue);
    });

    test('does not club when existing line has serial number', () {
      final items = [
        line(
          id: 'a',
          itemId: 'item-1',
          itemName: 'Widget',
          qty: 1,
          serialNo: 'SN-1',
        ),
        line(id: 'b'),
      ];
      final applied = line(
        id: 'b',
        itemId: 'item-1',
        itemName: 'Widget',
        qty: 1,
      );

      final result = selectCatalogItemOnSaleLines(
        items: items,
        targetIndex: 1,
        appliedLine: applied,
        nextLineId: () => 'new',
      );

      expect(result, hasLength(3));
      expect(result[0].qty, 1);
      expect(result[1].itemId, 'item-1');
    });
  });
}
