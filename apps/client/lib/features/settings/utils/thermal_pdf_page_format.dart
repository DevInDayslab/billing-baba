import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:pdf/pdf.dart';

/// Roll width in millimeters for each thermal paper size setting.
double thermalRollWidthMm(ThermalPageSize size) => switch (size) {
      ThermalPageSize.twoInch => 62,
      ThermalPageSize.threeInch => 80,
      ThermalPageSize.fourInch => 92,
    };

/// Horizontal margin inside the thermal roll (each side).
double thermalHorizontalMarginMm() => 10;

/// Finite-size roll format used for both PDF generation and printing.
PdfPageFormat thermalReceiptPdfFormat({
  required ThermalPageSize size,
  required double heightMm,
}) {
  final side = thermalHorizontalMarginMm();
  return PdfPageFormat(
    thermalRollWidthMm(size) * PdfPageFormat.mm,
    heightMm * PdfPageFormat.mm,
    marginTop: 6 * PdfPageFormat.mm,
    marginBottom: 6 * PdfPageFormat.mm,
    marginLeft: side * PdfPageFormat.mm,
    marginRight: side * PdfPageFormat.mm,
  );
}

/// Estimates receipt height from content so the PDF page matches the slip.
double estimateThermalReceiptHeightMm({
  required PrintSettings settings,
  required int itemCount,
  String? customerName,
}) {
  var lines = 8.0;
  if (settings.printCompanyLogo) lines += 3;
  if (settings.printCompanyName) lines += 1.5;
  if (settings.printAddress) lines += 2;
  if (settings.printGstin) lines += 1.5;
  if (settings.printPhone) lines += 1.5;
  if (customerName != null && customerName.trim().isNotEmpty) lines += 2.5;
  lines += 1;
  lines += itemCount * 2;
  lines += 5;
  if (settings.printBankDetails) lines += 3;
  if (settings.printTermsAndConditions &&
      settings.termsAndConditions.trim().isNotEmpty) {
    lines += 3;
  }
  lines += settings.extraLinesAtEnd;
  return (lines * 5.5 + 22).clamp(100, 380);
}

/// POS receipt page format derived from settings + sale content.
PdfPageFormat posReceiptPdfFormat({
  required PrintSettings settings,
  required PosSale sale,
}) {
  return thermalReceiptPdfFormat(
    size: settings.thermalPageSize,
    heightMm: estimateThermalReceiptHeightMm(
      settings: settings,
      itemCount: sale.items.length,
      customerName: sale.displayName,
    ),
  );
}

/// [Printing.layoutPdf] format for thermal commercial invoices.
PdfPageFormat? layoutPdfFormatFor(PrintSettings settings) {
  if (settings.printerType != PrinterType.thermal) return null;
  return thermalReceiptPdfFormat(
    size: settings.thermalPageSize,
    heightMm: 200,
  );
}

bool isThermalRollFormat(PdfPageFormat format) =>
    format.width < PdfPageFormat.a4.width;
