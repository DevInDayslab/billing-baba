import 'dart:typed_data';

import 'package:billing_baba/features/print/models/pdf_page_profile.dart';
import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';
import 'package:billing_baba/features/print/templates/commercial_document_layout_config.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_fonts.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_sections.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_theme.dart';
import 'package:billing_baba/features/print/templates/print_template.dart';
import 'package:pdf/widgets.dart' as pw;

/// Production A4 layout for all commercial documents.
class A4CommercialDocumentTemplate implements PrintTemplate {
  @override
  String get id => 'a4_commercial_document_v1';

  @override
  bool supports(PrintableDocumentKind kind) => kind.isCommercial;

  @override
  Future<Uint8List> render(PrintableDocument document) async {
    await InvoicePdfFonts.ensureLoaded();

    final config = CommercialDocumentLayoutConfig.forDocument(document);
    final showGst = config.showGstColumns;
    final showLinePricing = config.showLinePricing;
    final columnWidths = CommercialDocumentPdfSections.tableColumnWidths(
      showGst: showGst,
      showLinePricing: showLinePricing,
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageProfile.transaction.pageFormat,
          margin: PdfPageProfile.transaction.pageMargins,
          buildBackground: (context) =>
              CommercialDocumentPdfSections.watermark(
                document.metadata.status,
              ) ??
              pw.SizedBox(),
        ),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              if (context.pageNumber == 1)
                CommercialDocumentPdfSections.pageHeaderSection(
                  document,
                  config,
                ),
              pw.SizedBox(height: InvoicePdfTheme.spacingMd),
              pw.Table(
                border: pw.TableBorder(
                  left: const pw.BorderSide(
                    color: InvoicePdfTheme.border,
                    width: 0.5,
                  ),
                  right: const pw.BorderSide(
                    color: InvoicePdfTheme.border,
                    width: 0.5,
                  ),
                  top: pw.BorderSide(
                    color: InvoicePdfTheme.border,
                    width: context.pageNumber == 1 ? 0.5 : 0,
                  ),
                  bottom: const pw.BorderSide(
                    color: InvoicePdfTheme.border,
                    width: 0.5,
                  ),
                  horizontalInside: const pw.BorderSide(
                    color: InvoicePdfTheme.border,
                    width: 0.5,
                  ),
                ),
                columnWidths: columnWidths,
                children: CommercialDocumentPdfSections.itemsTableHeader(
                  showGst: showGst,
                  showLinePricing: showLinePricing,
                ),
              ),
            ],
          );
        },
        footer: CommercialDocumentPdfSections.footerSection,
        build: (context) => [
          pw.Table(
            border: const pw.TableBorder(
              left: pw.BorderSide(color: InvoicePdfTheme.border, width: 0.5),
              right: pw.BorderSide(color: InvoicePdfTheme.border, width: 0.5),
              bottom: pw.BorderSide(color: InvoicePdfTheme.border, width: 0.5),
              horizontalInside: pw.BorderSide(
                color: InvoicePdfTheme.border,
                width: 0.5,
              ),
            ),
            columnWidths: columnWidths,
            children: CommercialDocumentPdfSections.itemsTableRows(
              lines: document.lines,
              showGst: showGst,
              showLinePricing: showLinePricing,
            ),
          ),
          CommercialDocumentPdfSections.closingSection(document, config),
        ],
      ),
    );

    return pdf.save();
  }
}

/// @deprecated Use [A4CommercialDocumentTemplate].
typedef A4GstInvoiceTemplate = A4CommercialDocumentTemplate;
