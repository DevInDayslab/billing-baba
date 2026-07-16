import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/utilities/application/barcode_item_label_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarcodeItemLabelMapper', () {
    test('maps company name, item name, and sale price', () {
      const item = InventoryItem(
        id: '1',
        name: 'Widget Pro',
        type: ItemType.product,
        salePrice: 199.5,
      );

      final fields = BarcodeItemLabelMapper.fromItem(
        item: item,
        companyName: 'Acme Traders',
      );

      expect(fields.header, 'Acme Traders');
      expect(fields.line1, 'Widget Pro');
      expect(fields.line2, 'Rs.199.50');
      expect(fields.line3, isEmpty);
      expect(fields.line4, isEmpty);
    });

    test('shows MRP on line 4 when present', () {
      const item = InventoryItem(
        id: '1',
        name: 'Widget Pro',
        type: ItemType.product,
        salePrice: 180,
        mrp: 200,
      );

      final fields = BarcodeItemLabelMapper.fromItem(
        item: item,
        companyName: 'Acme Traders',
      );

      expect(fields.line3, isEmpty);
      expect(fields.line4, 'MRP: Rs.200.00');
    });

    test('prefers HSN over category when MRP is absent', () {
      const item = InventoryItem(
        id: '1',
        name: 'Widget Pro',
        type: ItemType.product,
        hsnCode: '1234',
        categoryId: 'cat-1',
      );

      final fields = BarcodeItemLabelMapper.fromItem(
        item: item,
        companyName: 'Acme Traders',
        categoryName: 'Electronics',
      );

      expect(fields.line4, 'HSN: 1234');
    });

    test('falls back to category when MRP and HSN are absent', () {
      const item = InventoryItem(
        id: '1',
        name: 'Widget Pro',
        type: ItemType.product,
        categoryId: 'cat-1',
      );

      final fields = BarcodeItemLabelMapper.fromItem(
        item: item,
        companyName: 'Acme Traders',
        categoryName: 'Electronics',
      );

      expect(fields.line4, 'Electronics');
    });
  });
}
