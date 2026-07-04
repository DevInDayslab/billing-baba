import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// CSV export, clipboard copy, file save, and print preview for reports.
abstract final class ReportExportService {
  static String toCsv({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final buffer = StringBuffer()
      ..writeln(_escapeCsvRow(headers));
    for (final row in rows) {
      buffer.writeln(_escapeCsvRow(row));
    }
    return buffer.toString();
  }

  static String _escapeCsvRow(List<String> cells) {
    return cells.map(_escapeCsvCell).join(',');
  }

  static String _escapeCsvCell(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static Future<void> copyCsvToClipboard(String csv) async {
    await Clipboard.setData(ClipboardData(text: csv));
  }

  /// Saves CSV to the downloads directory on desktop, or app documents elsewhere.
  static Future<String?> saveCsvFile({
    required String csv,
    required String filename,
  }) async {
    if (kIsWeb) return null;

    final directory = await _resolveSaveDirectory();
    final safeName = filename.endsWith('.csv') ? filename : '$filename.csv';
    final file = File('${directory.path}/$safeName');
    await file.writeAsString(csv);
    return file.path;
  }

  static Future<Directory> _resolveSaveDirectory() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    }
    return getApplicationDocumentsDirectory();
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

  static Future<void> exportAndNotify({
    required BuildContext context,
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    String filename = 'report',
  }) async {
    final csv = toCsv(headers: headers, rows: rows);

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final path = await saveCsvFile(csv: csv, filename: filename);
      if (context.mounted && path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to $path')),
        );
      }
      return;
    }

    await copyCsvToClipboard(csv);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV copied to clipboard')),
      );
    }
  }
}
