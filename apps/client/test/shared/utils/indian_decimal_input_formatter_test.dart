import 'package:billing_baba/shared/constants/item_price_limits.dart';
import 'package:billing_baba/shared/utils/text_input_formatters.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndianDecimalInputFormatter', () {
    test('formatCleanedDecimal uses Indian grouping', () {
      expect(
        IndianDecimalInputFormatter.formatCleanedDecimal('13213123121'),
        '13,21,31,23,121',
      );
      expect(
        IndianDecimalInputFormatter.formatCleanedDecimal('100000'),
        '1,00,000',
      );
    });

    test('parseIndianDecimalInput strips commas', () {
      expect(parseIndianDecimalInput('13,21,31,23,121'), 13213123121);
      expect(parseIndianDecimalInput('1,00,000.50'), 100000.5);
    });

    test('formatIndianDecimalInput round-trips common values', () {
      expect(formatIndianDecimalInput(45645646546), '45,64,56,46,546');
      expect(formatIndianDecimalInput(1234.5), '1,234.5');
    });

    test('item price formatter caps at 99,99,99,999', () {
      expect(
        IndianDecimalInputFormatter.formatCleanedDecimal('999999999'),
        ItemPriceLimits.maxAmountIndianLabel,
      );
      const formatter = indianItemPriceInputFormatter;
      final overMax = formatter.formatEditUpdate(
        const TextEditingValue(text: '99,99,99,999'),
        const TextEditingValue(text: '99,99,99,9999'),
      );
      expect(overMax.text, '99,99,99,999');
      expect(parseIndianItemPriceInput('99,99,99,999'), 999999999);
      expect(
        parseIndianItemPriceInput('1,00,00,00,000'),
        ItemPriceLimits.maxWholeRupees,
      );
    });
  });
}
