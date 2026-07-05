import 'dart:typed_data';

import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_fonts.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_sections.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_theme.dart';
import 'package:billing_baba/features/print/templates/print_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Production A4 GST tax invoice layout.
class A4GstInvoiceTemplate implements PrintTemplate {
  @override
  String get id => 'a4_gst_invoice_v1';

  @override
  bool supports(PrintableDocumentKind kind) =>
      kind == PrintableDocumentKind.saleInvoice;

  @override
  Future<Uint8List> render(PrintableDocument document) async {
    await InvoicePdfFonts.ensureLoaded();

    final showGst = document.metadata.isGstFormal;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 48),
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          buildBackground: (context) =>
              InvoicePdfSections.watermark(document.metadata.status) ??
              pw.SizedBox(),
        ),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              if (context.pageNumber == 1) ...[
                InvoicePdfSections.companySection(document),
                InvoicePdfSections.invoiceHeaderSection(document),
                InvoicePdfSections.partySection(document),
              ],
              pw.Table(
                border: pw.TableBorder.all(
                  color: InvoicePdfTheme.border,
                  width: 0.5,
                ),
                columnWidths: showGst
                    ? {
                        0: const pw.FixedColumnWidth(20),
                        1: const pw.FlexColumnWidth(3),
                        2: const pw.FixedColumnWidth(42),
                        3: const pw.FixedColumnWidth(32),
                        4: const pw.FixedColumnWidth(32),
                        5: const pw.FixedColumnWidth(48),
                        6: const pw.FixedColumnWidth(36),
                        7: const pw.FixedColumnWidth(36),
                        8: const pw.FixedColumnWidth(52),
                      }
                    : {
                        0: const pw.FixedColumnWidth(20),
                        1: const pw.FlexColumnWidth(3),
                        2: const pw.FixedColumnWidth(32),
                        3: const pw.FixedColumnWidth(32),
                        4: const pw.FixedColumnWidth(48),
                        5: const pw.FixedColumnWidth(36),
                        6: const pw.FixedColumnWidth(52),
                      },
                children: InvoicePdfSections.itemsTableHeader(showGst: showGst),
              ),
            ],
          );
        },
        footer: InvoicePdfSections.footerSection,
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
            columnWidths: showGst
                ? {
                    0: const pw.FixedColumnWidth(20),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FixedColumnWidth(42),
                    3: const pw.FixedColumnWidth(32),
                    4: const pw.FixedColumnWidth(32),
                    5: const pw.FixedColumnWidth(48),
                    6: const pw.FixedColumnWidth(36),
                    7: const pw.FixedColumnWidth(36),
                    8: const pw.FixedColumnWidth(52),
                  }
                : {
                    0: const pw.FixedColumnWidth(20),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FixedColumnWidth(32),
                    3: const pw.FixedColumnWidth(32),
                    4: const pw.FixedColumnWidth(48),
                    5: const pw.FixedColumnWidth(36),
                    6: const pw.FixedColumnWidth(52),
                  },
            children: InvoicePdfSections.itemsTableRows(
              lines: document.lines,
              showGst: showGst,
            ),
          ),
          InvoicePdfSections.totalsSection(document),
          InvoicePdfSections.amountInWordsSection(document),
          InvoicePdfSections.notesSection(document),
          InvoicePdfSections.signatureSection(document),
        ],
      ),
    );

    return pdf.save();
  }
}
