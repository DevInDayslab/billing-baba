import 'dart:convert';
import 'dart:typed_data';

import 'package:billing_baba/features/export/models/export_file.dart';
import 'package:billing_baba/features/export/models/export_request.dart';
import 'package:billing_baba/features/export/utils/export_filename.dart';
import 'package:billing_baba/features/export/utils/export_formatters.dart';
import 'package:csv/csv.dart';

/// Generates UTF-8 CSV files from [ExportRequest].
class CsvExporter {
  Uint8List export(ExportRequest request) {
    if (request.sheets.isEmpty) {
      return Uint8List.fromList(utf8.encode('\uFEFF'));
    }

    // CSV export uses the first sheet only.
    final sheet = request.sheets.first;
    final rows = <List<String>>[
      [for (final col in sheet.columns) col.header],
      for (final row in sheet.rows) ExportFormatters.formatRow(sheet, row),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    // UTF-8 BOM for Excel compatibility.
    return Uint8List.fromList(utf8.encode('\uFEFF$csv'));
  }

  ExportFile exportFile(ExportRequest request) {
    final filename = ExportFilename.build(
      baseName: request.filenameBase,
      extension: 'csv',
    );
    return ExportFile(
      bytes: export(request),
      filename: filename,
      format: request.format,
    );
  }
}
