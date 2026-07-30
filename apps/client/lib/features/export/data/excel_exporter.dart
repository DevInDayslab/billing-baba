import 'dart:typed_data';

import 'package:billing_baba/features/export/application/export_exception.dart';
import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_file.dart';
import 'package:billing_baba/features/export/models/export_format.dart';
import 'package:billing_baba/features/export/models/export_request.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/export/utils/export_filename.dart';
import 'package:justkawal_excel_updated/justkawal_excel_updated.dart';

/// Generates native .xlsx files from [ExportRequest].
class ExcelExporter {
  Uint8List export(ExportRequest request) {
    final excel = Excel.createExcel();

    for (final sheet in request.sheets) {
      _writeSheet(excel, sheet);
    }

    // Remove the default empty sheet after writing named sheets so Excel opens
    // on the populated worksheet (matches import-items export flow).
    if (request.sheets.isNotEmpty &&
        excel.sheets.keys.contains('Sheet1') &&
        request.sheets.every(
          (sheet) => _safeSheetName(sheet.name) != 'Sheet1',
        )) {
      excel.delete('Sheet1');
    }

    if (excel.sheets.isEmpty) {
      excel.rename('Sheet1', 'Export');
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw ExportException('Unable to generate the Excel file.');
    }
    return Uint8List.fromList(bytes);
  }

  ExportFile exportFile(ExportRequest request) {
    final filename = ExportFilename.build(
      baseName: request.filenameBase,
      extension: 'xlsx',
    );
    return ExportFile(
      bytes: export(request),
      filename: filename,
      format: ExportFormat.xlsx,
    );
  }

  void _writeSheet(Excel excel, ExportSheet sheet) {
    final safeName = _safeSheetName(sheet.name);
    final worksheet = excel[safeName];

    // Header row — bold.
    for (var col = 0; col < sheet.columns.length; col++) {
      final cell = worksheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cell.value = TextCellValue(sheet.columns[col].header);
      cell.cellStyle = CellStyle(bold: true);
    }

    // Data rows.
    for (var rowIdx = 0; rowIdx < sheet.rows.length; rowIdx++) {
      final row = sheet.rows[rowIdx];
      for (var col = 0; col < sheet.columns.length; col++) {
        final column = sheet.columns[col];
        final value = col < row.cells.length ? row.cells[col] : null;
        final cell = worksheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: rowIdx + 1,
          ),
        );
        _setCellValue(cell, value, column.type);
      }
    }

    // Approximate auto column width.
    for (var col = 0; col < sheet.columns.length; col++) {
      var maxLen = sheet.columns[col].header.length;
      for (final row in sheet.rows) {
        if (col < row.cells.length && row.cells[col] != null) {
          final len = row.cells[col].toString().length;
          if (len > maxLen) maxLen = len;
        }
      }
      worksheet.setColumnWidth(col, (maxLen + 2).clamp(8, 48).toDouble());
    }
  }

  void _setCellValue(Data cell, Object? value, ExportCellType type) {
    if (value == null) {
      cell.value = TextCellValue('');
      return;
    }

    switch (type) {
      case ExportCellType.number:
      case ExportCellType.currency:
        final numValue = value is num
            ? value.toDouble()
            : double.tryParse(value.toString());
        if (numValue != null) {
          cell.value = DoubleCellValue(numValue);
        } else {
          cell.value = TextCellValue(value.toString());
        }
      case ExportCellType.date:
      case ExportCellType.datetime:
        if (value is DateTime) {
          cell.value = DateTimeCellValue(
            year: value.year,
            month: value.month,
            day: value.day,
            hour: type == ExportCellType.datetime ? value.hour : 0,
            minute: type == ExportCellType.datetime ? value.minute : 0,
          );
        } else {
          cell.value = TextCellValue(value.toString());
        }
      case ExportCellType.text:
        cell.value = TextCellValue(value.toString());
    }
  }

  String _safeSheetName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/*?:\[\]]'), '_').trim();
    final truncated = cleaned.length > 31 ? cleaned.substring(0, 31) : cleaned;
    return truncated.isEmpty ? 'Sheet' : truncated;
  }
}
