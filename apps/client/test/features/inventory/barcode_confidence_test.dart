import 'package:billing_baba/features/inventory/application/barcode_confidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarcodeConfidence', () {
    test('normalize strips non-digit characters', () {
      expect(BarcodeConfidence.normalize('890-1234 567890'), '8901234567890');
    });

    test('isBarcodeLike requires 8+ digits', () {
      expect(BarcodeConfidence.isBarcodeLike('1234567'), isFalse);
      expect(BarcodeConfidence.isBarcodeLike('12345678'), isTrue);
      expect(BarcodeConfidence.isBarcodeLike('8901234567890'), isTrue);
      expect(BarcodeConfidence.isBarcodeLike('Maggi'), isFalse);
    });

    test('hasValidGtinChecksum validates known GTINs', () {
      expect(BarcodeConfidence.hasValidGtinChecksum('4006381333931'), isTrue);
      expect(BarcodeConfidence.hasValidGtinChecksum('1234567890123'), isFalse);
      expect(BarcodeConfidence.hasValidGtinChecksum('12345'), isFalse);
    });

    test('isEligibleForExternalLookup requires valid GTIN length and checksum', () {
      expect(BarcodeConfidence.isEligibleForExternalLookup('4006381333931'), isTrue);
      expect(BarcodeConfidence.isEligibleForExternalLookup('99999999'), isFalse);
      expect(BarcodeConfidence.isEligibleForExternalLookup('123'), isFalse);
    });

    test('isExactBarcodeMatch compares normalized values', () {
      expect(
        BarcodeConfidence.isExactBarcodeMatch(
          '890-1234-567890',
          '8901234567890',
        ),
        isTrue,
      );
      expect(
        BarcodeConfidence.isExactBarcodeMatch('1234567890123', '8901234567890'),
        isFalse,
      );
    });
  });
}
