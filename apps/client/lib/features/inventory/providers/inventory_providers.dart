import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_catalog.dart';
import 'package:billing_baba/features/inventory/providers/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_units_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productsProvider = Provider<List<InventoryItem>>((ref) {
  final query = ref.watch(productSearchQueryProvider).toLowerCase();
  return ref.watch(inventoryItemsProvider)
      .where((item) => item.type == ItemType.product)
      .where((item) => query.isEmpty || item.name.toLowerCase().contains(query))
      .toList();
});

final servicesProvider = FutureProvider<List<InventoryItem>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 800));
  final query = ref.watch(serviceSearchQueryProvider).toLowerCase();
  return ref.watch(inventoryItemsProvider)
      .where((item) => item.type == ItemType.service)
      .where((item) => query.isEmpty || item.name.toLowerCase().contains(query))
      .toList();
});

final categoriesProvider = Provider<List<InventoryCategory>>((ref) {
  final query = ref.watch(categorySearchQueryProvider).toLowerCase();
  final items = ref.watch(inventoryItemsProvider);

  int itemCountFor(InventoryCategory category) {
    if (category.isUncategorized) {
      return items
          .where(
            (item) =>
                item.categoryId == null ||
                item.categoryId == InventoryCatalog.uncategorizedCategoryId,
          )
          .length;
    }
    return items.where((item) => item.categoryId == category.id).length;
  }

  return ref.watch(inventoryCategoriesProvider)
      .map(
        (category) => InventoryCategory(
          id: category.id,
          name: category.name,
          itemCount: itemCountFor(category),
          isUncategorized: category.isUncategorized,
        ),
      )
      .where(
        (category) =>
            query.isEmpty || category.name.toLowerCase().contains(query),
      )
      .toList();
});

final categoryItemsProvider = Provider.family<List<InventoryItem>, String>((
  ref,
  categoryId,
) {
  final query = ref.watch(categoryItemSearchQueryProvider).toLowerCase();
  return ref.watch(inventoryItemsProvider)
      .where((item) => item.categoryId == categoryId)
      .where((item) => query.isEmpty || item.name.toLowerCase().contains(query))
      .toList();
});

final unitsProvider = Provider<List<InventoryUnit>>((ref) {
  final query = ref.watch(unitSearchQueryProvider).toLowerCase();
  return ref.watch(inventoryUnitsProvider)
      .where(
        (unit) =>
            query.isEmpty ||
            unit.fullName.toLowerCase().contains(query) ||
            unit.shortName.toLowerCase().contains(query),
      )
      .toList();
});

const inventoryProductsTabIndex = 0;
const inventoryServicesTabIndex = 1;

final inventoryItemsTabIndexProvider =
    NotifierProvider<InventoryItemsTabIndex, int>(InventoryItemsTabIndex.new);

class InventoryItemsTabIndex extends Notifier<int> {
  @override
  int build() => inventoryProductsTabIndex;

  void select(int index) => state = index;

  void selectForItemType(ItemType type) {
    state = type == ItemType.product
        ? inventoryProductsTabIndex
        : inventoryServicesTabIndex;
  }
}

final selectedProductIdProvider =
    NotifierProvider<SelectedProductId, String?>(SelectedProductId.new);

final selectedServiceIdProvider =
    NotifierProvider<SelectedServiceId, String?>(SelectedServiceId.new);

final selectedCategoryIdProvider =
    NotifierProvider<SelectedCategoryId, String?>(SelectedCategoryId.new);

final selectedUnitIdProvider =
    NotifierProvider<SelectedUnitId, String?>(SelectedUnitId.new);

final productSearchQueryProvider =
    NotifierProvider<ProductSearchQuery, String>(ProductSearchQuery.new);

final serviceSearchQueryProvider =
    NotifierProvider<ServiceSearchQuery, String>(ServiceSearchQuery.new);

final categorySearchQueryProvider =
    NotifierProvider<CategorySearchQuery, String>(CategorySearchQuery.new);

final categoryItemSearchQueryProvider =
    NotifierProvider<CategoryItemSearchQuery, String>(
      CategoryItemSearchQuery.new,
    );

final unitSearchQueryProvider =
    NotifierProvider<UnitSearchQuery, String>(UnitSearchQuery.new);

final unitConversionSearchQueryProvider =
    NotifierProvider<UnitConversionSearchQuery, String>(
      UnitConversionSearchQuery.new,
    );

final productTransactionSearchQueryProvider =
    NotifierProvider<ProductTransactionSearchQuery, String>(
      ProductTransactionSearchQuery.new,
    );

final productTransactionsProvider =
    Provider.family<List<ProductTransaction>, String>((ref, itemId) {
      final query =
          ref.watch(productTransactionSearchQueryProvider).toLowerCase();
      return InventoryCatalog.productTransactions
          .where((txn) => txn.itemId == itemId)
          .where(
            (txn) =>
                query.isEmpty ||
                txn.typeLabel.toLowerCase().contains(query) ||
                txn.invoiceRefNo.toLowerCase().contains(query) ||
                txn.partyName.toLowerCase().contains(query) ||
                txn.status.toLowerCase().contains(query),
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });

class SelectedProductId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

class SelectedServiceId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

class SelectedCategoryId extends Notifier<String?> {
  @override
  String? build() => InventoryCatalog.uncategorizedCategoryId;

  void select(String? id) => state = id;
}

class SelectedUnitId extends Notifier<String?> {
  @override
  String? build() {
    final units = ref.watch(inventoryUnitsProvider);
    return units.isEmpty ? null : units.first.id;
  }

  void select(String? id) => state = id;
}

class ProductSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class ServiceSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class CategorySearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class CategoryItemSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class UnitSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class UnitConversionSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class ProductTransactionSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}
