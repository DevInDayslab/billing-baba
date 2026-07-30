import 'package:billing_baba/features/inventory/application/inventory_item_list_merge.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:flutter_test/flutter_test.dart';

InventoryItem _item({
  required String id,
  required String name,
  String? barcode,
  ItemType type = ItemType.product,
}) {
  return InventoryItem(
    id: id,
    name: name,
    type: type,
    barcode: barcode,
  );
}

void main() {
  group('dedupeInventoryItemsById', () {
    test('keeps the last occurrence for duplicate ids', () {
      final items = [
        _item(id: 'a', name: 'Alpha'),
        _item(id: 'a', name: 'Alpha Updated'),
      ];

      final result = dedupeInventoryItemsById(items);

      expect(result, hasLength(1));
      expect(result.single.name, 'Alpha Updated');
    });
  });

  group('upsertInventoryItemById', () {
    test('appends when id is new', () {
      final items = [_item(id: 'a', name: 'Alpha')];
      final next = upsertInventoryItemById(items, _item(id: 'b', name: 'Beta'));

      expect(next, hasLength(2));
      expect(next.last.id, 'b');
    });

    test('replaces when id already exists', () {
      final items = [_item(id: 'a', name: 'Alpha')];
      final next = upsertInventoryItemById(
        items,
        _item(id: 'a', name: 'Alpha Updated'),
      );

      expect(next, hasLength(1));
      expect(next.single.name, 'Alpha Updated');
    });
  });

  group('isServerBackedInventoryItemId', () {
    test('accepts UUID server ids', () {
      expect(
        isServerBackedInventoryItemId('b234a35a-f0b1-4fcc-915b-dbf2c46328fa'),
        isTrue,
      );
    });

    test('rejects seed catalog and pending local ids', () {
      expect(isServerBackedInventoryItemId('item-dai-001'), isFalse);
      expect(
        isServerBackedInventoryItemId('item-local-abc-123'),
        isFalse,
      );
    });
  });

  group('inventoryItemsReconcile', () {
    test('matches pending local item to server item by name and type', () {
      final local = _item(id: 'item-local-1', name: 'Widget');
      final server = _item(id: 'server-1', name: 'Widget');

      expect(inventoryItemsReconcile(local, server), isTrue);
    });

    test('matches by barcode when both sides have one', () {
      final local = _item(
        id: 'item-local-1',
        name: 'Widget',
        barcode: 'ABC',
      );
      final server = _item(
        id: 'server-1',
        name: 'Widget',
        barcode: 'XYZ',
      );

      expect(inventoryItemsReconcile(local, server), isFalse);
    });
  });

  group('mergeFetchedWithPendingLocalInventoryItems', () {
    test('drops reconciled local items when server item is present', () {
      final fetched = [_item(id: 'server-1', name: 'Widget')];
      final previous = [_item(id: 'item-local-1', name: 'Widget')];

      final merged = mergeFetchedWithPendingLocalInventoryItems(
        fetched,
        previous,
      );

      expect(merged, hasLength(1));
      expect(merged.single.id, 'server-1');
    });

    test('keeps unreconciled pending local items', () {
      final fetched = [_item(id: 'server-1', name: 'Widget')];
      final previous = [_item(id: 'item-local-1', name: 'Offline Only')];

      final merged = mergeFetchedWithPendingLocalInventoryItems(
        fetched,
        previous,
      );

      expect(merged, hasLength(2));
      expect(
        merged.map((item) => item.id),
        containsAll(['server-1', 'item-local-1']),
      );
    });
  });
}
