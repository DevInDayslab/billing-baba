import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/utilities/application/import_items_excel_parser.dart';
import 'package:billing_baba/features/utilities/application/import_items_excel_service.dart';
import 'package:billing_baba/features/utilities/models/import_item_preview_row.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImportItemsExcelService.buildPreviewRows', () {
    const parsedRows = [
      ParsedImportExcelRow(
        sheetRowNumber: 2,
        itemName: 'Rice Bag 5kg',
        type: 'product',
        salePrice: '250',
        purchasePrice: '200',
        taxRate: '5',
        unit: 'BAG',
        hsnSac: '1006',
        openingQty: '100',
      ),
    ];

    const units = [
      InventoryUnit(
        id: 'unit-pcs',
        fullName: 'Pieces',
        shortName: 'PCS',
      ),
    ];

    test('marks rows valid when units exist even if excel unit is unknown', () {
      final rows = ImportItemsExcelService.buildPreviewRows(
        parsedRows: parsedRows,
        existingItems: const [],
        units: units,
      );

      expect(rows, hasLength(1));
      expect(rows.first.status, ImportRowStatus.valid);
      expect(rows.first.isSelected, isTrue);
      expect(rows.first.importForm, isNotNull);
      expect(rows.first.importForm!.baseUnitId, 'unit-pcs');
    });

    test('marks rows as error only when units list is empty', () {
      final rows = ImportItemsExcelService.buildPreviewRows(
        parsedRows: parsedRows,
        existingItems: const [],
        units: const [],
      );

      expect(rows, hasLength(1));
      expect(rows.first.status, ImportRowStatus.error);
      expect(rows.first.issueMessage, contains('No units configured'));
    });
  });
}
