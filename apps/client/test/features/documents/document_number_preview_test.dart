import 'package:billing_baba/features/documents/application/document_number_preview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatDocumentNumberPreview', () {
    test('joins prefix and next number', () {
      expect(
        formatDocumentNumberPreview(prefix: 'INV', nextNumber: 5),
        'INV5',
      );
    });

    test('uses number only when prefix empty', () {
      expect(
        formatDocumentNumberPreview(prefix: '  ', nextNumber: 1),
        '1',
      );
    });

    test('clamps non-positive next number', () {
      expect(
        formatDocumentNumberPreview(prefix: 'SO', nextNumber: 0),
        'SO1',
      );
    });
  });

  group('resolveDocumentNumberDisplay', () {
    test('uses preview for new documents', () {
      expect(
        resolveDocumentNumberDisplay(
          documentId: null,
          currentNumber: 'Auto',
          preview: 'INV3',
        ),
        'INV3',
      );
    });

    test('uses assigned number for existing documents', () {
      expect(
        resolveDocumentNumberDisplay(
          documentId: 'doc-1',
          currentNumber: 'LOCAL-000003',
          preview: 'INV3',
        ),
        'LOCAL-000003',
      );
    });

    test('forceAuto prefers preview even with document id', () {
      expect(
        resolveDocumentNumberDisplay(
          documentId: 'doc-1',
          currentNumber: 'Auto',
          preview: 'INV4',
          forceAuto: true,
        ),
        'INV4',
      );
    });
  });
}
