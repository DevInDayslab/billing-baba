import 'package:billing_baba/features/inventory/models/item_model.dart';

/// Reserved search keyword marking an item inactive in catalog / POS pickers.
const inventoryItemInactiveKeyword = '__bb_inactive__';

bool isCatalogInactiveItem(InventoryItem item) {
  return item.searchKeywords.contains(inventoryItemInactiveKeyword);
}

List<String> applyCatalogInactiveFlag(
  List<String> keywords, {
  required bool inactive,
}) {
  final cleaned = keywords
      .where((keyword) => keyword != inventoryItemInactiveKeyword)
      .toList();
  if (inactive) {
    cleaned.add(inventoryItemInactiveKeyword);
  }
  return cleaned;
}
