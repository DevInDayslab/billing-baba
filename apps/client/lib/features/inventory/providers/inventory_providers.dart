import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/dto/stock_level_dto.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/models/item_location_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/price_history_model.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/models/tier_price_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_units_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productsProvider = Provider<List<InventoryItem>>((ref) {
  final query = ref.watch(productSearchQueryProvider).toLowerCase();
  return (ref.watch(inventoryItemsProvider).value ?? [])
      .where((item) => item.type == ItemType.product)
      .where((item) => query.isEmpty || item.name.toLowerCase().contains(query))
      .toList();
});

final servicesProvider = Provider<List<InventoryItem>>((ref) {
  final query = ref.watch(serviceSearchQueryProvider).toLowerCase();
  return (ref.watch(inventoryItemsProvider).value ?? [])
      .where((item) => item.type == ItemType.service)
      .where((item) => query.isEmpty || item.name.toLowerCase().contains(query))
      .toList();
});

final categoriesProvider = Provider<List<InventoryCategory>>((ref) {
  final query = ref.watch(categorySearchQueryProvider).toLowerCase();
  final categories = ref.watch(inventoryCategoriesProvider).value ?? [];
  final items = ref.watch(inventoryItemsProvider).value ?? [];
  final serviceAsync = ref.watch(inventoryServiceProvider);

  final withUncategorized = serviceAsync.maybeWhen(
    data: (service) => service.withUncategorizedCategory(
      categories: categories,
      items: items,
    ),
    orElse: () => categories,
  );

  return withUncategorized
      .where(
        (category) =>
            query.isEmpty || category.name.toLowerCase().contains(query),
      )
      .toList();
});

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final categoryItemsProvider = Provider.family<List<InventoryItem>, String>((
  ref,
  categoryId,
) {
  final query = ref.watch(categoryItemSearchQueryProvider).toLowerCase();
  final items = ref.watch(inventoryItemsProvider).value ?? [];

  final filteredItems = categoryId == uncategorizedCategoryId
      ? items.where(
          (item) =>
              item.categoryId == null ||
              item.categoryId == uncategorizedCategoryId,
        )
      : items.where((item) => item.categoryId == categoryId);

  return filteredItems
      .where((item) => query.isEmpty || item.name.toLowerCase().contains(query))
      .toList();
});

final unitsProvider = Provider<List<InventoryUnit>>((ref) {
  final query = ref.watch(unitSearchQueryProvider).toLowerCase();
  return (ref.watch(inventoryUnitsProvider).value ?? [])
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

  int get tabIndex => state;
  set tabIndex(int index) => state = index;

  void selectForItemType(ItemType type) {
    state = type == ItemType.product
        ? inventoryProductsTabIndex
        : inventoryServicesTabIndex;
  }
}

final selectedProductIdProvider = NotifierProvider<SelectedProductId, String?>(
  SelectedProductId.new,
);

final selectedServiceIdProvider = NotifierProvider<SelectedServiceId, String?>(
  SelectedServiceId.new,
);

final selectedCategoryIdProvider =
    NotifierProvider<SelectedCategoryId, String?>(SelectedCategoryId.new);

final selectedUnitIdProvider = NotifierProvider<SelectedUnitId, String?>(
  SelectedUnitId.new,
);

final productSearchQueryProvider = NotifierProvider<ProductSearchQuery, String>(
  ProductSearchQuery.new,
);

final serviceSearchQueryProvider = NotifierProvider<ServiceSearchQuery, String>(
  ServiceSearchQuery.new,
);

final categorySearchQueryProvider =
    NotifierProvider<CategorySearchQuery, String>(CategorySearchQuery.new);

final categoryItemSearchQueryProvider =
    NotifierProvider<CategoryItemSearchQuery, String>(
      CategoryItemSearchQuery.new,
    );

final unitSearchQueryProvider = NotifierProvider<UnitSearchQuery, String>(
  UnitSearchQuery.new,
);

final unitConversionSearchQueryProvider =
    NotifierProvider<UnitConversionSearchQuery, String>(
      UnitConversionSearchQuery.new,
    );

final productTransactionSearchQueryProvider =
    NotifierProvider<ProductTransactionSearchQuery, String>(
      ProductTransactionSearchQuery.new,
    );

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final productTransactionsProvider =
    FutureProvider.family<List<ProductTransaction>, String>((
      ref,
      itemId,
    ) async {
      final query = ref
          .watch(productTransactionSearchQueryProvider)
          .toLowerCase();
      final service = await ref.watch(inventoryServiceProvider.future);
      final transactions = await service.fetchProductTransactions(itemId);
      return transactions
          .where(
            (txn) =>
                query.isEmpty ||
                txn.typeLabel.toLowerCase().contains(query) ||
                txn.invoiceRefNo.toLowerCase().contains(query) ||
                txn.partyName.toLowerCase().contains(query) ||
                txn.status.toLowerCase().contains(query),
          )
          .toList();
    });

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final productDetailProvider = FutureProvider.family<InventoryItem, String>((
  ref,
  itemId,
) async {
  final service = await ref.watch(inventoryServiceProvider.future);
  return service.getItem(itemId);
});

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final itemStockLevelsProvider =
    FutureProvider.family<List<StockLevelDto>, String>((ref, itemId) async {
      final service = await ref.watch(inventoryServiceProvider.future);
      return service.fetchItemStockLevels(itemId);
    });

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final itemTierPricesProvider =
    FutureProvider.family<List<TierPriceModel>, String>((ref, itemId) async {
      final service = await ref.watch(inventoryServiceProvider.future);
      return service.fetchItemTierPrices(itemId);
    });

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final itemImagesProvider =
    FutureProvider.family<List<ItemImageModel>, String>((ref, itemId) async {
      final service = await ref.watch(inventoryServiceProvider.future);
      return service.fetchItemImages(itemId);
    });

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final itemLocationsProvider =
    FutureProvider.family<List<ItemLocationModel>, String>((ref, itemId) async {
      final service = await ref.watch(inventoryServiceProvider.future);
      return service.fetchItemLocations(itemId);
    });

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final priceHistoryProvider =
    FutureProvider.family<List<PriceHistoryModel>, String>((ref, itemId) async {
      final service = await ref.watch(inventoryServiceProvider.future);
      return service.fetchItemPriceHistory(itemId);
    });

class SelectedProductId extends Notifier<String?> {
  @override
  String? build() => null;

  String? get selected => state;
  set selected(String? id) => state = id;
}

class SelectedServiceId extends Notifier<String?> {
  @override
  String? build() => null;

  String? get selected => state;
  set selected(String? id) => state = id;
}

class SelectedCategoryId extends Notifier<String?> {
  @override
  String? build() => uncategorizedCategoryId;

  String? get selected => state;
  set selected(String? id) => state = id;
}

class SelectedUnitId extends Notifier<String?> {
  @override
  String? build() {
    final units = ref.watch(inventoryUnitsProvider).value ?? [];
    return units.isEmpty ? null : units.first.id;
  }

  String? get selected => state;
  set selected(String? id) => state = id;
}

class ProductSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

class ServiceSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

class CategorySearchQuery extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

class CategoryItemSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

class UnitSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

class UnitConversionSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

class ProductTransactionSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}
