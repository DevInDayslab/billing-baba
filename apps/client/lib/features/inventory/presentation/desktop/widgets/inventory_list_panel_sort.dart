import 'package:billing_baba/features/inventory/models/item_model.dart';

enum InventoryListPanelQtySortDirection { none, ascending, descending }

class InventoryListPanelQtySort {
  const InventoryListPanelQtySort({
    this.direction = InventoryListPanelQtySortDirection.none,
  });

  final InventoryListPanelQtySortDirection direction;

  bool get isSorted => direction != InventoryListPanelQtySortDirection.none;

  bool get isAscending =>
      direction == InventoryListPanelQtySortDirection.ascending;

  InventoryListPanelQtySort cycle() {
    final next = switch (direction) {
      InventoryListPanelQtySortDirection.none =>
        InventoryListPanelQtySortDirection.ascending,
      InventoryListPanelQtySortDirection.ascending =>
        InventoryListPanelQtySortDirection.descending,
      InventoryListPanelQtySortDirection.descending =>
        InventoryListPanelQtySortDirection.none,
    };
    return InventoryListPanelQtySort(direction: next);
  }
}

/// Client-side sort for Products/Services left list (mirrors party amount column).
List<InventoryItem> sortInventoryListPanelItems(
  List<InventoryItem> items,
  InventoryListPanelQtySort sort,
) {
  if (sort.direction == InventoryListPanelQtySortDirection.none) {
    final sorted = List<InventoryItem>.from(items)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sorted;
  }

  final ascending = sort.isAscending;
  final sorted = List<InventoryItem>.from(items)
    ..sort((a, b) {
      final comparison = (a.quantity ?? 0).compareTo(b.quantity ?? 0);
      return ascending ? comparison : -comparison;
    });
  return sorted;
}
