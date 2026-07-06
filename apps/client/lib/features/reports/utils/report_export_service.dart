import 'dart:convert';

import 'package:billing_baba/features/export/data/csv_exporter.dart';
import 'package:billing_baba/features/export/models/export_request.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_preview_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// CSV generation and legacy print-preview entry points.
abstract final class ReportExportService {
  static String toCsv({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final sheet = ExportSheet.fromStrings(
      name: 'Report',
      headers: headers,
      rows: rows,
    );
    final exporter = CsvExporter();
    final bytes = exporter.export(
      ExportRequest.csv(sheet: sheet, filenameBase: 'report'),
    );
    return ReportCsvCodec.decode(bytes);
  }

  static Future<void> copyCsvToClipboard(String csv) async {
    await Clipboard.setData(ClipboardData(text: csv));
  }

  /// Opens the professional report preview instead of raw CSV text.
  static Future<void> showPrintPreview({
    required BuildContext context,
    required String title,
    required String content,
    String filename = 'report',
    ReportPreviewMeta? meta,
  }) async {
    if (!context.mounted) return;

    final parsed = ReportCsvCodec.parse(content);
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not parse report data for preview'),
        ),
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
}

/// UTF-8 CSV decoding with BOM stripping and lightweight parsing.
abstract final class ReportCsvCodec {
  static String decode(List<int> bytes) {
    var text = utf8.decode(bytes, allowMalformed: true);
    if (text.startsWith('\uFEFF')) {
      text = text.substring(1);
    }
    return text;
  }

  static ({List<String> headers, List<List<String>> rows})? parse(String csv) {
    var text = csv;
    if (text.startsWith('\uFEFF')) {
      text = text.substring(1);
    }
    if (text.trim().isEmpty) return null;

    final lines = const LineSplitter().convert(text);
    if (lines.isEmpty) return null;

    final headers = _parseLine(lines.first);
    if (headers.isEmpty) return null;

    final rows = <List<String>>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      rows.add(_parseLine(lines[i]));
    }

    return (headers: headers, rows: rows);
  }

  static List<String> _parseLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        values.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    values.add(buffer.toString());
    return values;
  }
}
