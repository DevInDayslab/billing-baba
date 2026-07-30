import 'package:billing_baba/features/print/models/printable_pdf.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/document_pdf_preview_dialog.dart';
import 'package:billing_baba/features/settings/utils/thermal_pdf_page_format.dart';
import 'package:billing_baba/shared/utils/platform_file_output.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

enum _ThermalOutputAction { savePdf, saveImage, printToPrinter }

/// Native print, preview, share, and save for generated PDF bytes.
class PrintOutputService {
  /// Opens an in-app PDF preview for [bytes].
  Future<void> preview({
    required BuildContext context,
    required Uint8List bytes,
    String name = 'document',
    PdfPageFormat? format,
    int copies = 1,
  }) {
    return previewDocument(
      context,
      PrintablePdf(bytes: bytes, name: name),
      format: format,
      copies: copies,
    );
  }

  /// Opens an in-app PDF preview with Print, Download, and Share actions.
  Future<void> previewDocument(
    BuildContext context,
    PrintablePdf document, {
    PdfPageFormat? format,
    int copies = 1,
  }) {
    if (!context.mounted) return Future.value();
    return showDocumentPdfPreviewDialog(
      context: context,
      document: document,
      copies: copies,
      outputService: this,
    );
  }

  /// Shows the platform-native print dialog for [bytes].
  Future<void> print({
    required BuildContext context,
    required Uint8List bytes,
    String name = 'document',
    PdfPageFormat? format,
  }) async {
    if (format != null && isThermalRollFormat(format)) {
      await _printThermalReceipt(
        context: context,
        bytes: bytes,
        format: format,
        name: name,
      );
      return;
    }

    await printDocument(
      context: context,
      document: PrintablePdf(bytes: bytes, name: name),
      format: format,
    );
  }

  /// Opens the in-app PDF preview for a pre-rendered document.
  Future<void> printDocument({
    required BuildContext context,
    required PrintablePdf document,
    PdfPageFormat? format,
    int copies = 1,
  }) {
    return previewDocument(
      context,
      document,
      format: format,
      copies: copies,
    );
  }

  /// Sends [document] to a selected printer without the OS print setup dialog.
  ///
  /// Falls back to share, then save, when no printer is available.
  Future<void> printToDevice({
    required BuildContext context,
    required PrintablePdf document,
    PdfPageFormat? format,
    int copies = 1,
  }) async {
    final pageFormat =
        format ?? document.profile.printFormat;
    final info = await Printing.info();

    if (info.canListPrinters && context.mounted) {
      final printer = await Printing.pickPrinter(
        context: context,
        title: 'Select printer',
      );
      if (printer == null) return;

      for (var copy = 0; copy < copies; copy++) {
        await Printing.directPrintPdf(
          printer: printer,
          onLayout: (_) async => document.bytes,
          name: document.name,
          format: pageFormat,
          dynamicLayout: false,
        );
      }
      return;
    }

    if (info.canPrint && !PlatformFileOutput.isDesktop) {
      for (var copy = 0; copy < copies; copy++) {
        await Printing.layoutPdf(
          onLayout: (_) async => document.bytes,
          name: document.name,
          format: pageFormat,
          dynamicLayout: false,
        );
      }
      return;
    }

    if (info.canShare) {
      final shared = await Printing.sharePdf(
        bytes: document.bytes,
        filename: document.filename,
      );
      if (shared) {
        if (context.mounted) {
          _showPrintFallbackSnackBar(
            context,
            'No printer available. Shared PDF instead.',
          );
        }
        return;
      }
    }

    final path = await save(
      bytes: document.bytes,
      filename: document.filename,
    );
    if (!context.mounted) return;

    final message = path != null
        ? 'No printer available. PDF saved to $path'
        : 'No printer available. Download or share the PDF instead.';
    _showPrintFallbackSnackBar(context, message);
  }

  void _showPrintFallbackSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _printThermalReceipt({
    required BuildContext context,
    required Uint8List bytes,
    required PdfPageFormat format,
    required String name,
  }) async {
    if (!context.mounted) return;
    final action = await showDialog<_ThermalOutputAction>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thermal receipt'),
        content: const Text(
          'Save the receipt as PDF or image to keep the correct roll size.\n\n'
          'Do not use "Microsoft Print to PDF" — it always outputs Letter/A4.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _ThermalOutputAction.savePdf),
            child: const Text('Save PDF'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _ThermalOutputAction.saveImage),
            child: const Text('Save image'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              _ThermalOutputAction.printToPrinter,
            ),
            child: const Text('Print to printer'),
          ),
        ],
      ),
    );

    if (action == null || !context.mounted) return;

    switch (action) {
      case _ThermalOutputAction.savePdf:
        await _saveThermalPdf(context: context, bytes: bytes, name: name);
      case _ThermalOutputAction.saveImage:
        await _saveThermalImage(context: context, bytes: bytes, name: name);
      case _ThermalOutputAction.printToPrinter:
        await _sendThermalToPrinter(
          context: context,
          bytes: bytes,
          format: format,
          name: name,
        );
    }
  }

  Future<void> _saveThermalPdf({
    required BuildContext context,
    required Uint8List bytes,
    required String name,
  }) async {
    if (PlatformFileOutput.isDesktop) {
      final path = await PlatformFileOutput.saveViaDialog(
        filename: name,
        bytes: bytes,
        extension: 'pdf',
      );
      if (path != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receipt saved to $path')),
        );
      }
      return;
    }

    await PlatformFileOutput.shareFromTemp(
      filename: name,
      bytes: bytes,
      mimeType: 'application/pdf',
      extension: 'pdf',
    );
  }

  Future<void> _saveThermalImage({
    required BuildContext context,
    required Uint8List bytes,
    required String name,
  }) async {
    final pngBytes = await _pdfToPng(bytes);
    if (pngBytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not convert receipt to image on this device.'),
          ),
        );
      }
      return;
    }

    if (PlatformFileOutput.isDesktop) {
      final path = await PlatformFileOutput.saveViaDialog(
        filename: name,
        bytes: pngBytes,
        extension: 'png',
      );
      if (path != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to $path')),
        );
      }
      return;
    }

    await PlatformFileOutput.shareFromTemp(
      filename: name,
      bytes: pngBytes,
      mimeType: 'image/png',
      extension: 'png',
    );
  }

  Future<Uint8List?> _pdfToPng(Uint8List pdfBytes) async {
    final info = await Printing.info();
    if (!info.canRaster) return null;

    await for (final page in Printing.raster(pdfBytes, dpi: 203)) {
      return page.toPng();
    }
    return null;
  }

  Future<void> _sendThermalToPrinter({
    required BuildContext context,
    required Uint8List bytes,
    required PdfPageFormat format,
    required String name,
  }) async {
    if (PlatformFileOutput.isDesktop) {
      final info = await Printing.info();
      if (!info.canListPrinters) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No printers found. Use Save PDF instead.'),
          ),
        );
        return;
      }

      if (!context.mounted) return;
      final printer = await Printing.pickPrinter(
        context: context,
        title: 'Select thermal printer',
      );
      if (printer == null) return;

      await Printing.directPrintPdf(
        printer: printer,
        onLayout: (_) async => bytes,
        name: name,
        format: format,
        dynamicLayout: false,
      );
      return;
    }

    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: name,
      format: format,
      dynamicLayout: false,
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
