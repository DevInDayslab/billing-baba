import 'package:billing_baba/features/purchases/application/purchase_document_parse_mapper.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PurchaseDocumentParseMapper header fields', () {
    test('leaves OCR header fields empty when not detected', () {
      final base = AddPurchaseFormState(
        eWayBillNo: 'EWB-OLD',
        billDate: DateTime(2024, 1, 15),
        billTime: const TimeOfDay(hour: 10, minute: 30),
        dueDate: DateTime(2024, 2),
        items: [PurchaseLineItem.empty(id: 'line_1')],
      );

      final result = PurchaseDocumentParseMapper.apply(
        base: base,
        parsed: const PurchaseDocumentParseDto(
          vendorName: 'Acme Supplies',
        ),
        parties: const [],
        itemNameToId: const {},
        nextLineId: () => 'line_2',
      );

      expect(result.eWayBillNo, isEmpty);
      expect(result.billDate, isNull);
      expect(result.billTime, isNull);
      expect(result.dueDate, isNull);
      expect(result.stateOfSupply, isEmpty);
      expect(result.party, 'Acme Supplies');
    });

    test('fills e-way bill only when OCR detects e_way_bill_number', () {
      final withEWay = PurchaseDocumentParseMapper.apply(
        base: AddPurchaseFormState(
          items: [PurchaseLineItem.empty(id: 'line_1')],
        ),
        parsed: const PurchaseDocumentParseDto(
          eWayBillNumber: 'EWB1234567890',
          invoiceNumber: 'INV-1001',
          supplierInvoiceNumber: 'INV-1001',
        ),
        parties: const [],
        itemNameToId: const {},
        nextLineId: () => 'line_2',
      );

      expect(withEWay.eWayBillNo, 'EWB1234567890');
      expect(withEWay.billNumber, 'INV-1001');
    });

    test('leaves e-way bill blank when only invoice number is parsed', () {
      final result = PurchaseDocumentParseMapper.apply(
        base: AddPurchaseFormState(
          items: [PurchaseLineItem.empty(id: 'line_1')],
        ),
        parsed: const PurchaseDocumentParseDto(
          invoiceNumber: 'INV-1001',
          supplierInvoiceNumber: 'INV-1001',
        ),
        parties: const [],
        itemNameToId: const {},
        nextLineId: () => 'line_2',
      );

      expect(result.eWayBillNo, isEmpty);
      expect(result.billNumber, 'INV-1001');
    });
  });

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

    test('defaults quantity to 1 when OCR omits quantity', () {
      const parsed = PurchaseDocumentParseDto(
        lines: [
          PurchaseDocumentParseLineDto(
            itemName: 'Bolt pack',
            unitPrice: 25,
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
      expect(line.itemName, 'Bolt pack');
      expect(line.qty, 1);
      expect(line.pricePerUnit, 25);
    });

    test('skips lines without a unit price', () {
      const parsed = PurchaseDocumentParseDto(
        lines: [
          PurchaseDocumentParseLineDto(
            itemName: 'Mystery item',
            quantity: 2,
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

      // No mapped lines — form keeps its base empty draft line.
      expect(result.items.single.itemName, isEmpty);
    });
  });
}
