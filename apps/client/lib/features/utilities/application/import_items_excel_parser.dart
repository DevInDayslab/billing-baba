import 'package:justkawal_excel_updated/justkawal_excel_updated.dart';

class ParsedImportExcelRow {
  const ParsedImportExcelRow({
    required this.sheetRowNumber,
    required this.itemName,
    required this.type,
    required this.salePrice,
    required this.purchasePrice,
    required this.taxRate,
    required this.unit,
    required this.hsnSac,
    required this.openingQty,
  });

  final int sheetRowNumber;
  final String itemName;
  final String type;
  final String salePrice;
  final String purchasePrice;
  final String taxRate;
  final String unit;
  final String hsnSac;
  final String openingQty;
}

abstract final class ImportItemsExcelParser {
  static const templateHeaders = [
    'Item Name*',
    'Type (product/service)',
    'Sale Price',
    'Purchase Price',
    'Tax Rate (%)',
    'Unit',
    'HSN/SAC Code',
    'Opening Quantity',
  ];

  static const sampleRows = [
    [
      'Rice Bag 5kg',
      'product',
      '250',
      '200',
      '5',
      'BAG',
      '1006',
      '100',
    ],
    [
      'Web Design Service',
      'service',
      '5000',
      '0',
      '18',
      'NOS',
      '998314',
      '0',
    ],
  ];

  static List<ParsedImportExcelRow> parse(List<int> bytes) {
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) return const [];

    final sheet = excel.tables.values.first;
    final rows = <ParsedImportExcelRow>[];

    for (var rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
      final name = _cellText(sheet, 0, rowIndex);
      if (name.trim().isEmpty) continue;
      if (_isHeaderRow(sheet, rowIndex, name)) continue;

      rows.add(
        ParsedImportExcelRow(
          sheetRowNumber: rowIndex + 1,
          itemName: name.trim(),
          type: _cellText(sheet, 1, rowIndex),
          salePrice: _cellText(sheet, 2, rowIndex),
          purchasePrice: _cellText(sheet, 3, rowIndex),
          taxRate: _cellText(sheet, 4, rowIndex),
          unit: _cellText(sheet, 5, rowIndex),
          hsnSac: _cellText(sheet, 6, rowIndex),
          openingQty: _cellText(sheet, 7, rowIndex),
        ),
      );
    }

    return rows;
  }

  static bool _isHeaderRow(Sheet sheet, int rowIndex, String itemNameCell) {
    final normalizedName = itemNameCell
        .toLowerCase()
        .replaceAll('*', '')
        .trim();
    if (normalizedName == 'item name' ||
        normalizedName.startsWith('item name')) {
      return true;
    }

    final typeCell = _cellText(sheet, 1, rowIndex).toLowerCase();
    if (typeCell.contains('product/service') || typeCell == 'type') {
      return true;
    }

    return false;
  }

  static String _cellText(Sheet sheet, int column, int row) {
    final value = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
        .value;
    if (value == null) return '';

    if (value is TextCellValue) return value.value.toString().trim();
    if (value is IntCellValue) return value.value.toString();
    if (value is DoubleCellValue) return _formatNumber(value.value);
    if (value is BoolCellValue) return value.value.toString();
    return value.toString().trim();
  }

  static String _formatNumber(num value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    final text = value.toString();
    return text.contains('e') || text.contains('E')
        ? value.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')
        : text;
  }
}
