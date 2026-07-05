import 'package:billing_baba/features/print/application/print_amount_words.dart';
import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_line_item.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_fonts.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_theme.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

final _dateFormat = DateFormat('dd MMM yyyy');

abstract final class InvoicePdfSections {
  static pw.Widget? watermark(String status) {
    final label = switch (status) {
      'draft' => 'DRAFT',
      'cancelled' => 'CANCELLED',
      _ => null,
    };
    if (label == null) return null;

    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Center(
        child: pw.Transform.rotate(
          angle: -0.4,
          child: pw.Text(
            label,
            style: InvoicePdfFonts.style(
              fontSize: 72,
              fontWeight: pw.FontWeight.bold,
              color: InvoicePdfTheme.watermark,
            ),
          ),
        ),
      ),
    );
  }

  static pw.Widget companySection(PrintableDocument document) {
    final company = document.company.profile;
    final hasLogo = document.assets.logoBytes != null;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (hasLogo) ...[
          pw.Container(
            height: 48,
            width: 48,
            child: pw.Image(
              pw.MemoryImage(document.assets.logoBytes!),
            ),
          ),
          pw.SizedBox(width: 12),
        ],
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(company.name, style: InvoicePdfTheme.heading(size: 14)),
              if (company.gstin != null && company.gstin!.isNotEmpty)
                pw.Text(
                  'GSTIN: ${company.gstin}',
                  style: InvoicePdfTheme.mutedBody(),
                ),
              if (company.address != null && company.address!.isNotEmpty)
                pw.Text(company.address!, style: InvoicePdfTheme.mutedBody()),
              if (company.pincode != null && company.pincode!.isNotEmpty)
                pw.Text(
                  'PIN: ${company.pincode}',
                  style: InvoicePdfTheme.mutedBody(),
                ),
              if (company.state != null && company.state!.isNotEmpty)
                pw.Text(company.state!, style: InvoicePdfTheme.mutedBody()),
              if (company.phone != null && company.phone!.isNotEmpty)
                pw.Text(
                  'Phone: ${company.phone}',
                  style: InvoicePdfTheme.mutedBody(),
                ),
              if (company.email != null && company.email!.isNotEmpty)
                pw.Text(
                  'Email: ${company.email}',
                  style: InvoicePdfTheme.mutedBody(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget invoiceHeaderSection(PrintableDocument document) {
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
              pw.Text('TAX INVOICE', style: InvoicePdfTheme.title(size: 16)),
              pw.SizedBox(height: 4),
              pw.Text(
                'Invoice No: ${meta.displayNumber}',
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

  static pw.Widget partySection(PrintableDocument document) {
    final party = document.party;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(10),
      decoration: InvoicePdfTheme.sectionBorder(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Bill To', style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: 6),
          if (party != null) ...[
            pw.Text(party.dto.name, style: InvoicePdfTheme.body()),
            if (party.dto.gstin != null && party.dto.gstin!.isNotEmpty)
              pw.Text(
                'GSTIN: ${party.dto.gstin}',
                style: InvoicePdfTheme.mutedBody(),
              ),
            if (party.dto.state != null && party.dto.state!.isNotEmpty)
              pw.Text(party.dto.state!, style: InvoicePdfTheme.mutedBody()),
            if (party.dto.mobile != null && party.dto.mobile!.isNotEmpty)
              pw.Text(
                'Phone: ${party.dto.mobile}',
                style: InvoicePdfTheme.mutedBody(),
              ),
            if (party.dto.email != null && party.dto.email!.isNotEmpty)
              pw.Text(
                'Email: ${party.dto.email}',
                style: InvoicePdfTheme.mutedBody(),
              ),
          ] else
            pw.Text('Walk-in Customer', style: InvoicePdfTheme.body()),
        ],
      ),
    );
  }

  static List<pw.TableRow> itemsTableHeader({required bool showGst}) {
    return [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: InvoicePdfTheme.headerFill),
        children: [
          _headerCell('#'),
          _headerCell('Description'),
          if (showGst) _headerCell('HSN'),
          _headerCell('Qty'),
          _headerCell('Unit'),
          _headerCell('Rate', align: pw.TextAlign.right),
          _headerCell('Disc.', align: pw.TextAlign.right),
          if (showGst) _headerCell('GST %', align: pw.TextAlign.right),
          _headerCell('Amount', align: pw.TextAlign.right),
        ],
      ),
    ];
  }

  static List<pw.TableRow> itemsTableRows({
    required List<PrintableLineItem> lines,
    required bool showGst,
  }) {
    return [
      for (var i = 0; i < lines.length; i++)
        _itemRow(index: i + 1, item: lines[i], showGst: showGst),
    ];
  }

  static pw.Widget itemsTable({
    required List<PrintableLineItem> lines,
    required bool showGst,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: InvoicePdfTheme.border, width: 0.5),
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
      children: [
        ...itemsTableHeader(showGst: showGst),
        ...itemsTableRows(lines: lines, showGst: showGst),
      ],
    );
  }

  static pw.Widget totalsSection(PrintableDocument document) {
    final totals = document.totals;
    final tax = document.taxSummary;
    final showGst = document.metadata.isGstFormal;

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      child: pw.Row(
        children: [
          pw.Spacer(),
          pw.SizedBox(
            width: 240,
            child: pw.Column(
              children: [
                _totalRow('Subtotal', totals.subtotal),
                _totalRow('Discount', totals.discountTotal),
                if (showGst) ...[
                  _totalRow('CGST', tax.cgstTotal),
                  _totalRow('SGST', tax.sgstTotal),
                  _totalRow('IGST', tax.igstTotal),
                ],
                pw.Divider(color: InvoicePdfTheme.border, height: 8),
                _totalRow(
                  'Grand Total',
                  totals.totalAmount,
                  bold: true,
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

  static pw.Widget notesSection(PrintableDocument document) {
    final notes = document.metadata.notes;
    if (notes == null || notes.trim().isEmpty) {
      return pw.SizedBox();
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Notes', style: InvoicePdfTheme.heading(size: 9)),
          pw.SizedBox(height: 4),
          pw.Text(notes, style: InvoicePdfTheme.body()),
        ],
      ),
    );
  }

  static pw.Widget signatureSection(PrintableDocument document) {
    final hasSignature = document.assets.signatureBytes != null;

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 24),
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

  static pw.TableRow _itemRow({
    required int index,
    required PrintableLineItem item,
    required bool showGst,
  }) {
    final line = item.line;
    final description = item.description != null && item.description!.isNotEmpty
        ? '${item.displayName}\n${item.description}'
        : item.displayName;

    return pw.TableRow(
      children: [
        _cell('$index'),
        _cell(description),
        if (showGst) _cell(item.hsnCode ?? '-'),
        _cell(line.quantity),
        _cell(line.unit),
        _cell(_format(line.unitPrice), align: pw.TextAlign.right),
        _cell(_format(line.discountAmount), align: pw.TextAlign.right),
        if (showGst) _cell('${line.taxRate}%', align: pw.TextAlign.right),
        _cell(_format(line.lineTotal), align: pw.TextAlign.right),
      ],
    );
  }

  static pw.Widget _cell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Align(
        alignment: _toAlignment(align),
        child: pw.Text(text, style: InvoicePdfTheme.tableCell()),
      ),
    );
  }

  static pw.Widget _totalRow(String label, String amount, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: bold
                ? InvoicePdfTheme.heading(size: 9)
                : InvoicePdfTheme.body(),
          ),
          pw.Text(
            _format(amount),
            style: bold
                ? InvoicePdfTheme.heading(size: 9)
                : InvoicePdfTheme.body(),
          ),
        ],
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
