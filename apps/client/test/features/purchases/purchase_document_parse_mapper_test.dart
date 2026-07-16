import 'package:billing_baba/features/purchases/application/purchase_document_parse_mapper.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PurchaseDocumentParseMapper tax', () {
    test(
      'switches exclusive billed line to With Tax and matches tax amount',
      () {
        const parsed = PurchaseDocumentParseDto(
          lines: [
            PurchaseDocumentParseLineDto(
              itemName: 'Widget',
              quantity: 2,
              unitPrice: 100,
              taxRate: 18,
              taxAmount: 36,
              taxInclusive: false,
            ),
          ],
        );

        final result = PurchaseDocumentParseMapper.apply(
          base: AddPurchaseFormState(
            items: [PurchaseLineItem.empty(id: 'line_1')],
          ),
          parsed: parsed,
          parties: const [],
          itemNameToId: const {},
          nextLineId: () => 'line_2',
        );

        final line = result.items.single;
        expect(line.priceIsTaxInclusive, isTrue);
        expect(line.taxPercent, 18);
        expect(line.pricePerUnit, closeTo(118, 0.01));
        expect(line.lineTax, closeTo(36, 0.01));
      },
    );

    test('keeps inclusive billed line on With Tax', () {
      const parsed = PurchaseDocumentParseDto(
        lines: [
          PurchaseDocumentParseLineDto(
            itemName: 'Gadget',
            quantity: 1,
            unitPrice: 118,
            taxRate: 18,
            taxAmount: 18,
            taxInclusive: true,
          ),
        ],
      );

      final result = PurchaseDocumentParseMapper.apply(
        base: AddPurchaseFormState(
          items: [PurchaseLineItem.empty(id: 'line_1')],
        ),
        parsed: parsed,
        parties: const [],
        itemNameToId: const {},
        nextLineId: () => 'line_2',
      );

      final line = result.items.single;
      expect(line.priceIsTaxInclusive, isTrue);
      expect(line.taxPercent, 18);
      expect(line.pricePerUnit, 118);
      expect(line.lineTax, closeTo(18, 0.01));
    });

    test('leaves non-tax lines on Without Tax', () {
      const parsed = PurchaseDocumentParseDto(
        lines: [
          PurchaseDocumentParseLineDto(
            itemName: 'Plain item',
            quantity: 1,
            unitPrice: 50,
          ),
        ],
      );

      final result = PurchaseDocumentParseMapper.apply(
        base: AddPurchaseFormState(
          items: [PurchaseLineItem.empty(id: 'line_1')],
        ),
        parsed: parsed,
        parties: const [],
        itemNameToId: const {},
        nextLineId: () => 'line_2',
      );

      final line = result.items.single;
      expect(line.priceIsTaxInclusive, isFalse);
      expect(line.taxPercent, 0);
      expect(line.lineTax, 0);
    });
  });
}
