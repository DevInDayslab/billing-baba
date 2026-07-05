import 'dart:typed_data';

import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_fonts.dart';
import 'package:billing_baba/features/print/templates/print_template.dart';
import 'package:billing_baba/features/print/templates/voucher/voucher_layout_config.dart';
import 'package:billing_baba/features/print/templates/voucher/voucher_pdf_sections.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Production A4 layout for payment and voucher documents.
class A4VoucherTemplate implements PrintTemplate {
  @override
  String get id => 'a4_voucher_v1';

  @override
  bool supports(PrintableDocumentKind kind) => kind.isVoucher;

  @override
  Future<Uint8List> render(PrintableDocument document) async {
    await InvoicePdfFonts.ensureLoaded();

    final config = VoucherLayoutConfig.forDocument(document);
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 52),
          buildBackground: (context) =>
              VoucherPdfSections.watermark(document.metadata.status) ??
              pw.SizedBox(),
        ),
        footer: VoucherPdfSections.footerSection,
        header: (context) {
          if (context.pageNumber != 1) {
            return pw.SizedBox();
          }
          return VoucherPdfSections.pageHeaderSection(document, config);
        },
        build: (context) => [
          if (config.showAllocationTable)
            VoucherPdfSections.allocationTable(document.allocations),
          if (config.showAssetTable) VoucherPdfSections.assetTable(document),
          if (config.showJobWorkMaterials)
            VoucherPdfSections.jobWorkMaterialsTable(document),
          if (config.showJobWorkCharges)
            VoucherPdfSections.jobWorkChargesTable(document),
          VoucherPdfSections.closingSection(document, config),
        ],
      ),
    );

    return pdf.save();
  }
}
