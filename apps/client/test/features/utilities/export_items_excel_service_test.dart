import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/utilities/application/export_items_excel_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportItemsExcelService.buildSheet', () {
    test('maps item fields to import-compatible and detail columns', () {
      const item = InventoryItem(
        id: '1',
        name: 'Rice Bag',
        type: ItemType.product,
        quantity: 50,
        salePrice: 250,
        purchasePrice: 200,
        defaultTaxRate: 5,
        baseUnitShortName: 'BAG',
        hsnCode: '1006',
        barcode: '890123',
        mrp: 280,
        description: '5kg pack',
        categoryId: 'cat-1',
        brandId: 'brand-1',
        shortName: 'Rice',
        alias: 'Chawal',
        reorderLevel: 10,
        isRawMaterial: false,
      );

      final sheet = ExportItemsExcelService.buildSheet(
        items: [item],
        categoryNamesById: {'cat-1': 'Grocery'},
        brandNamesById: {'brand-1': 'Local'},
      );

      expect(sheet.rows, hasLength(1));
      final row = sheet.rows.first.cells;
      expect(row[0], 'Rice Bag');
      expect(row[1], 'product');
      expect(row[2], '250');
      expect(row[7], '50');
      expect(row[8], '890123');
      expect(row[11], 'Grocery');
      expect(row[12], 'Local');
      expect(row[16], 'no');
    });

    test('sorts items by name', () {
      final sheet = ExportItemsExcelService.buildSheet(
        items: const [
          InventoryItem(id: 'b', name: 'Zebra', type: ItemType.service),
          InventoryItem(id: 'a', name: 'Apple', type: ItemType.product),
        ],
        categoryNamesById: {},
        brandNamesById: {},
      );

      expect(sheet.rows.first.cells.first, 'Apple');
      expect(sheet.rows.last.cells.first, 'Zebra');
    });
  });
}
