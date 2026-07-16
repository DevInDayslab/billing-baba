import 'package:billing_baba/features/utilities/application/barcode_label_sheet_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';

void main() {
  group('BarcodeLabelSheetLayout', () {
    test('fits maximum 50x25mm labels on A4 with minimal margins', () {
      const sheet = BarcodeLabelSheetLayout(
        pageFormat: PdfPageFormat.a4,
        labelWidthMm: 50,
        labelHeightMm: 25,
      );

      expect(sheet.columns, 4);
      expect(sheet.rows, 11);
      expect(sheet.labelsPerPage, 44);
      expect(sheet.startXMm, greaterThanOrEqualTo(sheet.marginMm));
      expect(sheet.startYMm, greaterThanOrEqualTo(sheet.marginMm));
    });

    test('positions labels in a tight grid', () {
      const sheet = BarcodeLabelSheetLayout(
        pageFormat: PdfPageFormat.a4,
        labelWidthMm: 50,
        labelHeightMm: 25,
      );

      expect(sheet.labelLeftMm(0), sheet.startXMm);
      expect(sheet.labelLeftMm(1), sheet.startXMm + 51);
      expect(sheet.labelTopMm(1), sheet.startYMm + 26);
    });
  });
}
