import 'package:billing_baba/features/inventory/providers/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_search_provider.dart';
import 'package:billing_baba/features/pos/application/pos_catalog.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/providers/pos_repository_provider.dart';
import 'package:billing_baba/features/pos/repositories/pos_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_items_provider.g.dart';

@riverpod
class PosItemSearchQuery extends _$PosItemSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

/// POS catalog derived from the shared inventory cache (single source of truth).
@riverpod
List<PosItem> posCatalog(Ref ref) {
  final inventoryItems = ref.watch(inventoryItemsProvider).value ?? const [];
  final categories = ref.watch(inventoryCategoriesProvider).value ?? const [];
  return mapInventoryItemsToPosItems(
    inventoryItems,
    categoryNamesById(categories),
  );
}

/// Inventory categories that currently have at least one POS product.
@riverpod
List<PosCategoryOption> posCategories(Ref ref) {
  final catalog = ref.watch(posCatalogProvider);
  final categories = ref.watch(inventoryCategoriesProvider).value ?? const [];
  return posCategoriesForCatalog(catalog, categories);
}

/// Filtered POS catalog using inventory search (name, barcode/SKU, HSN).
@riverpod
List<PosItem> posFilteredCatalog(
  Ref ref, {
  required String searchQuery,
  String? categoryId,
  bool inStockOnly = false,
}) {
  ref.watch(inventoryItemsProvider);
  ref.watch(inventoryCategoriesProvider);

  final catalog = ref.watch(posCatalogProvider);
  final inventoryItems = ref.watch(inventoryItemsProvider).value ?? const [];
  final searchEngine = ref.watch(inventorySearchEngineProvider);

  return filterPosCatalog(
    catalog: catalog,
    inventoryItems: inventoryItems,
    searchEngine: searchEngine,
    searchQuery: searchQuery,
    categoryId: categoryId,
    inStockOnly: inStockOnly,
  );
}

@riverpod
Future<List<PosCustomer>> posCustomerSearch(Ref ref, String query) async {
  final repository = await ref.watch(posRepositoryProvider.future);
  if (query.isEmpty) return [];
  return repository.searchCustomers(query);
}
