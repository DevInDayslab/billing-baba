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

  void moveItemsToCategory({
    required List<String> itemIds,
    required String categoryId,
    required bool removeFromExistingCategory,
  }) {
    state = [
      for (final item in state)
        if (itemIds.contains(item.id))
          _movedItem(
            item,
            categoryId: categoryId,
            removeFromExistingCategory: removeFromExistingCategory,
          )
        else
          item,
    ];
  }

  InventoryItem _movedItem(
    InventoryItem item, {
    required String categoryId,
    required bool removeFromExistingCategory,
  }) {
    final hasExistingCategory =
        item.categoryId != null &&
        item.categoryId != InventoryCatalog.uncategorizedCategoryId;

    if (!removeFromExistingCategory && hasExistingCategory) {
      return item;
    }

    return InventoryItem(
      id: item.id,
      name: item.name,
      type: item.type,
      quantity: item.quantity,
      salePrice: item.salePrice,
      stockValue: item.stockValue,
      categoryId: categoryId,
      availableForSale: item.availableForSale,
      reservedQuantity: item.reservedQuantity,
    );
  }
}
