import 'package:billing_baba/features/inventory/application/barcode_confidence.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_engine.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_units_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Precomputed search index rebuilt when inventory metadata changes.
final inventorySearchEngineProvider = Provider<InventorySearchEngine>((ref) {
  final items = ref.watch(inventoryItemsProvider).value ?? const [];
  final categories = ref.watch(inventoryCategoriesProvider).value ?? const [];
  final brands = ref.watch(inventoryBrandsProvider).value ?? const [];
  final units = ref.watch(inventoryUnitsProvider).value ?? const [];

  final categoryById = {for (final category in categories) category.id: category.name};
  final brandById = {for (final brand in brands) brand.id: brand.name};
  final unitByShortName = {
    for (final unit in units) unit.shortName.toLowerCase(): unit.fullName,
  };

  final searchableItems = items.map((item) {
    final unitShortName = item.baseUnitShortName?.toLowerCase();
    final aliases = <String>[
      if (item.shortName != null && item.shortName!.trim().isNotEmpty)
        item.shortName!.trim(),
      if (item.alias != null && item.alias!.trim().isNotEmpty) item.alias!.trim(),
      ...item.searchKeywords,
    ];
    return InventorySearchableFields.fromInventoryItem(
      item,
      categoryName: categoryById[item.categoryId],
      brandName: brandById[item.brandId],
      unitName: unitShortName == null
          ? item.baseUnitShortName
          : unitByShortName[unitShortName] ?? item.baseUnitShortName,
      aliases: aliases,
    );
  });

  return InventorySearchEngine.build(items: searchableItems);
});

List<InventoryItem> searchInventoryItems(
  InventorySearchEngine engine,
  Iterable<InventoryItem> items, {
  required String query,
}) {
  return engine.searchItems(items, query: query);
}

InventoryItem? findInventoryItemByBarcodeOrQuery(
  InventorySearchEngine engine,
  Iterable<InventoryItem> items, {
  required String query,
}) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return null;

  for (final item in items) {
    if (BarcodeConfidence.isExactBarcodeMatch(trimmed, item.barcode)) {
      return item;
    }
  }

  if (BarcodeConfidence.isBarcodeLike(trimmed)) return null;

  return engine.searchItems(items, query: trimmed).firstOrNull;
}
