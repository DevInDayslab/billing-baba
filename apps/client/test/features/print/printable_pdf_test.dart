import 'dart:typed_data';

import 'package:billing_baba/features/print/models/printable_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PrintablePdf', () {
    test('appends .pdf extension when missing', () {
      final document = PrintablePdf(
        bytes: Uint8List.fromList([1, 2, 3]),
        name: 'barcode-labels',
      );

      expect(document.filename, 'barcode-labels.pdf');
    });

    test('keeps existing .pdf extension', () {
      final document = PrintablePdf(
        bytes: Uint8List.fromList([1, 2, 3]),
        name: 'invoice.pdf',
      );

      expect(document.filename, 'invoice.pdf');
    });
  });
}
