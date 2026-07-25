import 'package:billing_baba/features/export/presentation/desktop/widgets/export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_preview_dialog.dart';
import 'package:billing_baba/features/reports/utils/report_export_service.dart';
import 'package:flutter/material.dart';

void reportExportTable({
  required BuildContext context,
  required String title,
  required String filename,
  required List<String> headers,
  required List<List<String>> rows,
}) {
  ExportActions.exportReportXlsx(
    context,
    sheetName: title,
    filenameBase: filename,
    headers: headers,
    rows: rows,
  );
}

void reportPrintTable({
  required BuildContext context,
  required String title,
  required List<String> headers,
  required List<List<String>> rows,
  String? filename,
  ReportPreviewMeta? meta,
}) {
  showReportPreviewDialog(
    context: context,
    title: title,
    filenameBase: filename ?? _filenameFromTitle(title),
    headers: headers,
    rows: rows,
    meta: meta,
  );
}

void reportPrintRow({
  required BuildContext context,
  required String title,
  required List<String> headers,
  required List<String> row,
  String? filename,
  ReportPreviewMeta? meta,
}) {
  reportPrintTable(
    context: context,
    title: title,
    filename: filename,
    headers: headers,
    rows: [row],
    meta: meta,
  );
}

String _filenameFromTitle(String title) {
  final slug = title
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');
  return slug.isEmpty ? 'report' : slug;
}

/// Opens the formatted report preview for callers that still pass CSV text.
void reportShowPreviewFromCsv({
  required BuildContext context,
  required String title,
  required String filename,
  required String csv,
  ReportPreviewMeta? meta,
}) {
  final parsed = ReportCsvCodec.parse(csv);
  if (parsed == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not parse report data for preview')),
    );
    return;
  }

  showReportPreviewDialog(
    context: context,
    title: title,
    filenameBase: filename,
    headers: parsed.headers,
    rows: parsed.rows,
    meta: meta,
  );
}
