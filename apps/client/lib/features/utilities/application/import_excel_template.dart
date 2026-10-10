import 'dart:typed_data';

import 'package:billing_baba/features/utilities/application/import_items_excel_parser.dart';
import 'package:billing_baba/features/utilities/application/import_parties_excel_parser.dart';
import 'package:justkawal_excel_updated/justkawal_excel_updated.dart';

/// Builds sample Excel template bytes for import utilities.
Uint8List? buildImportSampleTemplateBytes({
  required String sheetName,
  required List<String> headers,
  required List<List<String>> sampleRows,
  int numericColumnStartIndex = 2,
}) {
  final excel = Excel.createExcel();
  final sheet = excel[sheetName];
  excel.delete('Sheet1');

  for (var i = 0; i < headers.length; i++) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        .value = TextCellValue(headers[i]);
  }

  for (var rowIndex = 0; rowIndex < sampleRows.length; rowIndex++) {
    final sampleRow = sampleRows[rowIndex];
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
          .value = parsed != null && colIndex >= numericColumnStartIndex
          ? DoubleCellValue(parsed)
          : TextCellValue(cellValue);
    }
  }

  final bytes = excel.encode();
  if (bytes == null) return null;
  return Uint8List.fromList(bytes);
}

/// Builds the sample Excel template bytes for item import.
Uint8List? buildImportItemsSampleTemplateBytes() {
  return buildImportSampleTemplateBytes(
    sheetName: 'Items',
    headers: ImportItemsExcelParser.templateHeaders,
    sampleRows: ImportItemsExcelParser.sampleRows,
    numericColumnStartIndex: 2,
  );
}

/// Builds the sample Excel template bytes for party import.
Uint8List? buildImportPartiesSampleTemplateBytes() {
  return buildImportSampleTemplateBytes(
    sheetName: 'Parties',
    headers: ImportPartiesExcelParser.templateHeaders,
    sampleRows: ImportPartiesExcelParser.sampleRows,
    numericColumnStartIndex: 7,
  );
}
