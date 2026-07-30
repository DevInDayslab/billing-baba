import 'dart:typed_data';

import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_fonts.dart';
import 'package:billing_baba/features/print/templates/print_template.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Compact POS receipt PDF (58mm thermal width with A4 fallback).
class PosReceiptTemplate implements PrintTemplate {
  @override
  String get id => 'pos_receipt_v1';

  @override
  bool supports(PrintableDocumentKind kind) =>
      kind == PrintableDocumentKind.posReceipt;

  @override
  Future<Uint8List> render(PrintableDocument document) async {
    throw UnsupportedError(
      'Use renderSale() for POS receipts with local sale data.',
    );
  }

  Future<Uint8List> renderSale({
    required PosSale sale,
    required String businessName,
    String? address,
    String? gstin,
    String? cashier,
  }) async {
    await InvoicePdfFonts.ensureLoaded();

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs ',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    final cgstTotal = sale.items.fold<double>(
      0,
      (sum, item) => sum + (item.cgstAmount ?? 0),
    );
    final sgstTotal = sale.items.fold<double>(
      0,
      (sum, item) => sum + (item.sgstAmount ?? 0),
    );

    final pdf = pw.Document();
    const pageFormat = PdfPageFormat(
      58 * PdfPageFormat.mm,
      double.infinity,
      marginAll: 4 * PdfPageFormat.mm,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                businessName,
                style: InvoicePdfFonts.style(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              if (address != null && address.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  address,
                  style: InvoicePdfFonts.style(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ],
              if (gstin != null && gstin.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  'GSTIN: $gstin',
                  style: InvoicePdfFonts.style(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ],
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 4),
              pw.Text(
                sale.docNumber,
                style: InvoicePdfFonts.style(
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                dateFormat.format(sale.completedAt),
                style: InvoicePdfFonts.style(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                sale.displayName,
                style: InvoicePdfFonts.style(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
              if (cashier != null && cashier.isNotEmpty)
                pw.Text(
                  'Cashier: $cashier',
                  style: InvoicePdfFonts.style(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5),
              _itemsTable(sale, currency),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5),
              _totalRow('Subtotal', currency.format(sale.totalAmount)),
              if (cgstTotal > 0 || sgstTotal > 0) ...[
                _totalRow('CGST', currency.format(cgstTotal)),
                _totalRow('SGST', currency.format(sgstTotal)),
              ] else
                _totalRow('Tax', currency.format(sale.taxAmount)),
              pw.SizedBox(height: 2),
              _totalRow(
                'Grand Total',
                currency.format(sale.finalAmount),
                bold: true,
              ),
              pw.SizedBox(height: 4),
              if (sale.payments.length > 1)
                for (final payment in sale.payments)
                  _totalRow(
                    _paymentModeLabel(payment.mode),
                    currency.format(payment.amount),
                  )
              else
                _totalRow('Payment', _paymentSummary(sale, currency)),
              pw.SizedBox(height: 8),
              pw.Text(
                'Thank you for your purchase!',
                style: InvoicePdfFonts.style(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _itemsTable(PosSale sale, NumberFormat currency) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.IntrinsicColumnWidth(),
        2: const pw.IntrinsicColumnWidth(),
        3: const pw.IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        pw.TableRow(
          children: [
            _headerCell('Item'),
            _headerCell('Qty', align: pw.TextAlign.right),
            _headerCell('Rate', align: pw.TextAlign.right),
            _headerCell('Total', align: pw.TextAlign.right),
          ],
        ),
        for (final item in sale.items)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text(
                  item.name,
                  style: InvoicePdfFonts.style(fontSize: 8),
                  maxLines: 2,
                ),
              ),
              _cell('${item.quantity}', align: pw.TextAlign.right),
              _cell(
                currency.format(
                  item.unitPrice ??
                      (item.quantity > 0 ? item.lineTotal / item.quantity : 0),
                ),
                align: pw.TextAlign.right,
              ),
              _cell(
                currency.format(item.lineTotal),
                align: pw.TextAlign.right,
                bold: true,
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _headerCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(
        text,
        style: InvoicePdfFonts.style(
          fontSize: 7,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: align,
      ),
    );
  }

  pw.Widget _cell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Text(
        text,
        style: InvoicePdfFonts.style(
          fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  pw.Widget _totalRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: InvoicePdfFonts.style(
              fontSize: bold ? 10 : 8,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: InvoicePdfFonts.style(
              fontSize: bold ? 10 : 8,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _paymentSummary(PosSale sale, NumberFormat currency) {
    if (sale.payments.isNotEmpty) {
      final payment = sale.payments.first;
      return '${_paymentModeLabel(payment.mode)} ${currency.format(payment.amount)}';
    }
    return switch (sale.paymentMethod?.split(',').first.trim()) {
      'upi' => 'UPI',
      'card' => 'Card',
      'bank_transfer' => 'Bank',
      _ => 'Cash',
    };
  }

  String _paymentModeLabel(PaymentMode mode) => switch (mode) {
    PaymentMode.cash => 'Cash',
    PaymentMode.upi => 'UPI',
    PaymentMode.card => 'Card',
    PaymentMode.bank => 'Bank',
  };
}
