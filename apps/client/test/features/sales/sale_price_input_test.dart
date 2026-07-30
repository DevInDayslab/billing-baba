import 'package:billing_baba/features/sales/utils/sale_price_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SalePriceInput', () {
    test('format returns empty string for zero by default', () {
      expect(SalePriceInput.format(0), '');
    });

    test('format trims whole numbers', () {
      expect(SalePriceInput.format(100), '100');
    });

    test('format keeps decimal values', () {
      expect(SalePriceInput.format(99.5), '99.5');
    });

    test('parse handles empty and invalid input', () {
      expect(SalePriceInput.parse(''), 0);
      expect(SalePriceInput.parse('abc'), 0);
    });

    test('parse handles decimal values', () {
      expect(SalePriceInput.parse('12.5'), 12.5);
    });
  });
}
