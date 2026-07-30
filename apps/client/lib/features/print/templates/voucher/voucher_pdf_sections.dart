import 'package:billing_baba/features/print/application/print_amount_words.dart';
import 'package:billing_baba/features/print/models/printable_allocation.dart';
import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_sections.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_theme.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_widgets.dart';
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
      InvoicePdfWidgets.watermark(status);

  static pw.Widget pageHeaderSection(
    PrintableDocument document,
    VoucherLayoutConfig config,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _voucherHeader(document, config),
        pw.SizedBox(height: InvoicePdfTheme.spacingLg),
        partySection(document, config),
        detailsSection(document),
      ],
    );
  }

  static pw.Widget companySection(PrintableDocument document) =>
      CommercialDocumentPdfSections.companySection(document);

  static pw.Widget voucherHeaderSection(
    PrintableDocument document,
    VoucherLayoutConfig config,
  ) => _voucherHeader(document, config);

  static pw.Widget _voucherHeader(
    PrintableDocument document,
    VoucherLayoutConfig config,
  ) {
    final meta = document.metadata;
    final date = DateTime.tryParse(meta.documentDate);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: companySection(document)),
        pw.SizedBox(width: InvoicePdfTheme.spacingLg),
        pw.SizedBox(
          width: 210,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                config.title,
                style: InvoicePdfTheme.documentTitle(),
                textAlign: pw.TextAlign.right,
              ),
              pw.SizedBox(height: InvoicePdfTheme.spacingSm),
              InvoicePdfWidgets.metaLine(
                config.voucherNumberLabel,
                meta.displayNumber,
              ),
              InvoicePdfWidgets.metaLine(
                'Date',
                date != null ? _dateFormat.format(date) : meta.documentDate,
              ),
              pw.SizedBox(height: InvoicePdfTheme.spacingXs),
              InvoicePdfWidgets.statusBadge(meta.status),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget partySection(
    PrintableDocument document,
    VoucherLayoutConfig config,
  ) {
    final party = document.party;
    final purchaseBatch = document.purchaseFaBatch;
    final saleBatch = document.saleFaBatch;
    final expense = document.expense;

    final displayName = party?.dto.name ??
        expense?.partyName ??
        purchaseBatch?.partyName ??
        saleBatch?.partyName;

    if (displayName == null || displayName.trim().isEmpty) {
      return pw.SizedBox();
    }

    final lines = <pw.Widget>[
      InvoicePdfWidgets.partyLine(displayName.trim(), emphasized: true),
    ];

    if (party?.dto.gstin != null && party!.dto.gstin!.isNotEmpty) {
      lines.add(InvoicePdfWidgets.labeledPartyLine('GSTIN', party.dto.gstin!));
    }
    if (party?.dto.state != null && party!.dto.state!.isNotEmpty) {
      lines.add(InvoicePdfWidgets.labeledPartyLine('State', party.dto.state!));
    }
    if (party?.dto.mobile != null && party!.dto.mobile!.isNotEmpty) {
      lines.add(InvoicePdfWidgets.labeledPartyLine('Phone', party.dto.mobile!));
    }
    if (party?.dto.email != null && party!.dto.email!.isNotEmpty) {
      lines.add(InvoicePdfWidgets.labeledPartyLine('Email', party.dto.email!));
    }

    return InvoicePdfWidgets.partyCard(
      heading: config.partyHeading,
      lines: lines,
    );
  }

  static pw.Widget detailsSection(PrintableDocument document) {
    final meta = document.metadata;
    final payment = document.payment;
    final expense = document.expense;
    final purchaseBatch = document.purchaseFaBatch;
    final saleBatch = document.saleFaBatch;
    final order = document.jobWorkOrder;

    final rows = <(String, String)>[];

    if (payment != null) {
      if (payment.referenceNumber != null &&
          payment.referenceNumber!.isNotEmpty) {
        rows.add(('Reference', payment.referenceNumber!));
      }
      rows.add(('Payment Method', payment.paymentMode));
      rows.add(('Amount', _format(payment.amount)));
      if (payment.notes != null && payment.notes!.trim().isNotEmpty) {
        rows.add(('Notes', payment.notes!.trim()));
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
        rows.add(('Notes', expense.notes!.trim()));
      }
    } else if (purchaseBatch != null) {
      if (purchaseBatch.referenceNumber != null &&
          purchaseBatch.referenceNumber!.isNotEmpty) {
        rows.add(('Reference', purchaseBatch.referenceNumber!));
      }
      if (purchaseBatch.paymentMode != null &&
          purchaseBatch.paymentMode!.isNotEmpty) {
        rows.add(('Payment Method', purchaseBatch.paymentMode!));
      }
      rows.add(('Purchase Value', _format(purchaseBatch.totalAmount)));
      if (purchaseBatch.notes != null && purchaseBatch.notes!.trim().isNotEmpty) {
        rows.add(('Notes', purchaseBatch.notes!.trim()));
      }
    } else if (saleBatch != null) {
      if (saleBatch.referenceNumber != null &&
          saleBatch.referenceNumber!.isNotEmpty) {
        rows.add(('Reference', saleBatch.referenceNumber!));
      }
      if (saleBatch.paymentMode != null && saleBatch.paymentMode!.isNotEmpty) {
        rows.add(('Payment Method', saleBatch.paymentMode!));
      }
      rows.add(('Sale Value', _format(saleBatch.totalAmount)));
      if (saleBatch.notes != null && saleBatch.notes!.trim().isNotEmpty) {
        rows.add(('Notes', saleBatch.notes!.trim()));
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
        rows.add(('Notes', order.notes!.trim()));
      }
    }

    if (rows.isEmpty) return pw.SizedBox();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: InvoicePdfTheme.spacingMd),
      padding: const pw.EdgeInsets.all(InvoicePdfTheme.spacingMd),
      decoration: InvoicePdfTheme.cardDecoration(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Voucher Details', style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: InvoicePdfTheme.spacingSm),
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
      margin: const pw.EdgeInsets.only(bottom: InvoicePdfTheme.spacingMd),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Allocation', style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: InvoicePdfTheme.spacingSm),
          pw.Table(
            border: pw.TableBorder.all(
              color: InvoicePdfTheme.border,
              width: 0.5,
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(1.5),
              2: pw.FlexColumnWidth(1.5),
              3: pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                repeat: true,
                decoration: const pw.BoxDecoration(
                  color: InvoicePdfTheme.headerFill,
                ),
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  InvoicePdfWidgets.tableHeaderCell('Invoice No'),
                  InvoicePdfWidgets.tableHeaderCell('Invoice Date'),
                  InvoicePdfWidgets.tableHeaderCell(
                    'Allocated',
                    align: pw.TextAlign.right,
                  ),
                  InvoicePdfWidgets.tableHeaderCell(
                    'Balance',
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
              for (final row in allocations)
                pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    InvoicePdfWidgets.tableBodyCell(row.invoiceNumber),
                    InvoicePdfWidgets.tableBodyCell(row.invoiceDate),
                    InvoicePdfWidgets.tableBodyCell(
                      _format(row.allocatedAmount),
                      align: pw.TextAlign.right,
                    ),
                    InvoicePdfWidgets.tableBodyCell(
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
    final purchaseBatch = document.purchaseFaBatch;
    final saleBatch = document.saleFaBatch;
    if (purchaseBatch != null && purchaseBatch.assets.isNotEmpty) {
      return _assetTable(
        assets: [
          for (final asset in purchaseBatch.assets)
            (
              name: asset.assetCategory != null &&
                      asset.assetCategory!.isNotEmpty
                  ? '${asset.assetName}\n${asset.assetCategory}'
                  : asset.assetName,
              qty: asset.qty,
              rate: asset.purchasePrice,
              total: asset.lineTotal,
            ),
        ],
      );
    }
    if (saleBatch != null && saleBatch.assets.isNotEmpty) {
      return _assetTable(
        assets: [
          for (final asset in saleBatch.assets)
            (
              name: asset.assetCategory != null &&
                      asset.assetCategory!.isNotEmpty
                  ? '${asset.assetName}\n${asset.assetCategory}'
                  : asset.assetName,
              qty: asset.qty,
              rate: asset.salePrice,
              total: asset.lineTotal,
            ),
        ],
      );
    }
    return pw.SizedBox();
  }

  static pw.Widget _assetTable({
    required List<
        ({
          String name,
          String qty,
          String rate,
          String total,
        })> assets,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: InvoicePdfTheme.spacingMd),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Assets', style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: InvoicePdfTheme.spacingSm),
          pw.Table(
            border: pw.TableBorder.all(
              color: InvoicePdfTheme.border,
              width: 0.5,
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FixedColumnWidth(48),
              2: pw.FixedColumnWidth(56),
              3: pw.FixedColumnWidth(64),
            },
            children: [
              pw.TableRow(
                repeat: true,
                decoration: const pw.BoxDecoration(
                  color: InvoicePdfTheme.headerFill,
                ),
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  InvoicePdfWidgets.tableHeaderCell('Asset'),
                  InvoicePdfWidgets.tableHeaderCell(
                    'Qty',
                    align: pw.TextAlign.right,
                  ),
                  InvoicePdfWidgets.tableHeaderCell(
                    'Rate',
                    align: pw.TextAlign.right,
                  ),
                  InvoicePdfWidgets.tableHeaderCell(
                    'Amount',
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
              for (final asset in assets)
                pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    InvoicePdfWidgets.tableBodyCell(asset.name),
                    InvoicePdfWidgets.tableBodyCell(
                      asset.qty,
                      align: pw.TextAlign.right,
                    ),
                    InvoicePdfWidgets.tableBodyCell(
                      _format(asset.rate),
                      align: pw.TextAlign.right,
                    ),
                    InvoicePdfWidgets.tableBodyCell(
                      _format(asset.total),
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

  static pw.Widget jobWorkMaterialsTable(PrintableDocument document) {
    final order = document.jobWorkOrder;
    if (order == null || order.rawMaterials.isEmpty) return pw.SizedBox();

    final names = document.jobWorkMaterialNames;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: InvoicePdfTheme.spacingMd),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Materials', style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: InvoicePdfTheme.spacingSm),
          pw.Table(
            border: pw.TableBorder.all(
              color: InvoicePdfTheme.border,
              width: 0.5,
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FixedColumnWidth(40),
              2: pw.FixedColumnWidth(40),
              3: pw.FixedColumnWidth(56),
            },
            children: [
              pw.TableRow(
                repeat: true,
                decoration: const pw.BoxDecoration(
                  color: InvoicePdfTheme.headerFill,
                ),
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  InvoicePdfWidgets.tableHeaderCell('Item'),
                  InvoicePdfWidgets.tableHeaderCell(
                    'Qty',
                    align: pw.TextAlign.right,
                  ),
                  InvoicePdfWidgets.tableHeaderCell(
                    'Unit',
                    align: pw.TextAlign.center,
                  ),
                  InvoicePdfWidgets.tableHeaderCell(
                    'Amount',
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
              for (final line in order.rawMaterials)
                pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    InvoicePdfWidgets.tableBodyCell(
                      names[line.itemId] ?? line.itemId,
                    ),
                    InvoicePdfWidgets.tableBodyCell(
                      line.quantity,
                      align: pw.TextAlign.right,
                    ),
                    InvoicePdfWidgets.tableBodyCell(
                      line.unit,
                      align: pw.TextAlign.center,
                    ),
                    InvoicePdfWidgets.tableBodyCell(
                      _format(line.lineTotal),
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

  static pw.Widget jobWorkChargesTable(PrintableDocument document) {
    final order = document.jobWorkOrder;
    if (order == null || order.additionalCosts.isEmpty) return pw.SizedBox();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: InvoicePdfTheme.spacingMd),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Additional Charges', style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: InvoicePdfTheme.spacingSm),
          pw.Table(
            border: pw.TableBorder.all(
              color: InvoicePdfTheme.border,
              width: 0.5,
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FixedColumnWidth(72),
            },
            children: [
              pw.TableRow(
                repeat: true,
                decoration: const pw.BoxDecoration(
                  color: InvoicePdfTheme.headerFill,
                ),
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  InvoicePdfWidgets.tableHeaderCell('Charge'),
                  InvoicePdfWidgets.tableHeaderCell(
                    'Amount',
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
              for (final cost in order.additionalCosts)
                pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    InvoicePdfWidgets.tableBodyCell(cost.label),
                    InvoicePdfWidgets.tableBodyCell(
                      _format(cost.amount),
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

  static pw.Widget totalSection(PrintableDocument document) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(
        top: InvoicePdfTheme.totalsMarginTop,
        bottom: InvoicePdfTheme.totalsMarginBottom,
      ),
      child: pw.Row(
        children: [
          pw.Spacer(),
          pw.SizedBox(
            width: 280,
            child: pw.Container(
              decoration: InvoicePdfTheme.totalsBoxDecoration(),
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: InvoicePdfTheme.grandTotalDecoration(),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Amount',
                      style: InvoicePdfTheme.grandTotalLabel(),
                    ),
                    pw.Text(
                      _format(document.totals.totalAmount),
                      style: InvoicePdfTheme.grandTotalValue(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget amountInWordsSection(PrintableDocument document) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: InvoicePdfTheme.spacingSm),
      child: InvoicePdfWidgets.infoBox(
        heading: 'Amount in Words',
        body: PrintAmountWords.fromAmount(document.totals.totalAmount),
      ),
    );
  }

  static pw.Widget signatureSection(PrintableDocument document) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(
        top: InvoicePdfTheme.spacingXl,
        bottom: InvoicePdfTheme.spacingSm,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          InvoicePdfWidgets.signatureBlock(
            signatureBytes: document.assets.signatureBytes,
          ),
        ],
      ),
    );
  }

  static pw.Widget closingSection(
    PrintableDocument document,
    VoucherLayoutConfig config,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        totalSection(document),
        if (config.showAmountInWords) amountInWordsSection(document),
        if (config.showSignature) signatureSection(document),
      ],
    );
  }

  static pw.Widget footerSection(pw.Context context) =>
      InvoicePdfWidgets.documentFooter(context);

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

  static String _format(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return value;
    return _currencyFormat.format(parsed);
  }
}
