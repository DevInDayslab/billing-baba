import 'package:billing_baba/features/print/templates/a4_commercial_document_template.dart' show A4CommercialDocumentTemplate;
import 'package:billing_baba/features/print/templates/a4_gst_invoice_template.dart' show A4CommercialDocumentTemplate;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Proportional column widths for the commercial document items table.
abstract final class InvoicePdfTableLayout {
  /// Matches [A4CommercialDocumentTemplate] horizontal margins.
  static const horizontalMargin = 40.0;

  static double printableWidth({
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    double margin = horizontalMargin,
  }) {
    return pageFormat.width - (margin * 2);
  }

  /// #, Description, HSN/SAC, Qty, Unit, Rate, Discount, GST %, Amount
  static const _gstFractions = <double>[
    0.04,
    0.34,
    0.10,
    0.07,
    0.06,
    0.10,
    0.10,
    0.07,
    0.12,
  ];

  /// #, Description, Qty, Unit, Rate, Discount, Amount
  static const _nonGstFractions = <double>[
    0.05,
    0.42,
    0.08,
    0.08,
    0.12,
    0.10,
    0.15,
  ];

  static Map<int, pw.TableColumnWidth> commercialColumns({
    required bool showGst,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    double margin = horizontalMargin,
  }) {
    final available = printableWidth(
      pageFormat: pageFormat,
      margin: margin,
    );
    final fractions = showGst ? _gstFractions : _nonGstFractions;

    return {
      for (var i = 0; i < fractions.length; i++)
        i: pw.FixedColumnWidth(available * fractions[i]),
    };
  }
}
