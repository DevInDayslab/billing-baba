import 'package:billing_baba/features/inventory/application/inventory_search_engine.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/pos/application/pos_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps inventory primary image URL to POS item', () {
    final posItem = mapInventoryItemToPosItem(
      const InventoryItem(
        id: 'item-1',
        name: 'Widget',
        type: ItemType.product,
        salePrice: 99,
        mrp: 120,
        primaryImageUrl: 'https://cdn.example.com/widget.png',
        quantity: 12,
        barcode: 'SKU-1',
        categoryId: 'grocery',
      ),
      categoryName: 'Grocery',
    );

    expect(posItem.imageUrl, 'https://cdn.example.com/widget.png');
    expect(posItem.stock, 12);
    expect(posItem.sku, 'SKU-1');
    expect(posItem.categoryId, 'grocery');
    expect(posItem.categoryName, 'Grocery');
    expect(posItem.mrp, 120);
    expect(posItem.isOutOfStock, isFalse);
  });

  test('filters POS catalog by inventory search query', () {
    const items = [
      InventoryItem(
        id: '1',
        name: 'Fortune Oil 1L',
        type: ItemType.product,
        barcode: '8901030865335',
        salePrice: 165,
      ),
      InventoryItem(
        id: '2',
        name: 'AA Battery 4-pack',
        type: ItemType.product,
        barcode: 'BAT-001',
        salePrice: 130,
      ),
    ];

    final catalog = mapInventoryItemsToPosItems(items, const {});
    final engine = InventorySearchEngine.build(
      items: items.map(InventorySearchableFields.fromInventoryItem),
    );

    final barcodeResults = filterPosCatalog(
      catalog: catalog,
      inventoryItems: items,
      searchEngine: engine,
      searchQuery: '8901030865335',
    );
    expect(barcodeResults, hasLength(1));
    expect(barcodeResults.first.name, 'Fortune Oil 1L');

    final nameResults = filterPosCatalog(
      catalog: catalog,
      inventoryItems: items,
      searchEngine: engine,
      searchQuery: 'battery',
    );
    expect(nameResults, hasLength(1));
    expect(nameResults.first.name, 'AA Battery 4-pack');
  });

  test('returns all products matching a partial name query', () {
    const items = [
      InventoryItem(
        id: '1',
        name: 'Test 1',
        type: ItemType.product,
        salePrice: 120,
      ),
      InventoryItem(
        id: '2',
        name: 'Test 2',
        type: ItemType.product,
        salePrice: 52,
      ),
      InventoryItem(
        id: '3',
        name: 'Test 3',
        type: ItemType.product,
        salePrice: 0,
      ),
      InventoryItem(
        id: '4',
        name: 'Widget',
        type: ItemType.product,
        salePrice: 10,
      ),
    ];

    final catalog = mapInventoryItemsToPosItems(items, const {});
    final engine = InventorySearchEngine.build(
      items: items.map(InventorySearchableFields.fromInventoryItem),
    );

    final results = filterPosCatalog(
      catalog: catalog,
      inventoryItems: items,
      searchEngine: engine,
      searchQuery: 't',
    );

    expect(
      results.map((item) => item.name),
      containsAll(['Test 1', 'Test 2', 'Test 3']),
    );
    expect(results, hasLength(4));
  });

  test('multi-word search matches only the named product', () {
    const items = [
      InventoryItem(
        id: '1',
        name: 'Test 1',
        type: ItemType.product,
        barcode: '1790938395123',
        salePrice: 120,
      ),
      InventoryItem(
        id: '2',
        name: 'Test 2',
        type: ItemType.product,
        barcode: '1790938433123',
        salePrice: 52,
      ),
    ];

    final catalog = mapInventoryItemsToPosItems(items, const {});
    final engine = InventorySearchEngine.build(
      items: items.map(InventorySearchableFields.fromInventoryItem),
    );

    final results = filterPosCatalog(
      catalog: catalog,
      inventoryItems: items,
      searchEngine: engine,
      searchQuery: 'test 1',
    );

    expect(results, hasLength(1));
    expect(results.first.name, 'Test 1');
  });
}
