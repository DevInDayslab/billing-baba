import 'package:billing_baba/core/utils/platform_file_output.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Native print, preview, share, and save for generated PDF bytes.
class PrintOutputService {
  /// Pre-rendered PDFs must use [dynamicLayout: false] on macOS/iOS — the
  /// default dynamic path blocks the main thread waiting for layout while the
  /// print dialog is open, which deadlocks Flutter's platform channel.
  Future<void> preview({
    required BuildContext context,
    required Uint8List bytes,
    String name = 'document',
  }) async {
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: name,
      dynamicLayout: false,
    );
  }

  Future<void> print({
    required Uint8List bytes,
    String name = 'document',
  }) async {
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: name,
      dynamicLayout: false,
    );
  }

  Future<void> share({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: filename);
      return;
    }

    final safeName = filename.endsWith('.pdf') ? filename : '$filename.pdf';
    await PlatformFileOutput.shareFromTemp(
      filename: safeName,
      bytes: bytes,
      mimeType: 'application/pdf',
    );
  }

  Future<String?> save({
    required Uint8List bytes,
    required String filename,
  }) async {
    final safeName = filename.endsWith('.pdf') ? filename : '$filename.pdf';

    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: safeName);
      return null;
    }

    if (PlatformFileOutput.isDesktop) {
      try {
        final path = await PlatformFileOutput.saveViaDialog(
          filename: safeName,
          bytes: bytes,
        );
        if (path != null) return path;
        return null;
      } on Object {
        await share(bytes: bytes, filename: safeName);
        return null;
      }
    }

    await share(bytes: bytes, filename: safeName);
    return null;
  }
}
