import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Print-friendly colors and text styles for invoice PDFs.
abstract final class InvoicePdfTheme {
  static const accent = PdfColor.fromInt(0xFF1565C0);
  static const headerFill = PdfColor.fromInt(0xFFF5F5F5);
  static const border = PdfColor.fromInt(0xFFE0E0E0);
  static const muted = PdfColor.fromInt(0xFF616161);
  static const watermark = PdfColor.fromInt(0x33BDBDBD);

  static pw.TextStyle title({double size = 18}) => InvoicePdfFonts.style(
    fontSize: size,
    fontWeight: pw.FontWeight.bold,
  );

  static pw.TextStyle heading({double size = 11}) => InvoicePdfFonts.style(
    fontSize: size,
    fontWeight: pw.FontWeight.bold,
  );

  static pw.TextStyle body({double size = 9, PdfColor? color}) =>
      InvoicePdfFonts.style(
        fontSize: size,
        color: color ?? PdfColors.black,
      );

  static pw.TextStyle mutedBody({double size = 9}) =>
      body(size: size, color: muted);

  static pw.TextStyle tableHeader() => InvoicePdfFonts.style(
    fontSize: 8,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );

  static pw.TextStyle tableCell() => InvoicePdfFonts.style(fontSize: 8);

  static pw.BoxDecoration sectionBorder() => pw.BoxDecoration(
    border: pw.Border.all(color: border, width: 0.5),
  );
}
