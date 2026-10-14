import 'package:billing_baba/features/print/application/print_amount_words.dart';
import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_line_item.dart';
import 'package:billing_baba/features/print/models/printable_party.dart';
import 'package:billing_baba/features/print/templates/commercial_document_layout_config.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_table_layout.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_theme.dart';
import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_widgets.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

final _dateFormat = DateFormat('dd MMM yyyy');

abstract final class CommercialDocumentPdfSections {
  static pw.Widget? watermark(String status) =>
      InvoicePdfWidgets.watermark(status);

  /// Company header + document meta + bill-to card (first page only).
  static pw.Widget pageHeaderSection(
    PrintableDocument document,
    CommercialDocumentLayoutConfig config,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _companyAndDocumentHeader(document, config),
        pw.SizedBox(height: InvoicePdfTheme.spacingLg),
        partySection(document, config),
      ],
    );
  }

  static pw.Widget _companyAndDocumentHeader(
    PrintableDocument document,
    CommercialDocumentLayoutConfig config,
  ) {
    final company = document.company.profile;
    final meta = document.metadata;
    final date = DateTime.tryParse(meta.documentDate);
    final dueDate = meta.dueDate != null
        ? DateTime.tryParse(meta.dueDate!)
        : null;
    final hasLogo = document.assets.logoBytes != null;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (hasLogo) ...[
                InvoicePdfWidgets.companyLogo(
                  bytes: document.assets.logoBytes!,
                ),
                pw.SizedBox(width: InvoicePdfTheme.spacingMd),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(company.name, style: InvoicePdfTheme.companyName()),
                    ..._companyDetailLines(
                      company.address,
                      company.gstin,
                      company.phone,
                      company.email,
                      company.pincode,
                      company.state,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                config.documentNumberLabel,
                meta.displayNumber,
              ),
              if (config.showSupplierInvoiceNumber &&
                  meta.supplierInvoiceNumber != null &&
                  meta.supplierInvoiceNumber!.isNotEmpty)
                InvoicePdfWidgets.metaLine(
                  'Supplier Inv.',
                  meta.supplierInvoiceNumber!,
                ),
              InvoicePdfWidgets.metaLine(
                'Date',
                date != null ? _dateFormat.format(date) : meta.documentDate,
              ),
              if (config.showDueDate && dueDate != null)
                InvoicePdfWidgets.metaLine(
                  'Due Date',
                  _dateFormat.format(dueDate),
                ),
              pw.SizedBox(height: InvoicePdfTheme.spacingXs),
              InvoicePdfWidgets.statusBadge(meta.status),
            ],
          ),
        ),
      ],
    );
  }

  static List<pw.Widget> _companyDetailLines(
    String? address,
    String? gstin,
    String? phone,
    String? email,
    String? pincode,
    String? state,
  ) {
    final lines = <pw.Widget>[];

    if (address != null && address.trim().isNotEmpty) {
      lines.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text(address.trim(), style: InvoicePdfTheme.mutedBody()),
        ),
      );
    }

    final location = [
      if (state != null && state.isNotEmpty) state,
      if (pincode != null && pincode.isNotEmpty) pincode,
    ].join(' - ');
    if (location.isNotEmpty) {
      lines.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child: pw.Text(location, style: InvoicePdfTheme.mutedBody()),
        ),
      );
    }

    if (gstin != null && gstin.isNotEmpty) {
      lines.add(InvoicePdfWidgets.labeledPartyLine('GSTIN', gstin));
    }
    if (phone != null && phone.isNotEmpty) {
      lines.add(InvoicePdfWidgets.labeledPartyLine('Phone', phone));
    }
    if (email != null && email.isNotEmpty) {
      lines.add(InvoicePdfWidgets.labeledPartyLine('Email', email));
    }

    return lines;
  }

  static pw.Widget partySection(
    PrintableDocument document,
    CommercialDocumentLayoutConfig config,
  ) {
    return InvoicePdfWidgets.partyCard(
      heading: config.partyHeading,
      lines: _partyLines(document.party, config.emptyPartyLabel),
    );
  }

  static List<pw.Widget> _partyLines(
    PrintableParty? party,
    String emptyLabel,
  ) {
    if (party == null) {
      return [InvoicePdfWidgets.partyLine(emptyLabel, emphasized: true)];
    }

    final dto = party.dto;
    final lines = <pw.Widget>[
      InvoicePdfWidgets.partyLine(dto.name, emphasized: true),
    ];

    if (dto.gstin != null && dto.gstin!.isNotEmpty) {
      lines.add(InvoicePdfWidgets.labeledPartyLine('GSTIN', dto.gstin!));
    }
    if (dto.state != null && dto.state!.isNotEmpty) {
      lines.add(InvoicePdfWidgets.labeledPartyLine('State', dto.state!));
    }
    if (dto.mobile != null && dto.mobile!.isNotEmpty) {
      lines.add(InvoicePdfWidgets.labeledPartyLine('Phone', dto.mobile!));
    }
    if (dto.email != null && dto.email!.isNotEmpty) {
      lines.add(InvoicePdfWidgets.labeledPartyLine('Email', dto.email!));
    }

    return lines;
  }

  static Map<int, pw.TableColumnWidth> tableColumnWidths({
    required bool showGst,
    required bool showLinePricing,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) {
    return InvoicePdfTableLayout.commercialColumns(
      showGst: showGst,
      showLinePricing: showLinePricing,
      pageFormat: pageFormat,
    );
  }

  static List<pw.TableRow> itemsTableHeader({
    required bool showGst,
    required bool showLinePricing,
  }) {
    return [
      pw.TableRow(
        repeat: true,
        decoration: const pw.BoxDecoration(color: InvoicePdfTheme.headerFill),
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          InvoicePdfWidgets.tableHeaderCell('#', align: pw.TextAlign.center),
          InvoicePdfWidgets.tableHeaderCell('Description'),
          if (showGst && showLinePricing)
            InvoicePdfWidgets.tableHeaderCell(
              'HSN/SAC',
              align: pw.TextAlign.center,
            ),
          InvoicePdfWidgets.tableHeaderCell('Qty', align: pw.TextAlign.center),
          InvoicePdfWidgets.tableHeaderCell('Unit', align: pw.TextAlign.center),
          if (showLinePricing) ...[
            InvoicePdfWidgets.tableHeaderCell(
              'Rate',
              align: pw.TextAlign.right,
            ),
            InvoicePdfWidgets.tableHeaderCell(
              'Discount',
              align: pw.TextAlign.right,
            ),
            if (showGst)
              InvoicePdfWidgets.tableHeaderCell(
                'GST %',
                align: pw.TextAlign.right,
              ),
            InvoicePdfWidgets.tableHeaderCell(
              'Amount',
              align: pw.TextAlign.right,
            ),
          ],
        ],
      ),
    ];
  }

  static List<pw.TableRow> itemsTableRows({
    required List<PrintableLineItem> lines,
    required bool showGst,
    required bool showLinePricing,
  }) {
    return [
      for (var i = 0; i < lines.length; i++)
        _itemRow(
          index: i + 1,
          item: lines[i],
          showGst: showGst,
          showLinePricing: showLinePricing,
        ),
    ];
  }

  static pw.Widget totalsSection(
    PrintableDocument document,
    CommercialDocumentLayoutConfig config,
  ) {
    if (!config.showLinePricing) {
      return pw.SizedBox();
    }
    final totals = document.totals;
    final tax = document.taxSummary;

    return pw.Container(
      margin: const pw.EdgeInsets.only(
        top: InvoicePdfTheme.totalsMarginTop,
        bottom: InvoicePdfTheme.totalsMarginBottom,
      ),
      child: pw.Row(
        children: [
          pw.Spacer(),
          pw.SizedBox(
            width: 240,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _totalRow('Subtotal', totals.subtotal),
                _totalRow('Discount', totals.discountTotal),
                if (config.showTaxSummary) ...[
                  _totalRow('CGST', tax.cgstTotal),
                  _totalRow('SGST', tax.sgstTotal),
                  _totalRow('IGST', tax.igstTotal),
                ],
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Divider(
                    color: InvoicePdfTheme.border,
                    height: 1,
                    thickness: 0.5,
                  ),
                ),
                _grandTotalRow('Grand Total', totals.totalAmount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget amountInWordsSection(PrintableDocument document) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Amount in Words',
            style: InvoicePdfTheme.infoBoxHeading(),
          ),
          pw.SizedBox(height: 2),
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
      margin: const pw.EdgeInsets.only(top: InvoicePdfTheme.spacingSm),
      child: InvoicePdfWidgets.infoBox(
        heading: 'Notes',
        body: notes.trim(),
      ),
    );
  }

  static pw.Widget footerNoteSection(String note) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: InvoicePdfTheme.spacingMd),
      child: InvoicePdfWidgets.infoBox(
        heading: 'Important',
        body: note,
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

  static pw.Widget footerSection(pw.Context context) =>
      InvoicePdfWidgets.documentFooter(context);

  /// Closing sections kept together when possible (totals through signature).
  static pw.Widget closingSection(
    PrintableDocument document,
    CommercialDocumentLayoutConfig config,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        totalsSection(document, config),
        if (config.showAmountInWords) amountInWordsSection(document),
        notesSection(document),
        if (config.footerNote != null) footerNoteSection(config.footerNote!),
        if (config.showSignature) signatureSection(document),
      ],
    );
  }

  static pw.TableRow _itemRow({
    required int index,
    required PrintableLineItem item,
    required bool showGst,
    required bool showLinePricing,
  }) {
    final line = item.line;

    return pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        InvoicePdfWidgets.tableBodyCell(
          '$index',
          align: pw.TextAlign.center,
        ),
        InvoicePdfWidgets.tableBodyCell(
          _lineDescription(item),
          maxLines: 2,
          allowWrap: true,
        ),
        if (showGst && showLinePricing)
          InvoicePdfWidgets.tableBodyCell(
            _compactCode(item.hsnCode),
            align: pw.TextAlign.center,
          ),
        InvoicePdfWidgets.tableBodyCell(
          _compactQty(line.quantity),
          align: pw.TextAlign.center,
        ),
        InvoicePdfWidgets.tableBodyCell(
          _compactUnit(line.unit),
          align: pw.TextAlign.center,
        ),
        if (showLinePricing) ...[
          InvoicePdfWidgets.tableBodyCell(
            _format(line.unitPrice),
            align: pw.TextAlign.right,
          ),
          InvoicePdfWidgets.tableBodyCell(
            _format(line.discountAmount),
            align: pw.TextAlign.right,
          ),
          if (showGst)
            InvoicePdfWidgets.tableBodyCell(
              '${line.taxRate}%',
              align: pw.TextAlign.right,
            ),
          InvoicePdfWidgets.tableBodyCell(
            _format(line.lineTotal),
            align: pw.TextAlign.right,
          ),
        ],
      ],
    );
  }

  static pw.Widget _totalRow(String label, String amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: InvoicePdfTheme.totalRow(),
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.SizedBox(width: 12),
          pw.SizedBox(
            width: 72,
            child: pw.Text(
              _format(amount),
              style: InvoicePdfTheme.totalRow(),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _grandTotalRow(String label, String amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: InvoicePdfTheme.grandTotalLabel().copyWith(
                color: PdfColors.black,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.SizedBox(width: 12),
          pw.SizedBox(
            width: 72,
            child: pw.Text(
              _format(amount),
              style: InvoicePdfTheme.grandTotalValue().copyWith(
                color: PdfColors.black,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static String _lineDescription(PrintableLineItem item) {
    final name = item.displayName.trim();
    final desc = item.description?.trim();
    if (desc == null || desc.isEmpty) return name;
    if (desc == name) return name;
    return '$name\n$desc';
  }

  static String _compactCode(String? value) {
    if (value == null || value.trim().isEmpty) return '—';
    final trimmed = value.trim();
    if (trimmed.length <= 10) return trimmed;
    return '${trimmed.substring(0, 9)}…';
  }

  static String _compactQty(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return value;
    if (parsed == parsed.roundToDouble()) {
      return parsed.toInt().toString();
    }
    return parsed.toStringAsFixed(2);
  }

  static String _compactUnit(String value) {
    final trimmed = value.trim();
    if (trimmed.length <= 6) return trimmed;
    return trimmed.substring(0, 5);
  }

  static String _format(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return value;
    return _currencyFormat.format(parsed);
  }

  // Legacy aliases used by voucher template.
  static pw.Widget companySection(PrintableDocument document) {
    final company = document.company.profile;
    final hasLogo = document.assets.logoBytes != null;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (hasLogo) ...[
          InvoicePdfWidgets.companyLogo(bytes: document.assets.logoBytes!),
          pw.SizedBox(width: InvoicePdfTheme.spacingMd),
        ],
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(company.name, style: InvoicePdfTheme.companyName()),
              ..._companyDetailLines(
                company.address,
                company.gstin,
                company.phone,
                company.email,
                company.pincode,
                company.state,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget documentHeaderSection(
    PrintableDocument document,
    CommercialDocumentLayoutConfig config,
  ) {
    return _companyAndDocumentHeader(document, config);
  }
}

/// @deprecated Use [CommercialDocumentPdfSections].
typedef InvoicePdfSections = CommercialDocumentPdfSections;
