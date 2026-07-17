import 'package:billing_baba/features/utilities/application/barcode_label_pdf_builder.dart';
import 'package:billing_baba/features/utilities/models/barcode_label_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds pdf bytes for selected barcode labels', () async {
    final bytes = await BarcodeLabelPdfBuilder.build(
      entries: [
        BarcodeLabelEntry(
          itemName: 'Widget',
          itemCode: '8901234567890',
          labelCount: 2,
          header: 'Store',
          line1: 'Line 1',
        ),
      ],
      layout: BarcodeLabelLayout.twoLabels50x25,
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
