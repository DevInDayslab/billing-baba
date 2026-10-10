import 'package:billing_baba/features/inventory/application/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/pos/application/pos_catalog.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
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
  final inventoryItems = ref.watch(inventoryItemListProvider);
  final categories = ref.watch(inventoryCategoriesProvider).value ?? const [];
  final brands = ref.watch(inventoryBrandsProvider).value ?? const [];
  return mapInventoryItemsToPosItems(
    inventoryItems,
    categoryNamesById(categories),
    brandNamesById: {for (final brand in brands) brand.id: brand.name},
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
  final inventoryItems = ref.watch(inventoryItemListProvider);
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
  final trimmed = query.trim();
  if (trimmed.isEmpty) return [];

  // Prefer parties list (includes profile images) over the stub POS repo.
  final parties = await ref.watch(partyPickerListProvider.future);
  final q = trimmed.toLowerCase();
  return parties
      .where(
        (party) => party.partyType == 'customer' || party.partyType == 'both',
      )
      .where((party) {
        final phone = party.phone.replaceAll(RegExp(r'\D'), '');
        final queryDigits = trimmed.replaceAll(RegExp(r'\D'), '');
        return party.name.toLowerCase().contains(q) ||
            (queryDigits.isNotEmpty && phone.contains(queryDigits));
      })
      .take(20)
      .map(
        (party) => PosCustomer(
          id: party.id,
          name: party.name,
          phone: party.phone.isEmpty ? null : party.phone,
          outstanding: party.balance,
          creditLimit: double.tryParse(party.creditLimit) ?? 0,
          profileImageUrl: party.profileImageUrl,
          profileMediaAssetId: party.profileMediaAssetId,
        ),
      )
      .toList();
}
