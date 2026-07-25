import 'package:billing_baba/features/inventory/application/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_item_filter_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/application/inventory_transaction_table_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/category_item_sort.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/dto/stock_level_dto.dart';
import 'package:billing_baba/features/inventory/models/inventory_item_filters.dart';
import 'package:billing_baba/features/inventory/models/inventory_transaction_filters.dart';
import 'package:billing_baba/features/inventory/models/item_location_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/price_history_model.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/models/tier_price_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'item_images_provider.dart';

final productsProvider = Provider<List<InventoryItem>>((ref) {
  final query = ref.watch(productSearchQueryProvider);
  final filters = ref.watch(inventoryItemFiltersProvider);
  final engine = ref.watch(inventorySearchEngineProvider);
  final products = (ref.watch(inventoryItemsProvider).value ?? [])
      .where((item) => item.type == ItemType.product);

  return searchInventoryItems(engine, products, query: query)
      .where(
        (item) => InventoryItemFilterService.matches(item, filters: filters),
      )
      .toList();
});

final servicesProvider = Provider<List<InventoryItem>>((ref) {
  final query = ref.watch(serviceSearchQueryProvider);
  final filters = ref.watch(inventoryItemFiltersProvider);
  final engine = ref.watch(inventorySearchEngineProvider);
  final services = (ref.watch(inventoryItemsProvider).value ?? [])
      .where((item) => item.type == ItemType.service);

  return searchInventoryItems(engine, services, query: query)
      .where(
        (item) => InventoryItemFilterService.matches(item, filters: filters),
      )
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
  final query = ref.watch(categoryItemSearchQueryProvider);
  final filters = ref.watch(categoryItemFiltersProvider);
  final sort = ref.watch(categoryItemSortProvider);
  final items = ref.watch(inventoryItemsProvider).value ?? [];

  final filteredItems = categoryId == uncategorizedCategoryId
      ? items.where(
          (item) =>
              item.categoryId == null ||
              item.categoryId == uncategorizedCategoryId,
        )
      : items.where((item) => item.categoryId == categoryId);

  final engine = ref.watch(inventorySearchEngineProvider);
  final result = searchInventoryItems(engine, filteredItems, query: query)
      .where(
        (item) => InventoryItemFilterService.matches(item, filters: filters),
      )
      .toList();

  if (sort.direction == CategoryItemSortDirection.none) {
    return result;
  }

  final ascending = sort.direction == CategoryItemSortDirection.ascending;
  result.sort((a, b) {
    final comparison = switch (sort.column) {
      CategoryItemSortColumn.name => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
      CategoryItemSortColumn.quantity => (a.quantity ?? 0).compareTo(
        b.quantity ?? 0,
      ),
      CategoryItemSortColumn.stockValue => (a.stockValue ?? 0).compareTo(
        b.stockValue ?? 0,
      ),
    };
    return ascending ? comparison : -comparison;
  });

  return result;
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

final categoryItemFiltersProvider =
    NotifierProvider<CategoryItemFilters, InventoryItemFiltersState>(
      CategoryItemFilters.new,
    );

final categoryItemSortProvider =
    NotifierProvider<CategoryItemSort, CategoryItemSortState>(
      CategoryItemSort.new,
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

const inventoryTransactionPageSize = 35;

final productTransactionFiltersProvider =
    NotifierProvider<
      ProductTransactionFilters,
      InventoryTransactionFiltersState
    >(
      ProductTransactionFilters.new,
    );

final selectedProductTransactionIdProvider =
    NotifierProvider<SelectedProductTransactionId, String?>(
      SelectedProductTransactionId.new,
    );

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final filteredProductTransactionsProvider =
    Provider.family<List<ProductTransaction>, String>((ref, itemId) {
      final transactions =
          ref.watch(productTransactionsProvider(itemId)).value ?? [];
      final filters = ref.watch(productTransactionFiltersProvider);
      return InventoryTransactionTableService.applyFiltersAndSort(
        transactions: transactions,
        filters: filters,
      );
    });

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final productTransactionTypeOptionsProvider =
    Provider.family<List<String>, String>((ref, itemId) {
      final transactions =
          ref.watch(productTransactionsProvider(itemId)).value ?? [];
      return InventoryTransactionTableService.uniqueTypeOptions(transactions);
    });

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final productTransactionStatusOptionsProvider =
    Provider.family<List<String>, String>((ref, itemId) {
      final transactions =
          ref.watch(productTransactionsProvider(itemId)).value ?? [];
      return InventoryTransactionTableService.uniqueStatusOptions(transactions);
    });

final inventoryItemFiltersProvider =
    NotifierProvider<InventoryItemFilters, InventoryItemFiltersState>(
      InventoryItemFilters.new,
    );

class PaginatedProductTransactions {
  const PaginatedProductTransactions({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<ProductTransaction> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final paginatedProductTransactionsProvider =
    Provider.family<PaginatedProductTransactions, String>((ref, itemId) {
      final transactions = ref.watch(
        filteredProductTransactionsProvider(itemId),
      );
      final page = ref.watch(productTransactionFiltersProvider).currentPage;
      final totalPages = transactions.isEmpty
          ? 1
          : (transactions.length / inventoryTransactionPageSize).ceil();
      final safePage = page.clamp(0, totalPages - 1);
      final start = safePage * inventoryTransactionPageSize;
      final end = (start + inventoryTransactionPageSize).clamp(
        0,
        transactions.length,
      );

      return PaginatedProductTransactions(
        items: transactions.sublist(start, end),
        currentPage: safePage,
        totalPages: totalPages,
        totalItems: transactions.length,
      );
    });

class ProductStockSummary {
  const ProductStockSummary({
    this.availableStock,
    this.reservedStock,
    this.stockValue,
    this.averagePurchasePrice,
    this.lastPurchasePrice,
    this.reorderLevel,
    this.isLowStock,
  });

  final double? availableStock;
  final double? reservedStock;
  final double? stockValue;
  final double? averagePurchasePrice;
  final double? lastPurchasePrice;
  final double? reorderLevel;
  final bool? isLowStock;
}

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final itemStockMetricsProvider =
    Provider.family<ItemStockMetrics, String>((ref, itemId) {
      final item = (ref.watch(inventoryItemsProvider).value ?? [])
          .where((entry) => entry.id == itemId)
          .firstOrNull;
      return InventoryStockCalculator.metricsFromItem(item);
    });

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final productStockSummaryProvider =
    Provider.family<ProductStockSummary, String>((ref, itemId) {
      final item = (ref.watch(inventoryItemsProvider).value ?? [])
          .where((entry) => entry.id == itemId)
          .firstOrNull;
      final metrics = ref.watch(itemStockMetricsProvider(itemId));
      final stockLevels =
          ref.watch(itemStockLevelsProvider(itemId)).value ?? [];
      final transactions =
          ref.watch(productTransactionsProvider(itemId)).value ?? [];

      double? averageCost;
      var hasLowStock = false;
      for (final level in stockLevels) {
        final cost = parseDecimal(level.averageCost);
        if (cost != null) {
          averageCost = cost;
        }
        if (level.isLowStock) {
          hasLowStock = true;
        }
      }

      final lastPurchase =
          InventoryStockCalculator.lastPurchasePrice(transactions) ??
          item?.purchasePrice;

      final available = metrics.availableForSale;
      final reserved = metrics.reservedQuantity;
      final stockValue =
          item?.stockValue ??
          stockLevels.fold<double>(
            0,
            (sum, level) =>
                sum +
                ((parseDecimal(level.quantity) ?? 0) *
                    (parseDecimal(level.averageCost) ?? 0)),
          );

      final reorder =
          item?.reorderLevel ??
          parseDecimal(stockLevels.firstOrNull?.reorderLevel);

      final isLowStock =
          hasLowStock ||
          (metrics.physicalQuantity > 0 &&
              reorder != null &&
              metrics.availableForSale > 0 &&
              metrics.availableForSale <= reorder);

      return ProductStockSummary(
        availableStock: available,
        reservedStock: reserved,
        stockValue: stockValue > 0 ? stockValue : item?.stockValue,
        averagePurchasePrice: averageCost,
        lastPurchasePrice: lastPurchase,
        reorderLevel: reorder,
        isLowStock: stockLevels.isNotEmpty || reorder != null
            ? isLowStock
            : null,
      );
    });

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final productStockAfterProvider = Provider.family<Map<String, double>, String>((
  ref,
  itemId,
) {
  final transactions =
      ref.watch(productTransactionsProvider(itemId)).value ?? [];
  return InventoryStockCalculator.stockAfterByTransactionId(transactions);
});

class LatestStockUpdate {
  const LatestStockUpdate({
    required this.updatedAt,
    required this.changeDescription,
    this.updatedByName,
  });

  final DateTime updatedAt;
  final String? updatedByName;
  final String changeDescription;
}

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final latestStockUpdateProvider = Provider.family<LatestStockUpdate?, String>((
  ref,
  itemId,
) {
  final transactions =
      ref.watch(productTransactionsProvider(itemId)).value ?? [];
  if (transactions.isEmpty) return null;

  final latest = transactions.first;
  final prefix = latest.isInbound ? '+' : '-';
  final unit = latest.unit?.trim();
  final unitSuffix = unit == null || unit.isEmpty ? '' : ' $unit';
  final changeDescription =
      '${latest.typeLabel}: $prefix${formatQuantityValue(latest.quantity)}$unitSuffix';

  return LatestStockUpdate(
    updatedAt: latest.date,
    updatedByName: latest.createdByName,
    changeDescription: changeDescription,
  );
});

// Provider.family's family type is not publicly exported by Riverpod.
// ignore: specify_nonobvious_property_types
final productDetailContextProvider =
    Provider.family<
      ({InventoryItem? item, String? categoryName, String? brandName}),
      String
    >((
      ref,
      itemId,
    ) {
      final item = (ref.watch(inventoryItemsProvider).value ?? [])
          .where((entry) => entry.id == itemId)
          .firstOrNull;
      final categories = ref.watch(categoriesProvider);
      final brands = ref.watch(inventoryBrandsProvider).value ?? [];

      final categoryName = categories
          .where((category) => category.id == item?.categoryId)
          .map((category) => category.name)
          .firstOrNull;
      final brandName = brands
          .where((brand) => brand.id == item?.brandId)
          .map((brand) => brand.name)
          .firstOrNull;

      return (item: item, categoryName: categoryName, brandName: brandName);
    });

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
                txn.documentLabel.toLowerCase().contains(query) ||
                txn.transactionType.toLowerCase().contains(query) ||
                txn.referenceNo.toLowerCase().contains(query) ||
                txn.partyName.toLowerCase().contains(query) ||
                (txn.godownName?.toLowerCase().contains(query) ?? false) ||
                (txn.createdByName?.toLowerCase().contains(query) ?? false) ||
                (txn.notes?.toLowerCase().contains(query) ?? false) ||
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

// Item gallery: see [itemImagesProvider] in item_images_provider.dart.

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

class CategoryItemFilters extends Notifier<InventoryItemFiltersState> {
  @override
  InventoryItemFiltersState build() => const InventoryItemFiltersState();

  void apply(InventoryItemFiltersState filters) => state = filters;

  void clear() => state = const InventoryItemFiltersState();
}

class CategoryItemSort extends Notifier<CategoryItemSortState> {
  @override
  CategoryItemSortState build() => const CategoryItemSortState();

  void toggle(CategoryItemSortColumn column) {
    if (state.column == column) {
      final nextDirection = switch (state.direction) {
        CategoryItemSortDirection.none => CategoryItemSortDirection.ascending,
        CategoryItemSortDirection.ascending =>
          CategoryItemSortDirection.descending,
        CategoryItemSortDirection.descending => CategoryItemSortDirection.none,
      };
      state = state.copyWith(direction: nextDirection);
      return;
    }

    state = CategoryItemSortState(
      column: column,
      direction: CategoryItemSortDirection.ascending,
    );
  }
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

class InventoryItemFilters extends Notifier<InventoryItemFiltersState> {
  @override
  InventoryItemFiltersState build() => const InventoryItemFiltersState();

  void apply(InventoryItemFiltersState filters) => state = filters;

  void clear() => state = const InventoryItemFiltersState();
}

class ProductTransactionFilters
    extends Notifier<InventoryTransactionFiltersState> {
  @override
  InventoryTransactionFiltersState build() =>
      const InventoryTransactionFiltersState();

  void setTypeColumnFilter(MultiSelectColumnFilter? filter) {
    state = state.copyWith(
      typeColumnFilter: filter,
      clearTypeColumnFilter: filter == null,
      currentPage: 0,
    );
  }

  void setInvoiceRefColumnFilter(TextColumnFilter? filter) {
    state = state.copyWith(
      invoiceRefColumnFilter: filter,
      clearInvoiceRefColumnFilter: filter == null,
      currentPage: 0,
    );
  }

  void setPartyColumnFilter(TextColumnFilter? filter) {
    state = state.copyWith(
      partyColumnFilter: filter,
      clearPartyColumnFilter: filter == null,
      currentPage: 0,
    );
  }

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = state.copyWith(
      dateColumnFilter: filter,
      clearDateColumnFilter: filter == null,
      currentPage: 0,
    );
  }

  void setQuantityColumnFilter(AmountColumnFilter? filter) {
    state = state.copyWith(
      quantityColumnFilter: filter,
      clearQuantityColumnFilter: filter == null,
      currentPage: 0,
    );
  }

  void setPriceColumnFilter(AmountColumnFilter? filter) {
    state = state.copyWith(
      priceColumnFilter: filter,
      clearPriceColumnFilter: filter == null,
      currentPage: 0,
    );
  }

  void setStatusColumnFilter(MultiSelectColumnFilter? filter) {
    state = state.copyWith(
      statusColumnFilter: filter,
      clearStatusColumnFilter: filter == null,
      currentPage: 0,
    );
  }

  void toggleSort(InventoryTransactionSortColumn column) {
    if (state.sortColumn == column) {
      final nextDirection = switch (state.sortDirection) {
        InventoryTransactionSortDirection.none =>
          InventoryTransactionSortDirection.ascending,
        InventoryTransactionSortDirection.ascending =>
          InventoryTransactionSortDirection.descending,
        InventoryTransactionSortDirection.descending =>
          InventoryTransactionSortDirection.none,
      };
      state = state.copyWith(sortDirection: nextDirection, currentPage: 0);
      return;
    }

    state = state.copyWith(
      sortColumn: column,
      sortDirection: InventoryTransactionSortDirection.ascending,
      currentPage: 0,
    );
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void reset() {
    state = const InventoryTransactionFiltersState();
  }
}

class SelectedProductTransactionId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}
