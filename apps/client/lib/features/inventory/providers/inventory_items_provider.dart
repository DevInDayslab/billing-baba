import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryItemsProvider =
    NotifierProvider<InventoryItems, List<InventoryItem>>(InventoryItems.new);

class InventoryItems extends Notifier<List<InventoryItem>> {
  @override
  List<InventoryItem> build() => List.of(InventoryCatalog.items);

  void addItem(InventoryItem item) {
    state = [...state, item];
  }
}
