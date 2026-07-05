import 'package:billing_baba/features/print/application/print_amount_words.dart';
import 'package:billing_baba/features/print/models/printable_allocation.dart';
import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_sections.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_theme.dart';
import 'package:billing_baba/features/print/templates/voucher/voucher_layout_config.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

final _dateFormat = DateFormat('dd MMM yyyy');

abstract final class VoucherPdfSections {
  static pw.Widget? watermark(String status) =>
      CommercialDocumentPdfSections.watermark(status);

  static pw.Widget companySection(PrintableDocument document) =>
      CommercialDocumentPdfSections.companySection(document);

  static pw.Widget voucherHeaderSection(
    PrintableDocument document,
    VoucherLayoutConfig config,
  ) {
    final meta = document.metadata;
    final date = DateTime.tryParse(meta.documentDate);

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16, bottom: 12),
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: InvoicePdfTheme.border),
          bottom: pw.BorderSide(color: InvoicePdfTheme.border),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(config.title, style: InvoicePdfTheme.title(size: 16)),
              pw.SizedBox(height: 4),
              pw.Text(
                '${config.voucherNumberLabel}: ${meta.displayNumber}',
                style: InvoicePdfTheme.heading(size: 9),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Date: ${date != null ? _dateFormat.format(date) : meta.documentDate}',
                style: InvoicePdfTheme.body(),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Status: ${_statusLabel(meta.status)}',
                style: InvoicePdfTheme.body(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget partySection(
    PrintableDocument document,
    VoucherLayoutConfig config,
  ) {
    final party = document.party;
    final batch = document.purchaseFaBatch;
    final expense = document.expense;

    final displayName = party?.dto.name ??
        expense?.partyName ??
        batch?.partyName ??
        '—';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(10),
      decoration: InvoicePdfTheme.sectionBorder(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(config.partyHeading, style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: 6),
          pw.Text(displayName, style: InvoicePdfTheme.body()),
          if (party?.dto.gstin != null && party!.dto.gstin!.isNotEmpty)
            pw.Text(
              'GSTIN: ${party.dto.gstin}',
              style: InvoicePdfTheme.mutedBody(),
            ),
          if (party?.dto.mobile != null && party!.dto.mobile!.isNotEmpty)
            pw.Text(
              'Phone: ${party.dto.mobile}',
              style: InvoicePdfTheme.mutedBody(),
            ),
          if (party?.dto.email != null && party!.dto.email!.isNotEmpty)
            pw.Text(
              'Email: ${party.dto.email}',
              style: InvoicePdfTheme.mutedBody(),
            ),
        ],
      ),
    );
  }

  static pw.Widget detailsSection(PrintableDocument document) {
    final meta = document.metadata;
    final payment = document.payment;
    final expense = document.expense;
    final batch = document.purchaseFaBatch;
    final order = document.jobWorkOrder;

    final rows = <(String, String)>[];

    if (payment != null) {
      if (payment.referenceNumber != null && payment.referenceNumber!.isNotEmpty) {
        rows.add(('Reference', payment.referenceNumber!));
      }
      rows.add(('Payment Method', payment.paymentMode));
      rows.add(('Amount', _format(payment.amount)));
      if (payment.notes != null && payment.notes!.trim().isNotEmpty) {
        rows.add(('Notes', payment.notes!));
      }
    } else if (expense != null) {
      if (meta.expenseCategoryName != null &&
          meta.expenseCategoryName!.isNotEmpty) {
        rows.add(('Expense Category', meta.expenseCategoryName!));
      }
      if (meta.expenseDescription != null &&
          meta.expenseDescription!.isNotEmpty) {
        rows.add(('Description', meta.expenseDescription!));
      }
      if (expense.referenceNumber != null &&
          expense.referenceNumber!.isNotEmpty) {
        rows.add(('Reference', expense.referenceNumber!));
      }
      if (expense.paymentMode != null && expense.paymentMode!.isNotEmpty) {
        rows.add(('Payment Method', expense.paymentMode!));
      }
      rows.add(('Amount', _format(expense.amount)));
      if (expense.notes != null && expense.notes!.trim().isNotEmpty) {
        rows.add(('Notes', expense.notes!));
      }
    } else if (batch != null) {
      if (batch.referenceNumber != null && batch.referenceNumber!.isNotEmpty) {
        rows.add(('Reference', batch.referenceNumber!));
      }
      if (batch.paymentMode != null && batch.paymentMode!.isNotEmpty) {
        rows.add(('Payment Method', batch.paymentMode!));
      }
      rows.add(('Purchase Value', _format(batch.totalAmount)));
      if (batch.notes != null && batch.notes!.trim().isNotEmpty) {
        rows.add(('Notes', batch.notes!));
      }
    } else if (order != null) {
      if (order.finishedGoodName.isNotEmpty) {
        rows.add((
          'Finished Good',
          '${order.finishedGoodName} (${order.finishedGoodQuantity} ${order.finishedGoodUnit})',
        ));
      }
      if (order.deliveryDate != null) {
        final delivery = DateTime.tryParse(order.deliveryDate!);
        rows.add((
          'Delivery Date',
          delivery != null ? _dateFormat.format(delivery) : order.deliveryDate!,
        ));
      }
      rows.add(('Grand Total', _format(order.grandTotal)));
      if (order.notes != null && order.notes!.trim().isNotEmpty) {
        rows.add(('Notes', order.notes!));
      }
    }

    if (rows.isEmpty) return pw.SizedBox();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(10),
      decoration: InvoicePdfTheme.sectionBorder(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Voucher Details', style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: 6),
          for (final (label, value) in rows) ...[
            _detailRow(label, value),
            pw.SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  static pw.Widget allocationTable(List<PrintableAllocation> allocations) {
    if (allocations.isEmpty) return pw.SizedBox();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Allocation', style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: InvoicePdfTheme.border, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(1.5),
              2: pw.FlexColumnWidth(1.5),
              3: pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: InvoicePdfTheme.headerFill,
                ),
                children: [
                  _headerCell('Invoice No'),
                  _headerCell('Invoice Date'),
                  _headerCell('Allocated', align: pw.TextAlign.right),
                  _headerCell('Balance', align: pw.TextAlign.right),
                ],
              ),
              for (final row in allocations)
                pw.TableRow(
                  children: [
                    _cell(row.invoiceNumber),
                    _cell(row.invoiceDate),
                    _cell(_format(row.allocatedAmount), align: pw.TextAlign.right),
                    _cell(
                      row.balance != null ? _format(row.balance!) : '—',
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget assetTable(PrintableDocument document) {
    final batch = document.purchaseFaBatch;
    if (batch == null || batch.assets.isEmpty) return pw.SizedBox();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Assets', style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: InvoicePdfTheme.border, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FixedColumnWidth(48),
              2: pw.FixedColumnWidth(56),
              3: pw.FixedColumnWidth(64),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: InvoicePdfTheme.headerFill,
                ),
                children: [
                  _headerCell('Asset'),
                  _headerCell('Qty'),
                  _headerCell('Rate', align: pw.TextAlign.right),
                  _headerCell('Amount', align: pw.TextAlign.right),
                ],
              ),
              for (final asset in batch.assets)
                pw.TableRow(
                  children: [
                    _cell(
                      asset.assetCategory != null &&
                              asset.assetCategory!.isNotEmpty
                          ? '${asset.assetName}\n${asset.assetCategory}'
                          : asset.assetName,
                      maxLines: 3,
                    ),
                    _cell(asset.qty),
                    _cell(_format(asset.purchasePrice), align: pw.TextAlign.right),
                    _cell(_format(asset.lineTotal), align: pw.TextAlign.right),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget jobWorkMaterialsTable(PrintableDocument document) {
    final order = document.jobWorkOrder;
    if (order == null || order.rawMaterials.isEmpty) return pw.SizedBox();

    final names = document.jobWorkMaterialNames;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Materials', style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: InvoicePdfTheme.border, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FixedColumnWidth(40),
              2: pw.FixedColumnWidth(40),
              3: pw.FixedColumnWidth(56),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: InvoicePdfTheme.headerFill,
                ),
                children: [
                  _headerCell('Item'),
                  _headerCell('Qty'),
                  _headerCell('Unit'),
                  _headerCell('Amount', align: pw.TextAlign.right),
                ],
              ),
              for (final line in order.rawMaterials)
                pw.TableRow(
                  children: [
                    _cell(names[line.itemId] ?? line.itemId),
                    _cell(line.quantity),
                    _cell(line.unit),
                    _cell(_format(line.lineTotal), align: pw.TextAlign.right),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget jobWorkChargesTable(PrintableDocument document) {
    final order = document.jobWorkOrder;
    if (order == null || order.additionalCosts.isEmpty) return pw.SizedBox();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Additional Charges', style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: InvoicePdfTheme.border, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FixedColumnWidth(72),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: InvoicePdfTheme.headerFill,
                ),
                children: [
                  _headerCell('Charge'),
                  _headerCell('Amount', align: pw.TextAlign.right),
                ],
              ),
              for (final cost in order.additionalCosts)
                pw.TableRow(
                  children: [
                    _cell(cost.label),
                    _cell(_format(cost.amount), align: pw.TextAlign.right),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget totalSection(PrintableDocument document) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        children: [
          pw.Spacer(),
          pw.SizedBox(
            width: 260,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Amount', style: InvoicePdfTheme.heading(size: 10)),
                pw.Text(
                  _format(document.totals.totalAmount),
                  style: InvoicePdfTheme.heading(size: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget amountInWordsSection(PrintableDocument document) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.all(8),
      decoration: InvoicePdfTheme.sectionBorder(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Amount in Words', style: InvoicePdfTheme.heading(size: 9)),
          pw.SizedBox(height: 4),
          pw.Text(
            PrintAmountWords.fromAmount(document.totals.totalAmount),
            style: InvoicePdfTheme.body(),
          ),
        ],
      ),
    );
  }

  static pw.Widget signatureSection(PrintableDocument document) {
    final hasSignature = document.assets.signatureBytes != null;

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 24, bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Column(
            children: [
              if (hasSignature)
                pw.SizedBox(
                  height: 48,
                  width: 120,
                  child: pw.Image(
                    pw.MemoryImage(document.assets.signatureBytes!),
                  ),
                ),
              if (hasSignature) pw.SizedBox(height: 4),
              pw.Container(
                width: 160,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: InvoicePdfTheme.border),
                  ),
                ),
                padding: const pw.EdgeInsets.only(top: 6),
                child: pw.Text(
                  'Authorized Signature',
                  style: InvoicePdfTheme.mutedBody(size: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget footerSection(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: InvoicePdfTheme.mutedBody(size: 8),
      ),
    );
  }

  static pw.Widget _detailRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(label, style: InvoicePdfTheme.mutedBody()),
        ),
        pw.Expanded(child: pw.Text(value, style: InvoicePdfTheme.body())),
      ],
    );
  }

  static pw.Widget _headerCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: pw.Align(
        alignment: _toAlignment(align),
        child: pw.Text(text, style: InvoicePdfTheme.tableHeader()),
      ),
    );
  }

  static pw.Widget _cell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    int maxLines = 2,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Align(
        alignment: _toAlignment(align),
        child: pw.Text(
          text,
          style: InvoicePdfTheme.tableCell(),
          maxLines: maxLines,
          overflow: pw.TextOverflow.clip,
        ),
      ),
    );
  }

  static String _format(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return value;
    return _currencyFormat.format(parsed);
  }

  static String _statusLabel(String status) {
    return switch (status) {
      'draft' => 'Draft',
      'finalized' => 'Finalized',
      'cancelled' => 'Cancelled',
      'converted' => 'Converted',
      'open' => 'Open',
      'closed' => 'Closed',
      _ => status,
    };
  }

  static pw.Alignment _toAlignment(pw.TextAlign align) {
    return switch (align) {
      pw.TextAlign.right => pw.Alignment.centerRight,
      pw.TextAlign.center => pw.Alignment.center,
      _ => pw.Alignment.centerLeft,
    };
  }
}
