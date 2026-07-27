import 'dart:typed_data';

import 'package:justkawal_excel_updated/justkawal_excel_updated.dart';
import 'package:billing_baba/features/utilities/application/import_items_excel_parser.dart';

/// Builds the sample Excel template bytes for item import.
Uint8List? buildImportItemsSampleTemplateBytes() {
  final excel = Excel.createExcel();
  const sheetName = 'Items';
  final sheet = excel[sheetName];
  excel.delete('Sheet1');

  for (var i = 0; i < ImportItemsExcelParser.templateHeaders.length; i++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value =
        TextCellValue(
      ImportItemsExcelParser.templateHeaders[i],
    );
  }

  for (
    var rowIndex = 0;
    rowIndex < ImportItemsExcelParser.sampleRows.length;
    rowIndex++
  ) {
    final sampleRow = ImportItemsExcelParser.sampleRows[rowIndex];
    for (var colIndex = 0; colIndex < sampleRow.length; colIndex++) {
      final cellValue = sampleRow[colIndex];
      final excelRow = rowIndex + 1;
      final parsed = double.tryParse(cellValue);
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: colIndex,
              rowIndex: excelRow,
            ),
          )
          .value = parsed != null && colIndex >= 2
          ? DoubleCellValue(parsed)
          : TextCellValue(cellValue);
    }
  }

  final bytes = excel.encode();
  if (bytes == null) return null;
  return Uint8List.fromList(bytes);
}
