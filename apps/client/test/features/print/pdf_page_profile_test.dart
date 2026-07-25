import 'dart:typed_data';

import 'package:billing_baba/features/print/models/pdf_page_profile.dart';
import 'package:billing_baba/features/print/models/printable_pdf.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';

void main() {
  group('PdfPageProfile', () {
    test('barcode profile uses full-width preview and zero margins', () {
      expect(PdfPageProfile.barcode.kind, PdfProfileKind.barcode);
      expect(PdfPageProfile.barcode.pageFormat, PdfPageFormat.a4);
      expect(PdfPageProfile.barcode.pageMargins.left, 0);
      expect(PdfPageProfile.barcode.previewMaxPageWidth, double.infinity);
      expect(PdfPageProfile.barcode.previewDynamicLayout, isFalse);
    });

    test('transaction profile uses constrained preview and A4', () {
      expect(PdfPageProfile.transaction.kind, PdfProfileKind.transaction);
      expect(PdfPageProfile.transaction.pageFormat, PdfPageFormat.a4);
      expect(PdfPageProfile.transaction.previewMaxPageWidth, 700);
      expect(PdfPageProfile.transaction.previewDynamicLayout, isTrue);
    });

    test('forPrintSettings returns landscape A4 for landscape orientation', () {
      final settings = const PrintSettings.defaults().copyWith(
        printerType: PrinterType.regular,
        orientation: RegularOrientation.landscape,
      );
      final profile = PdfPageProfile.forPrintSettings(settings);
      expect(profile.pageFormat.width, greaterThan(profile.pageFormat.height));
    });
  });

  group('PrintablePdf', () {
    test('defaults to transaction profile', () {
      final document = PrintablePdf(
        bytes: Uint8List.fromList([1]),
        name: 'invoice',
      );
      expect(document.profile, PdfPageProfile.transaction);
    });
  });
}
