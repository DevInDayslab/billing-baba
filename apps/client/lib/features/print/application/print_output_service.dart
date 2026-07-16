import 'package:billing_baba/core/utils/platform_file_output.dart';
import 'package:billing_baba/features/print/models/printable_pdf.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Native print, preview, share, and save for generated PDF bytes.
class PrintOutputService {
  /// Opens the PDF in the system's default PDF viewer.
  ///
  /// `context` is accepted for call-site compatibility but is not used.
  Future<void> preview({
    required BuildContext context,
    required Uint8List bytes,
    String name = 'document',
  }) {
    return previewDocument(
      PrintablePdf(bytes: bytes, name: name),
    );
  }

  /// Opens a pre-rendered PDF in the system's default PDF viewer.
  Future<void> previewDocument(PrintablePdf document) {
    return PlatformFileOutput.openInDefaultViewer(
      bytes: document.bytes,
      filename: document.filename,
    );
  }

  /// Shows the platform-native print dialog for [bytes].
  Future<void> print({
    required Uint8List bytes,
    String name = 'document',
  }) {
    return printDocument(PrintablePdf(bytes: bytes, name: name));
  }

  /// Shows the platform-native print dialog for a pre-rendered PDF.
  ///
  /// Uses [Printing.layoutPdf] when the platform supports printing. Falls back
  /// to the native share sheet, then to the default PDF viewer so the user can
  /// print from there on unsupported or constrained devices.
  Future<void> printDocument(PrintablePdf document) async {
    final info = await Printing.info();

    if (info.canPrint) {
      await Printing.layoutPdf(
        onLayout: (_) async => document.bytes,
        name: document.name,
        dynamicLayout: false,
      );
      return;
    }

    if (info.canShare) {
      final shared = await Printing.sharePdf(
        bytes: document.bytes,
        filename: document.filename,
      );
      if (shared) return;
    }

    await PlatformFileOutput.openInDefaultViewer(
      bytes: document.bytes,
      filename: document.filename,
    );
  }

  Future<void> share({
    required Uint8List bytes,
    required String filename,
  }) async {
    final safeName = filename.endsWith('.pdf') ? filename : '$filename.pdf';
    final basename = safeName.split(RegExp(r'[/\\]')).last;

    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: basename);
      return;
    }

    // Desktop: native share UI via the printing plugin. share_plus cannot read
    // sandboxed temp files on macOS/Windows.
    if (PlatformFileOutput.isDesktop) {
      try {
        await Printing.sharePdf(bytes: bytes, filename: basename);
        return;
      } on Object {
        await PlatformFileOutput.saveViaDialog(
          filename: basename,
          bytes: bytes,
        );
        return;
      }
    }

    await PlatformFileOutput.shareFromTemp(
      filename: basename,
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
