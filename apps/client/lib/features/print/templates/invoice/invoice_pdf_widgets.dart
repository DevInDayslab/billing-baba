import 'dart:typed_data';

import 'package:billing_baba/features/print/templates/invoice/invoice_pdf_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Shared PDF layout primitives used by commercial and voucher templates.
abstract final class InvoicePdfWidgets {
  static pw.Widget? watermark(String status) {
    final label = switch (status) {
      'draft' => 'DRAFT',
      'cancelled' => 'CANCELLED',
      'converted' => 'CONVERTED',
      _ => null,
    };
    if (label == null) return null;

    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Center(
        child: pw.Transform.rotate(
          angle: -0.45,
          child: pw.Text(
            label,
            style: InvoicePdfTheme.title(size: 80).copyWith(
              color: InvoicePdfTheme.watermark,
            ),
          ),
        ),
      ),
    );
  }

  static pw.Widget statusBadge(String status) {
    final label = _statusLabel(status);
    final (bg, fg) = _statusColors(status);

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Text(
        label,
        style: InvoicePdfTheme.body(size: 8, color: fg).copyWith(
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget metaLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 72,
            child: pw.Text(
              label,
              style: InvoicePdfTheme.mutedBody(size: 8.5),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: InvoicePdfTheme.body(),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget partyCard({
    required String heading,
    required List<pw.Widget> lines,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(InvoicePdfTheme.spacingMd),
      decoration: InvoicePdfTheme.cardDecoration(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(heading, style: InvoicePdfTheme.heading()),
          pw.SizedBox(height: InvoicePdfTheme.spacingSm),
          ...lines,
        ],
      ),
    );
  }

  static pw.Widget partyLine(String text, {bool emphasized = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(
        text,
        style: emphasized
            ? InvoicePdfTheme.body().copyWith(
                fontWeight: pw.FontWeight.bold,
              )
            : InvoicePdfTheme.body(),
      ),
    );
  }

  static pw.Widget labeledPartyLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: InvoicePdfTheme.mutedBody(),
            ),
            pw.TextSpan(
              text: value,
              style: InvoicePdfTheme.body(),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget companyLogo({
    required Uint8List bytes,
    double size = 56,
  }) {
    return pw.Container(
      height: size,
      width: size,
      alignment: pw.Alignment.center,
      child: pw.Image(
        pw.MemoryImage(bytes),
      ),
    );
  }

  static pw.Widget infoBox({
    required String heading,
    required String body,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: InvoicePdfTheme.infoBoxDecoration(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(heading, style: InvoicePdfTheme.infoBoxHeading()),
          pw.SizedBox(height: 2),
          pw.Text(body, style: InvoicePdfTheme.body()),
        ],
      ),
    );
  }

  static pw.Widget signatureBlock({
    Uint8List? signatureBytes,
    String label = 'Authorized Signatory',
  }) {
    return pw.Container(
      width: 180,
      child: pw.Column(
        children: [
          pw.SizedBox(
            height: 56,
            width: 160,
            child: signatureBytes == null
                ? pw.SizedBox()
                : pw.Image(
                    pw.MemoryImage(signatureBytes),
                  ),
          ),
          pw.SizedBox(height: InvoicePdfTheme.spacingXs),
          pw.Container(
            width: 160,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: InvoicePdfTheme.border),
              ),
            ),
            padding: const pw.EdgeInsets.only(top: 6),
            child: pw.Text(
              label,
              style: InvoicePdfTheme.mutedBody(size: 8),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget documentFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: InvoicePdfTheme.spacingSm),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Thank you for your business.',
                  style: InvoicePdfTheme.body(size: 8),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'This is a computer-generated document.',
                  style: InvoicePdfTheme.mutedBody(size: 7.5),
                ),
              ],
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: InvoicePdfTheme.mutedBody(size: 8),
          ),
        ],
      ),
    );
  }

  static pw.Widget tableHeaderCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      child: pw.Align(
        alignment: _toAlignment(align),
        child: pw.Text(
          text,
          style: InvoicePdfTheme.tableHeader().copyWith(fontSize: 8.5),
          maxLines: 1,
          softWrap: false,
          overflow: pw.TextOverflow.clip,
        ),
      ),
    );
  }

  static pw.Widget tableBodyCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    int maxLines = 1,
    bool allowWrap = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Align(
        alignment: _toAlignment(align),
        child: pw.Text(
          text,
          style: InvoicePdfTheme.tableCell(),
          maxLines: maxLines,
          softWrap: allowWrap,
          overflow: maxLines > 1
              ? pw.TextOverflow.clip
              : pw.TextOverflow.clip,
        ),
      ),
    );
  }

  static pw.Alignment _toAlignment(pw.TextAlign align) {
    return switch (align) {
      pw.TextAlign.right => pw.Alignment.centerRight,
      pw.TextAlign.center => pw.Alignment.center,
      _ => pw.Alignment.centerLeft,
    };
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

  static (PdfColor bg, PdfColor fg) _statusColors(String status) {
    return switch (status) {
      'draft' => (
        const PdfColor.fromInt(0xFFFFF3E0),
        const PdfColor.fromInt(0xFFE65100),
      ),
      'finalized' => (
        const PdfColor.fromInt(0xFFE8F5E9),
        const PdfColor.fromInt(0xFF2E7D32),
      ),
      'cancelled' => (
        const PdfColor.fromInt(0xFFFFEBEE),
        const PdfColor.fromInt(0xFFC62828),
      ),
      'converted' => (
        const PdfColor.fromInt(0xFFE3F2FD),
        const PdfColor.fromInt(0xFF1565C0),
      ),
      'open' => (
        const PdfColor.fromInt(0xFFE8F5E9),
        const PdfColor.fromInt(0xFF2E7D32),
      ),
      'closed' => (
        const PdfColor.fromInt(0xFFF5F5F5),
        const PdfColor.fromInt(0xFF616161),
      ),
      _ => (
        const PdfColor.fromInt(0xFFF5F5F5),
        const PdfColor.fromInt(0xFF424242),
      ),
    };
  }
}
