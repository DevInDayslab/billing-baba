import 'package:billing_baba/features/inventory/application/barcode_scan_handler.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_engine.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

InventoryItem _item({
  required String id,
  required String name,
  String? barcode,
}) {
  return InventoryItem(
    id: id,
    name: name,
    type: ItemType.product,
    barcode: barcode,
    baseUnitShortName: 'PCS',
    salePrice: 10,
    purchasePrice: 5,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InventorySearchEngine engine;

  setUp(() {
    engine = InventorySearchEngine.build(items: const []);
  });

  test('handleBarcodeScan finds exact barcode match', () async {
    final handler = BarcodeScanHandler(debounce: Duration.zero);
    final items = [
      _item(id: '1', name: 'Milk', barcode: '8901234567890'),
      _item(id: '2', name: 'Bread', barcode: '8909999999999'),
    ];

    InventoryItem? found;
    await handleBarcodeScan(
      '8901234567890',
      handler: handler,
      engine: engine,
      items: items,
      onItemFound: (item, _) => found = item,
      onNotFound: (_) {},
    );

    expect(found?.id, '1');
  });

  test('handleBarcodeScan debounces duplicate scans', () async {
    final handler = BarcodeScanHandler(
      debounce: const Duration(milliseconds: 500),
    );
    final items = [_item(id: '1', name: 'Milk', barcode: '8901234567890')];
    var hits = 0;

    Future<void> scan() => handleBarcodeScan(
          '8901234567890',
          handler: handler,
          engine: engine,
          items: items,
          onItemFound: (_, __) => hits++,
          onNotFound: (_) {},
        );

    await scan();
    await scan();
    expect(hits, 1);
  });

  test('handleBarcodeScan reports not found', () async {
    final handler = BarcodeScanHandler(debounce: Duration.zero);
    String? missing;
    await handleBarcodeScan(
      '0000000000000',
      handler: handler,
      engine: engine,
      items: [_item(id: '1', name: 'Milk', barcode: '8901234567890')],
      onItemFound: (_, __) {},
      onNotFound: (code) => missing = code,
    );
    expect(missing, isNotEmpty);
  });

  test('BarcodeScanSuffix enterOrTab matches Enter and Tab', () {
    expect(
      BarcodeScanSuffix.enterOrTab.matches(LogicalKeyboardKey.enter),
      isTrue,
    );
    expect(
      BarcodeScanSuffix.enterOrTab.matches(LogicalKeyboardKey.tab),
      isTrue,
    );
    expect(
      BarcodeScanSuffix.enter.matches(LogicalKeyboardKey.tab),
      isFalse,
    );
  });
}
