import 'package:billing_baba/features/inventory/models/item_model.dart';

bool isPendingLocalInventoryItemId(String id) => id.startsWith('item-local-');

String _normalizedItemName(String name) => name.trim().toLowerCase();

/// Returns true when [local] is a pending offline item representing [server].
bool inventoryItemsReconcile(InventoryItem local, InventoryItem server) {
  if (!isPendingLocalInventoryItemId(local.id)) return false;
  if (_normalizedItemName(local.name) != _normalizedItemName(server.name)) {
    return false;
  }
  if (local.type != server.type) return false;

  final localBarcode = local.barcode?.trim().toLowerCase();
  final serverBarcode = server.barcode?.trim().toLowerCase();
  if (localBarcode != null &&
      localBarcode.isNotEmpty &&
      serverBarcode != null &&
      serverBarcode.isNotEmpty) {
    return localBarcode == serverBarcode;
  }
  return true;
}

List<InventoryItem> dedupeInventoryItemsById(List<InventoryItem> items) {
  final byId = <String, InventoryItem>{};
  for (final item in items) {
    byId[item.id] = item;
  }
  return byId.values.toList();
}

List<InventoryItem> upsertInventoryItemById(
  List<InventoryItem> items,
  InventoryItem item,
) {
  final index = items.indexWhere((existing) => existing.id == item.id);
  if (index < 0) return [...items, item];
  final next = [...items];
  next[index] = item;
  return next;
}

List<InventoryItem> removeReconciledLocalInventoryItems(
  List<InventoryItem> items,
  InventoryItem serverItem,
) {
  return items
      .where((item) => !inventoryItemsReconcile(item, serverItem))
      .toList();
}

/// Merges a fetched list with unreconciled pending local items from [previous].
List<InventoryItem> mergeFetchedWithPendingLocalInventoryItems(
  List<InventoryItem> fetched,
  List<InventoryItem> previous,
) {
  final dedupedFetched = dedupeInventoryItemsById(fetched);
  final serverItems = dedupedFetched
      .where((item) => !isPendingLocalInventoryItemId(item.id))
      .toList();
  final merged = List<InventoryItem>.from(dedupedFetched);
  final mergedIds = merged.map((item) => item.id).toSet();

  for (final item in previous) {
    if (!isPendingLocalInventoryItemId(item.id)) continue;
    if (serverItems.any((server) => inventoryItemsReconcile(item, server))) {
      continue;
    }
    if (mergedIds.add(item.id)) {
      merged.add(item);
    }
  }
  return merged;
}
