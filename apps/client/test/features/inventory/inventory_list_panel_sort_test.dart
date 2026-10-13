import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_panel_sort.dart';
import 'package:flutter_test/flutter_test.dart';

InventoryItem _item(String name, double? quantity) {
  return InventoryItem(
    id: name,
    name: name,
    quantity: quantity,
    type: ItemType.product,
  );
}

void main() {
  final items = [
    _item('Zebra', 10),
    _item('Alpha', -5),
    _item('Beta', 0),
  ];

  test('none sorts alphabetically by name', () {
    final sorted = sortInventoryListPanelItems(
      items,
      const InventoryListPanelQtySort(),
    );
    expect(sorted.map((e) => e.name).toList(), ['Alpha', 'Beta', 'Zebra']);
  });

  test('ascending sorts by quantity', () {
    final sorted = sortInventoryListPanelItems(
      items,
      const InventoryListPanelQtySort(
        direction: InventoryListPanelQtySortDirection.ascending,
      ),
    );
    expect(sorted.map((e) => e.quantity).toList(), [-5.0, 0.0, 10.0]);
  });

  test('descending sorts by quantity', () {
    final sorted = sortInventoryListPanelItems(
      items,
      const InventoryListPanelQtySort(
        direction: InventoryListPanelQtySortDirection.descending,
      ),
    );
    expect(sorted.map((e) => e.quantity).toList(), [10.0, 0.0, -5.0]);
  });
}
