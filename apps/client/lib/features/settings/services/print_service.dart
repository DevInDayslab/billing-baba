import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Settings-screen print and share output for generated invoice PDFs.
abstract final class PrintService {
  static Future<void> printOrShare({
    required pw.Document doc,
    required PrinterType printerType,
    required String fileName,
  }) async {
    final safeName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';

    if (printerType == PrinterType.regular) {
      await Printing.layoutPdf(
        onLayout: (_) async => doc.save(),
        name: safeName,
        dynamicLayout: false,
      );
      return;
    }

    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: safeName);
  }
}
