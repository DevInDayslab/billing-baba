import 'package:billing_baba/features/export/data/csv_exporter.dart';
import 'package:billing_baba/features/export/models/export_request.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// CSV text generation, clipboard copy, and print preview for reports.
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
    final text = String.fromCharCodes(bytes);
    return text.startsWith('\uFEFF') ? text.substring(1) : text;
  }

  static Future<void> copyCsvToClipboard(String csv) async {
    await Clipboard.setData(ClipboardData(text: csv));
  }

  static Future<void> showPrintPreview({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 640,
            height: 420,
            child: SingleChildScrollView(
              child: SelectableText(content),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () async {
                await copyCsvToClipboard(content);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                }
              },
              icon: const Icon(Icons.copy_outlined, size: 18),
              label: const Text('Copy'),
            ),
          ],
        );
      },
    );
  }
}
