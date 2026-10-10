import 'package:justkawal_excel_updated/justkawal_excel_updated.dart';

class ParsedImportPartyExcelRow {
  const ParsedImportPartyExcelRow({
    required this.sheetRowNumber,
    required this.partyName,
    required this.mobile,
    required this.partyType,
    required this.email,
    required this.gstin,
    required this.state,
    required this.partyGroup,
    required this.openingBalance,
  });

  final int sheetRowNumber;
  final String partyName;
  final String mobile;
  final String partyType;
  final String email;
  final String gstin;
  final String state;
  final String partyGroup;
  final String openingBalance;
}

abstract final class ImportPartiesExcelParser {
  static const templateHeaders = [
    'Party Name*',
    'Mobile*',
    'Type (customer/supplier/both)',
    'Email',
    'GSTIN',
    'State',
    'Party Group',
    'Opening Balance',
  ];

  static const sampleRows = [
    [
      'Acme Retailers',
      '9876543210',
      'customer',
      'acme@example.com',
      '',
      'Maharashtra',
      'Retail',
      '5000',
    ],
    [
      'Global Supplies Pvt Ltd',
      '9123456789',
      'supplier',
      'orders@globalsupplies.in',
      '27AABCU9603R1ZM',
      'Maharashtra',
      'Vendors',
      '0',
    ],
  ];

  static List<ParsedImportPartyExcelRow> parse(List<int> bytes) {
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) return const [];

    final sheet = excel.tables.values.first;
    final rows = <ParsedImportPartyExcelRow>[];

    for (var rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
      final name = _cellText(sheet, 0, rowIndex);
      if (name.trim().isEmpty) continue;
      if (_isHeaderRow(sheet, rowIndex, name)) continue;

      rows.add(
        ParsedImportPartyExcelRow(
          sheetRowNumber: rowIndex + 1,
          partyName: name.trim(),
          mobile: _cellText(sheet, 1, rowIndex),
          partyType: _cellText(sheet, 2, rowIndex),
          email: _cellText(sheet, 3, rowIndex),
          gstin: _cellText(sheet, 4, rowIndex),
          state: _cellText(sheet, 5, rowIndex),
          partyGroup: _cellText(sheet, 6, rowIndex),
          openingBalance: _cellText(sheet, 7, rowIndex),
        ),
      );
    }

    return rows;
  }

  static bool _isHeaderRow(Sheet sheet, int rowIndex, String partyNameCell) {
    final normalizedName = partyNameCell
        .toLowerCase()
        .replaceAll('*', '')
        .trim();
    if (normalizedName == 'party name' ||
        normalizedName.startsWith('party name')) {
      return true;
    }

    final mobileCell = _cellText(sheet, 1, rowIndex).toLowerCase();
    if (mobileCell == 'mobile' || mobileCell.startsWith('mobile')) {
      return true;
    }

    final typeCell = _cellText(sheet, 2, rowIndex).toLowerCase();
    if (typeCell.contains('customer/supplier') || typeCell == 'type') {
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
