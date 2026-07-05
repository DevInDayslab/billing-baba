import 'package:billing_baba/features/export/models/export_sheet.dart';

/// Builds export sheet from pre-built report headers and rows.
ExportSheet buildReportExportSheet({
  required String sheetName,
  required List<String> headers,
  required List<List<String>> rows,
}) {
  return ExportSheet.fromStrings(
    name: sheetName,
    headers: headers,
    rows: rows,
  );
}
