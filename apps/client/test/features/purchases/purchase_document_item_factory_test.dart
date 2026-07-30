import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/purchases/application/purchase_document_item_factory.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PurchaseDocumentItemFactory', () {
    test('matches existing inventory names case-insensitively', () {
      const items = [
        InventoryItem(
          id: 'item-1',
          name: 'Widget Pro',
          type: ItemType.product,
          salePrice: 100,
          purchasePrice: 80,
          quantity: 5,
          stockValue: 400,
        ),
      ];

      final map = PurchaseDocumentItemFactory.buildNameToIdMap(items);

      expect(
        PurchaseDocumentItemFactory.resolveExistingItemId(
          itemName: '  widget pro ',
          nameToId: map,
        ),
        'item-1',
      );
    });

    test('deduplicates missing names within one import batch', () {
      final lines = [
        const PurchaseLineItem(
          id: 'line-1',
          itemName: 'New Gadget',
          qty: 2,
          pricePerUnit: 50,
        ),
        const PurchaseLineItem(
          id: 'line-2',
          itemName: 'new gadget',
          qty: 1,
          pricePerUnit: 50,
        ),
        const PurchaseLineItem(
          id: 'line-3',
          itemName: 'Existing Item',
          itemId: 'item-existing',
          qty: 1,
          pricePerUnit: 10,
        ),
      ];

      final needing = PurchaseDocumentItemFactory.linesNeedingCreation(
        lines,
        const {},
      );

      expect(needing, hasLength(1));
      expect(needing.single.itemName, 'New Gadget');
    });

    test('builds inventory form from parsed line tax and unit data', () {
      const units = [
        InventoryUnit(
          id: 'unit-pcs',
          shortName: 'Pcs',
          fullName: 'Pieces',
        ),
      ];

      const line = PurchaseLineItem(
        id: 'line-1',
        itemName: 'Gadget',
        description: 'Imported gadget',
        qty: 2,
        unit: 'PCS',
        pricePerUnit: 118,
        priceIsTaxInclusive: true,
        taxPercent: 18,
      );

      final form = PurchaseDocumentItemFactory.toAddItemFormState(
        line: line,
        units: units,
      );

      expect(form, isNotNull);
      expect(form!.itemName, 'Gadget');
      expect(form.description, 'Imported gadget');
      expect(form.baseUnitId, 'unit-pcs');
      expect(form.atPrice, 118);
      expect(form.openingQty, 0);
      expect(form.purchasePriceTaxMode, PriceTaxMode.withTax);
      expect(form.taxRate, 'GST @ 18%');
    });

    test('assigns created ids to all matching lines', () {
      final lines = [
        const PurchaseLineItem(
          id: 'line-1',
          itemName: 'Gadget',
          qty: 2,
          pricePerUnit: 50,
        ),
        const PurchaseLineItem(
          id: 'line-2',
          itemName: 'GADGET',
          qty: 1,
          pricePerUnit: 50,
        ),
      ];

      final linked = PurchaseDocumentItemFactory.assignItemIds(
        lines,
        const {'gadget': 'item-new'},
      );

      expect(linked[0].itemId, 'item-new');
      expect(linked[1].itemId, 'item-new');
    });
  });
}
