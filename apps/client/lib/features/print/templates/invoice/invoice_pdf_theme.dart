import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Print-friendly colors and text styles for invoice PDFs.
abstract final class InvoicePdfTheme {
  /// Billing Baba primary (`AppColors.primary`).
  static const accent = PdfColor.fromInt(0xFF1565C0);
  static const accentTint = PdfColor.fromInt(0xFFE3F2FD);
  static const headerFill = PdfColor.fromInt(0xFFF5F5F5);
  static const border = PdfColor.fromInt(0xFFE0E0E0);
  static const muted = PdfColor.fromInt(0xFF616161);
  static const watermark = PdfColor.fromInt(0x1A9E9E9E);

  static const spacingXs = 4.0;
  static const spacingSm = 8.0;
  static const spacingMd = 12.0;
  static const spacingLg = 16.0;
  static const spacingXl = 24.0;

  static const totalsMarginTop = 12.0;
  static const totalsMarginBottom = 8.0;

  static pw.TextStyle companyName() => InvoicePdfFonts.style(
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
  );

  static pw.TextStyle documentTitle() => InvoicePdfFonts.style(
    fontSize: 19,
    fontWeight: pw.FontWeight.bold,
    color: accent,
  );

  static pw.TextStyle title({double size = 18}) => InvoicePdfFonts.style(
    fontSize: size,
    fontWeight: pw.FontWeight.bold,
  );

  /// Section titles — semiBold, 10–11 pt.
  static pw.TextStyle heading({double size = 10.5}) => InvoicePdfFonts.style(
    fontSize: size,
  );

  static pw.TextStyle body({double size = 9, PdfColor? color}) =>
      InvoicePdfFonts.style(
        fontSize: size,
        color: color ?? PdfColors.black,
      );

  static pw.TextStyle mutedBody({double size = 9}) =>
      body(size: size, color: muted);

  static pw.TextStyle tableHeader() => InvoicePdfFonts.style(
    fontSize: 9,
    color: PdfColors.black,
  );

  static pw.TextStyle tableCell() => InvoicePdfFonts.style(fontSize: 9);

  static pw.TextStyle totalRow() => body();

  static pw.TextStyle infoBoxHeading() => InvoicePdfFonts.style(fontSize: 9);

  static pw.TextStyle grandTotalLabel() => InvoicePdfFonts.style(
    fontSize: 10.5,
    color: accent,
  );

  static pw.TextStyle grandTotalValue() => InvoicePdfFonts.style(
    fontSize: 11,
    fontWeight: pw.FontWeight.bold,
    color: accent,
  );

  static pw.BoxDecoration cardDecoration() => pw.BoxDecoration(
    border: pw.Border.all(color: border, width: 0.5),
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
  );

  static pw.BoxDecoration infoBoxDecoration() => pw.BoxDecoration(
    border: pw.Border.all(color: border, width: 0.5),
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
    color: PdfColors.white,
  );

  static pw.BoxDecoration totalsBoxDecoration() => pw.BoxDecoration(
    border: pw.Border.all(color: border, width: 0.5),
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
    color: PdfColors.white,
  );

  static pw.BoxDecoration grandTotalDecoration() => const pw.BoxDecoration(
    color: accentTint,
    border: pw.Border(
      top: pw.BorderSide(color: accent),
    ),
  );

  /// @deprecated Use [cardDecoration].
  static pw.BoxDecoration sectionBorder() => cardDecoration();
}
