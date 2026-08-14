import 'dart:typed_data';

import 'package:barcode/barcode.dart';
import 'package:billing_baba/features/utilities/application/barcode_label_sheet_layout.dart';
import 'package:billing_baba/features/utilities/models/barcode_label_entry.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds print-ready PDF sheets for barcode labels.
class BarcodeLabelPdfBuilder {
  const BarcodeLabelPdfBuilder._();

  static final Barcode _code128 = Barcode.code128();

  static Future<Uint8List> build({
    required List<BarcodeLabelEntry> entries,
    required BarcodeLabelLayout layout,
  }) async {
    final doc = pw.Document();
    final expanded = <BarcodeLabelEntry>[];
    for (final entry in entries) {
      for (var i = 0; i < entry.labelCount; i++) {
        expanded.add(entry);
      }
    }

    if (expanded.isEmpty) {
      doc.addPage(
        pw.Page(
          pageFormat: layout.pageFormat,
          build: (_) => pw.Center(child: pw.Text('No labels selected')),
        ),
      );
      return doc.save();
    }

    final sheet = BarcodeLabelSheetLayout(
      pageFormat: layout.pageFormat,
      labelWidthMm: layout.widthMm,
      labelHeightMm: layout.heightMm,
    );

    final labelWidth = layout.widthMm * PdfPageFormat.mm;
    final labelHeight = layout.heightMm * PdfPageFormat.mm;
    var index = 0;

    while (index < expanded.length) {
      final widgets = <pw.Widget>[];

      for (var row = 0; row < sheet.rows && index < expanded.length; row++) {
        for (
          var col = 0;
          col < sheet.columns && index < expanded.length;
          col++
        ) {
          final entry = expanded[index];
          widgets.add(
            pw.Positioned(
              left: sheet.labelLeftMm(col) * PdfPageFormat.mm,
              top: sheet.labelTopMm(row) * PdfPageFormat.mm,
              child: pw.SizedBox(
                width: labelWidth,
                height: labelHeight,
                child: _labelWidget(entry, labelWidth, labelHeight),
              ),
            ),
          );
          index++;
        }
      }

      doc.addPage(
        pw.Page(
          pageFormat: layout.pageFormat,
          margin: pw.EdgeInsets.zero,
          build: (context) => pw.Stack(children: widgets),
        ),
      );
    }

    return doc.save();
  }

  static pw.Widget _labelWidget(
    BarcodeLabelEntry entry,
    double width,
    double height,
  ) {
    final barcodeData = entry.itemCode.trim();
    final showBarcode = !entry.noBarcode && barcodeData.isNotEmpty;
    final lines = [
      if (entry.line1.trim().isNotEmpty) entry.line1.trim(),
      if (entry.line2.trim().isNotEmpty) entry.line2.trim(),
      if (entry.line3.trim().isNotEmpty) entry.line3.trim(),
      if (entry.line4.trim().isNotEmpty) entry.line4.trim(),
    ];

    return pw.Container(
      width: width,
      height: height,
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 1.5),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.3),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (entry.header.trim().isNotEmpty)
            pw.Text(
              entry.header.trim(),
              textAlign: pw.TextAlign.center,
              maxLines: 1,
              style: pw.TextStyle(
                fontSize: 6,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          if (showBarcode) ...[
            pw.SizedBox(height: 1),
            pw.BarcodeWidget(
              barcode: _code128,
              data: barcodeData,
              width: width - 6,
              height: height * 0.38,
              drawText: false,
            ),
            pw.SizedBox(height: 1),
            pw.Text(
              barcodeData,
              textAlign: pw.TextAlign.center,
              maxLines: 1,
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
          for (final line in lines)
            pw.Text(
              line,
              textAlign: pw.TextAlign.center,
              maxLines: 1,
              style: const pw.TextStyle(fontSize: 5.5),
            ),
        ],
      ),
    );
  }
}
