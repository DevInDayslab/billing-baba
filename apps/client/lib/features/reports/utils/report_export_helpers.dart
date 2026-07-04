import 'package:billing_baba/features/reports/utils/report_export_service.dart';
import 'package:flutter/material.dart';

void reportExportTable({
  required BuildContext context,
  required String title,
  required String filename,
  required List<String> headers,
  required List<List<String>> rows,
}) {
  ReportExportService.exportAndNotify(
    context: context,
    title: title,
    filename: filename,
    headers: headers,
    rows: rows,
  );
}

void reportPrintTable({
  required BuildContext context,
  required String title,
  required List<String> headers,
  required List<List<String>> rows,
}) {
  ReportExportService.showPrintPreview(
    context: context,
    title: title,
    content: ReportExportService.toCsv(headers: headers, rows: rows),
  );
}

void reportPrintRow({
  required BuildContext context,
  required String title,
  required List<String> headers,
  required List<String> row,
}) {
  reportPrintTable(
    context: context,
    title: title,
    headers: headers,
    rows: [row],
  );
}
