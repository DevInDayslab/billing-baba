import 'dart:typed_data';

import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/print/models/pdf_page_profile.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_fonts.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:billing_baba/features/settings/utils/thermal_pdf_page_format.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Invoice line used by [InvoicePdfBuilder].
class InvoiceData {
  const InvoiceData({
    required this.invoiceNo,
    required this.date,
    required this.customerName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.logoBytes,
  });

  final String invoiceNo;
  final DateTime date;
  final String? customerName;
  final List<InvoiceLineData> items;
  final double subtotal;
  final double tax;
  final double total;
  final Uint8List? logoBytes;
}

class InvoiceLineData {
  const InvoiceLineData({
    required this.name,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  final String name;
  final num qty;
  final double rate;
  final double amount;
}

/// Builds printable invoice PDFs from settings + business + invoice data.
///
/// Layout mirrors [InvoicePreviewWidget] so the live preview matches output.
class InvoicePdfBuilder {
  InvoicePdfBuilder({
    required this.settings,
    required this.business,
    required this.invoice,
  });

  final PrintSettings settings;
  final BusinessProfileModel business;
  final InvoiceData invoice;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs ',
    decimalDigits: 2,
  );

  static final _thermalDateFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _regularDateFormat = DateFormat('dd MMM yyyy');

  Future<pw.Document> build() async {
    await InvoicePdfFonts.ensureLoaded();

    final doc = pw.Document();
    if (settings.printerType == PrinterType.thermal) {
      _buildThermal(doc);
    } else {
      _buildRegular(doc);
    }
    return doc;
  }

  void _buildThermal(pw.Document doc) {
    final pageFormat = _thermalPageFormat();
    final baseSize = _thermalBaseFontSize();

    pw.TextStyle thermalStyle({
      double scale = 1,
      bool emphasized = false,
    }) {
      final bold = settings.useTextStylingBold && emphasized;
      return InvoicePdfFonts.style(
        fontSize: baseSize * scale,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ).copyWith(lineSpacing: 1.45);
    }

    const gapXs = 3.0;
    const gapSm = 6.0;
    const gapMd = 10.0;
    const gapLg = 14.0;

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.only(
          left: pageFormat.marginLeft,
          top: pageFormat.marginTop,
          right: pageFormat.marginRight,
          bottom: pageFormat.marginBottom,
        ),
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
          if (settings.printCompanyLogo) ...[
            if (invoice.logoBytes != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Image(
                    pw.MemoryImage(invoice.logoBytes!),
                    width: 32,
                    height: 32,
                    fit: pw.BoxFit.contain,
                  ),
                ],
              )
            else
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 32,
                    height: 32,
                    decoration: const pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: PdfColor.fromInt(0x1F1565C0),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      business.name.isNotEmpty
                          ? business.name[0].toUpperCase()
                          : 'B',
                      style: thermalStyle(emphasized: true),
                    ),
                  ),
                ],
              ),
            pw.SizedBox(height: gapSm),
          ],
          if (settings.printCompanyName) ...[
            pw.Text(
              business.name,
              style: thermalStyle(scale: 1.15, emphasized: true),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: gapXs),
          ],
          if (settings.printAddress &&
              business.address != null &&
              business.address!.trim().isNotEmpty) ...[
            pw.Text(
              business.address!.trim(),
              style: thermalStyle(),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: gapXs),
          ],
          if (settings.printGstin &&
              business.gstin != null &&
              business.gstin!.trim().isNotEmpty) ...[
            pw.Text(
              'GSTIN: ${business.gstin!.trim()}',
              style: thermalStyle(),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: gapXs),
          ],
          if (settings.printPhone &&
              business.phone != null &&
              business.phone!.trim().isNotEmpty)
            pw.Text(
              'Phone: ${business.phone!.trim()}',
              style: thermalStyle(),
              textAlign: pw.TextAlign.center,
            ),
          _thermalSectionDivider(gapBefore: gapLg, gapAfter: gapMd),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  'No: ${invoice.invoiceNo}',
                  style: thermalStyle(emphasized: true),
                ),
              ),
              pw.Text(
                _thermalDateFormat.format(invoice.date),
                style: thermalStyle(scale: 0.95),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          if (invoice.customerName != null &&
              invoice.customerName!.trim().isNotEmpty) ...[
            pw.SizedBox(height: gapMd),
            pw.Text(
              'BILL TO:',
              style: thermalStyle(emphasized: true),
            ),
            pw.SizedBox(height: gapXs),
            pw.Text(
              invoice.customerName!.trim(),
              style: thermalStyle(),
            ),
          ],
          _thermalSectionDivider(gapBefore: gapMd, gapAfter: gapMd),
          _thermalItemsTable(thermalStyle),
          _thermalSectionDivider(gapBefore: gapMd, gapAfter: gapSm),
          _thermalTotalRow('Sub Total', _format(invoice.subtotal), thermalStyle()),
          _thermalTotalRow('Tax', _format(invoice.tax), thermalStyle()),
          _thermalSectionDivider(gapBefore: gapSm, gapAfter: gapSm),
          _thermalTotalRow(
            'Total Amount',
            _format(invoice.total),
            thermalStyle(emphasized: true),
            emphasized: true,
          ),
          if (settings.printBankDetails) ...[
            pw.SizedBox(height: gapLg),
            pw.Text(
              'Bank: Sample Account\nIFSC: SAMPLE0001',
              style: thermalStyle(scale: 0.9),
            ),
          ],
          if (settings.printTermsAndConditions &&
              settings.termsAndConditions.trim().isNotEmpty) ...[
            pw.SizedBox(height: gapLg),
            pw.Text(
              settings.termsAndConditions.trim(),
              style: thermalStyle(scale: 0.9),
              textAlign: pw.TextAlign.center,
            ),
          ],
          pw.SizedBox(height: gapLg + settings.extraLinesAtEnd * 4 * PdfPageFormat.mm),
            ],
          ),
        ],
      ),
    );
  }

  void _buildRegular(pw.Document doc) {
    final pageFormat = settings.orientation == RegularOrientation.landscape
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;
    final invoiceSize = _invoiceTextSize();
    final companySize = _companyTextSize();

    pw.TextStyle body({bool emphasized = false}) => InvoicePdfFonts.style(
          fontSize: invoiceSize,
          fontWeight: emphasized ? pw.FontWeight.bold : pw.FontWeight.normal,
        );

    pw.TextStyle company({bool emphasized = false}) => InvoicePdfFonts.style(
          fontSize: companySize,
          fontWeight: emphasized ? pw.FontWeight.bold : pw.FontWeight.normal,
        );

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: PdfPageProfile.transactionInvoice.pageMargins,
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (settings.printCompanyLogo) ...[
                      if (invoice.logoBytes != null)
                        pw.Image(
                          pw.MemoryImage(invoice.logoBytes!),
                          width: 32,
                          height: 32,
                          fit: pw.BoxFit.contain,
                        )
                      else
                        pw.Container(
                          width: 32,
                          height: 32,
                          decoration: const pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: PdfColor.fromInt(0x1F1565C0),
                          ),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            business.name.isNotEmpty
                                ? business.name[0].toUpperCase()
                                : 'B',
                            style: company(emphasized: true),
                          ),
                        ),
                      pw.SizedBox(height: 4),
                    ],
                    if (settings.printCompanyName)
                      pw.Text(business.name, style: company(emphasized: true)),
                    if (settings.printAddress &&
                        business.address != null &&
                        business.address!.trim().isNotEmpty)
                      pw.Text(business.address!.trim(), style: company()),
                    if (settings.printPhone &&
                        business.phone != null &&
                        business.phone!.trim().isNotEmpty)
                      pw.Text(
                        'Phone: ${business.phone!.trim()}',
                        style: company(),
                      ),
                    if (settings.printGstin &&
                        business.gstin != null &&
                        business.gstin!.trim().isNotEmpty)
                      pw.Text(
                        'GSTIN: ${business.gstin!.trim()}',
                        style: company(),
                      ),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('TAX INVOICE', style: company(emphasized: true)),
                  pw.Text('No: ${invoice.invoiceNo}', style: body()),
                  pw.Text(
                    'Date: ${_regularDateFormat.format(invoice.date)}',
                    style: body(),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text('Bill To', style: body(emphasized: true)),
          pw.Text(
            invoice.customerName ?? 'Walk-in Customer',
            style: body(emphasized: true),
          ),
          pw.SizedBox(height: 8),
          _regularItemsTable(body),
          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 160,
              child: pw.Column(
                children: [
                  _totalRow('Subtotal', _format(invoice.subtotal), body()),
                  _totalRow('Tax', _format(invoice.tax), body()),
                  _totalRow(
                    'Grand Total',
                    _format(invoice.total),
                    body(emphasized: true),
                  ),
                ],
              ),
            ),
          ),
          if (settings.printBankDetails) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Bank: Sample Account | IFSC: SAMPLE0001',
              style: body(),
            ),
          ],
          if (settings.printTermsAndConditions &&
              settings.termsAndConditions.trim().isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(settings.termsAndConditions.trim(), style: body()),
          ],
        ],
      ),
    );
  }

  pw.Widget _thermalSectionDivider({
    required double gapBefore,
    required double gapAfter,
  }) {
    return pw.Column(
      children: [
        pw.SizedBox(height: gapBefore),
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: gapAfter),
      ],
    );
  }

  pw.Widget _thermalItemsTable(
    pw.TextStyle Function({double scale, bool emphasized}) style,
  ) {
    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.IntrinsicColumnWidth(),
        2: pw.IntrinsicColumnWidth(),
        3: pw.IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.top,
      children: [
        pw.TableRow(
          children: [
            _thermalCell('Item', style(emphasized: true), isHeader: true),
            _thermalCell(
              'Qty',
              style(emphasized: true),
              align: pw.TextAlign.center,
              isHeader: true,
            ),
            _thermalCell(
              'Rate',
              style(emphasized: true),
              align: pw.TextAlign.right,
              isHeader: true,
            ),
            _thermalCell(
              'Total',
              style(emphasized: true),
              align: pw.TextAlign.right,
              isHeader: true,
            ),
          ],
        ),
        for (final item in invoice.items)
          pw.TableRow(
            children: [
              _thermalCell(item.name, style(), maxLines: 2),
              _thermalCell(
                '${item.qty}',
                style(),
                align: pw.TextAlign.center,
              ),
              _thermalCell(
                _format(item.rate),
                style(),
                align: pw.TextAlign.right,
              ),
              _thermalCell(
                _format(item.amount),
                style(),
                align: pw.TextAlign.right,
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _thermalCell(
    String text,
    pw.TextStyle style, {
    pw.TextAlign align = pw.TextAlign.left,
    int? maxLines,
    bool isHeader = false,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.fromLTRB(
        0,
        isHeader ? 4 : 5,
        align == pw.TextAlign.right ? 1 : 0,
        isHeader ? 6 : 5,
      ),
      child: pw.Text(
        text,
        style: style,
        textAlign: align,
        maxLines: maxLines,
      ),
    );
  }

  pw.Widget _thermalTotalRow(
    String label,
    String value,
    pw.TextStyle style, {
    bool emphasized = false,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(right: 1, top: emphasized ? 4 : 3, bottom: emphasized ? 4 : 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(label, style: style),
          ),
          pw.Text(value, style: style, textAlign: pw.TextAlign.right),
        ],
      ),
    );
  }

  pw.Widget _regularItemsTable(pw.TextStyle Function({bool emphasized}) style) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Description', style: style(emphasized: true)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                'Qty',
                style: style(emphasized: true),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                'Rate',
                style: style(emphasized: true),
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                'Amount',
                style: style(emphasized: true),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
        for (final item in invoice.items)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(item.name, style: style(), maxLines: 2),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  '${item.qty}',
                  style: style(),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  _format(item.rate),
                  style: style(),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  _format(item.amount),
                  style: style(),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _totalRow(
    String label,
    String value,
    pw.TextStyle style,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  PdfPageFormat _thermalPageFormat() => thermalReceiptPdfFormat(
        size: settings.thermalPageSize,
        heightMm: estimateThermalReceiptHeightMm(
          settings: settings,
          itemCount: invoice.items.length,
          customerName: invoice.customerName,
        ),
      );

  double _thermalBaseFontSize() {
    final scale = switch (settings.thermalPageSize) {
      ThermalPageSize.twoInch => 0.9,
      ThermalPageSize.threeInch => 1.0,
      ThermalPageSize.fourInch => 1.12,
    };
    return 9.5 * scale;
  }

  double _invoiceTextSize() => switch (settings.invoiceTextSize) {
        PrintTextSize.small => 8,
        PrintTextSize.medium => 10,
        PrintTextSize.large => 12,
      };

  double _companyTextSize() => switch (settings.companyTextSize) {
        PrintTextSize.small => 8,
        PrintTextSize.medium => 10,
        PrintTextSize.large => 12,
      };

  String _format(double value) => _currency.format(value);
}
