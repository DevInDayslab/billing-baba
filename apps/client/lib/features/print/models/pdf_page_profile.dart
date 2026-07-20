import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:billing_baba/features/settings/utils/thermal_pdf_page_format.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Distinguishes PDF layout families so preview/print settings stay isolated.
enum PdfProfileKind {
  barcode,
  transaction,
  thermal,
}

/// Page layout profile for PDF generation, in-app preview, and printing.
class PdfPageProfile {
  const PdfPageProfile({
    required this.kind,
    required this.pageFormat,
    this.pageMargins = const pw.EdgeInsets.fromLTRB(40, 40, 40, 52),
    this.previewMaxPageWidth = 700,
    this.previewDynamicLayout = true,
  });

  final PdfProfileKind kind;
  final PdfPageFormat pageFormat;
  final pw.EdgeInsets pageMargins;

  /// Maximum rendered page width in the preview pane (logical pixels).
  /// Use [double.infinity] to fill the available preview width.
  final double previewMaxPageWidth;
  final bool previewDynamicLayout;

  /// Barcode label sheets — full-width preview; margins handled in the builder.
  static const barcode = PdfPageProfile(
    kind: PdfProfileKind.barcode,
    pageFormat: PdfPageFormat.a4,
    pageMargins: pw.EdgeInsets.zero,
    previewMaxPageWidth: double.infinity,
    previewDynamicLayout: false,
  );

  /// Standard A4 commercial documents and vouchers.
  static const transaction = PdfPageProfile(
    kind: PdfProfileKind.transaction,
    pageFormat: PdfPageFormat.a4,
    pageMargins: pw.EdgeInsets.fromLTRB(40, 40, 40, 52),
    previewMaxPageWidth: 700,
    previewDynamicLayout: true,
  );

  /// Tabular reports and party ledger statements.
  static const transactionCompact = PdfPageProfile(
    kind: PdfProfileKind.transaction,
    pageFormat: PdfPageFormat.a4,
    pageMargins: pw.EdgeInsets.fromLTRB(36, 36, 36, 48),
    previewMaxPageWidth: 700,
    previewDynamicLayout: true,
  );

  /// Settings-driven regular invoices (print settings screen / commercial docs).
  static const transactionInvoice = PdfPageProfile(
    kind: PdfProfileKind.transaction,
    pageFormat: PdfPageFormat.a4,
    pageMargins: pw.EdgeInsets.all(15 * PdfPageFormat.mm),
    previewMaxPageWidth: 700,
    previewDynamicLayout: true,
  );

  /// Resolves the profile used for transaction documents from print settings.
  static PdfPageProfile forPrintSettings(PrintSettings settings) {
    if (settings.printerType == PrinterType.thermal) {
      return PdfPageProfile(
        kind: PdfProfileKind.thermal,
        pageFormat:
            layoutPdfFormatFor(settings) ??
            PdfPageFormat(
              thermalRollWidthMm(settings.thermalPageSize) * PdfPageFormat.mm,
              200 * PdfPageFormat.mm,
            ),
        pageMargins: pw.EdgeInsets.zero,
        previewMaxPageWidth: 420,
        previewDynamicLayout: false,
      );
    }

    if (settings.orientation == RegularOrientation.landscape) {
      return PdfPageProfile(
        kind: PdfProfileKind.transaction,
        pageFormat: PdfPageFormat.a4.landscape,
        pageMargins: transaction.pageMargins,
        previewMaxPageWidth: 900,
        previewDynamicLayout: true,
      );
    }

    return transactionInvoice;
  }

  /// Print format passed to the OS printer; falls back to [pageFormat].
  PdfPageFormat get printFormat => pageFormat;
}
