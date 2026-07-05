import 'dart:typed_data';

import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';
import 'package:billing_baba/features/print/templates/print_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Minimal placeholder template until the production A4 invoice layout ships.
class PlaceholderPrintTemplate implements PrintTemplate {
  @override
  String get id => 'placeholder_v1';

  @override
  bool supports(PrintableDocumentKind kind) =>
      kind == PrintableDocumentKind.paymentIn ||
      kind == PrintableDocumentKind.paymentOut;

  @override
  Future<Uint8List> render(PrintableDocument document) async {
    final pdf = pw.Document()
      ..addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  document.kind.label,
                  style: const pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text('Number: ${document.metadata.displayNumber}'),
                pw.Text('Date: ${document.metadata.documentDate}'),
                pw.Text('Status: ${document.metadata.status}'),
                if (document.party != null)
                  pw.Text('Party: ${document.party!.dto.name}'),
                pw.SizedBox(height: 12),
                pw.Text('Total: ${document.totals.totalAmount}'),
                pw.Spacer(),
                pw.Text(
                  'Placeholder template — replace with A4 GST invoice layout.',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            );
          },
        ),
      );
    return pdf.save();
  }
}
