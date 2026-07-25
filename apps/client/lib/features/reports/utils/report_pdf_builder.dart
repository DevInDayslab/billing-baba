import 'dart:typed_data';

import 'package:billing_baba/features/print/models/pdf_page_profile.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_fonts.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_theme.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_preview_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds A4 PDF bytes for tabular report previews and exports.
abstract final class ReportPdfBuilder {
  static Future<Uint8List> build({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    ReportPreviewMeta? meta,
  }) async {
    await InvoicePdfFonts.ensureLoaded();

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageProfile.transactionCompact.pageFormat,
          margin: PdfPageProfile.transactionCompact.pageMargins,
        ),
        header: (context) {
          if (context.pageNumber != 1) return pw.SizedBox();
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(title, style: InvoicePdfTheme.title(size: 16)),
              if (meta != null) ...[
                pw.SizedBox(height: InvoicePdfTheme.spacingSm),
                ..._metaLines(meta),
              ],
              pw.SizedBox(height: InvoicePdfTheme.spacingMd),
            ],
          );
        },
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: InvoicePdfTheme.mutedBody(size: 8),
          ),
        ),
        build: (context) => [
          pw.Table(
            border: const pw.TableBorder(
              left: pw.BorderSide(color: InvoicePdfTheme.border, width: 0.5),
              right: pw.BorderSide(color: InvoicePdfTheme.border, width: 0.5),
              top: pw.BorderSide(color: InvoicePdfTheme.border, width: 0.5),
              bottom: pw.BorderSide(color: InvoicePdfTheme.border, width: 0.5),
              horizontalInside: pw.BorderSide(
                color: InvoicePdfTheme.border,
                width: 0.5,
              ),
              verticalInside: pw.BorderSide(
                color: InvoicePdfTheme.border,
                width: 0.5,
              ),
            ),
            columnWidths: {
              for (var i = 0; i < headers.length; i++)
                i: i == headers.length - 2 && headers.length > 3
                    ? const pw.FlexColumnWidth(1.2)
                    : const pw.IntrinsicColumnWidth(),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: InvoicePdfTheme.headerFill,
                ),
                children: [
                  for (final header in headers)
                    InvoicePdfWidgets.tableHeaderCell(
                      header,
                      align: _headerAlign(header),
                    ),
                ],
              ),
              for (var i = 0; i < rows.length; i++)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i.isEven ? PdfColors.white : PdfColors.grey100,
                  ),
                  children: [
                    for (var j = 0; j < headers.length; j++)
                      InvoicePdfWidgets.tableBodyCell(
                        j < rows[i].length ? rows[i][j] : '',
                        align: _headerAlign(headers[j]),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static List<pw.Widget> _metaLines(ReportPreviewMeta meta) {
    final lines = <pw.Widget>[];
    if (meta.party case final party? when party.isNotEmpty) {
      lines.add(pw.Text('Party: $party', style: InvoicePdfTheme.body()));
    }
    if (meta.invoiceDate case final date? when date.isNotEmpty) {
      lines.add(pw.Text('Invoice Date: $date', style: InvoicePdfTheme.body()));
    }
    if (meta.invoiceNumber case final number? when number.isNotEmpty) {
      lines.add(
        pw.Text('Invoice Number: $number', style: InvoicePdfTheme.body()),
      );
    }
    return lines;
  }

  static pw.TextAlign _headerAlign(String header) {
    final normalized = header.toLowerCase();
    if (normalized.contains('amount') ||
        normalized.contains('profit') ||
        normalized.contains('loss') ||
        normalized.contains('balance') ||
        normalized.contains('debit') ||
        normalized.contains('credit') ||
        normalized.contains('qty') ||
        normalized.contains('quantity')) {
      return pw.TextAlign.right;
    }
    return pw.TextAlign.left;
  }
}
