import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/application/mobile_stock_summary_models.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mobileStockSummaryFiltersProvider =
    NotifierProvider<MobileStockSummaryFiltersNotifier, MobileStockSummaryFilters>(
      MobileStockSummaryFiltersNotifier.new,
    );

class MobileStockSummaryFiltersNotifier extends Notifier<MobileStockSummaryFilters> {
  @override
  MobileStockSummaryFilters build() => MobileStockSummaryFilters();

  void setUseAsOnDate(bool value) {
    state = state.copyWith(useAsOnDate: value);
  }

  void setAsOnDate(DateTime date) {
    state = state.copyWith(asOnDate: date);
  }

  void setCategoryId(String? categoryId) {
    state = state.copyWith(
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
    );
  }

  void setStockFilter(MobileStockSummaryStockFilter filter) {
    state = state.copyWith(stockFilter: filter);
  }

  void setStatusFilter(MobileStockSummaryStatusFilter filter) {
    state = state.copyWith(statusFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSearchVisible(bool visible) {
    state = state.copyWith(searchVisible: visible);
  }

  void resetFilters() {
    state = state.copyWith(
      clearCategoryId: true,
      stockFilter: MobileStockSummaryStockFilter.all,
      statusFilter: MobileStockSummaryStatusFilter.all,
    );
  }
}

final mobileStockSummaryProductsProvider = Provider<List<InventoryItem>>((ref) {
  return ref.watch(inventoryItemListProvider)
      .where((item) => item.type == ItemType.product)
      .toList();
});

final mobileStockSummaryRowsProvider =
    Provider<List<MobileStockSummaryRow>>((ref) {
      final items = ref.watch(mobileStockSummaryProductsProvider);
      final filters = ref.watch(mobileStockSummaryFiltersProvider);
      final engine = ref.watch(inventorySearchEngineProvider);

      var filtered = items;

      if (filters.searchQuery.trim().isNotEmpty) {
        filtered = searchInventoryItems(
          engine,
          filtered,
          query: filters.searchQuery,
        );
      }

      if (filters.categoryId != null) {
        filtered = filtered
            .where((item) => item.categoryId == filters.categoryId)
            .toList();
      }

      filtered = filtered.where((item) {
        final qty = item.quantity ?? 0;
        return switch (filters.stockFilter) {
          MobileStockSummaryStockFilter.all => true,
          MobileStockSummaryStockFilter.inStock => qty > 0,
          MobileStockSummaryStockFilter.outOfStock => qty <= 0,
        };
      }).toList();

      filtered = filtered.where((item) {
        final qty = item.quantity ?? 0;
        final isLowStock = isMobileStockSummaryLowStock(item);
        return switch (filters.statusFilter) {
          MobileStockSummaryStatusFilter.all => true,
          MobileStockSummaryStatusFilter.lowStock => isLowStock,
          MobileStockSummaryStatusFilter.inStock => qty > 0 && !isLowStock,
          MobileStockSummaryStatusFilter.outOfStock => qty <= 0,
        };
      }).toList();

      return [
        for (final item in filtered)
          MobileStockSummaryRow(
            item: item,
            stockQty: item.quantity ?? 0,
            stockValue: resolveMobileStockSummaryValue(item),
            isLowStock: isMobileStockSummaryLowStock(item),
          ),
      ];
    });

final mobileStockSummaryMetricsProvider =
    Provider<MobileStockSummaryMetrics>((ref) {
      final rows = ref.watch(mobileStockSummaryRowsProvider);
      return MobileStockSummaryMetrics(
        itemCount: rows.length,
        lowStockCount: rows.where((row) => row.isLowStock).length,
        totalStockValue: rows.fold<double>(
          0,
          (sum, row) => sum + row.stockValue,
        ),
      );
    });

final mobileStockSummaryCategoryLabelProvider = Provider<String>((ref) {
  final filters = ref.watch(mobileStockSummaryFiltersProvider);
  if (filters.categoryId == null) return 'All';

  final categories = ref.watch(categoriesProvider);
  return categories
          .where((category) => category.id == filters.categoryId)
          .map((category) => category.name)
          .firstOrNull ??
      'All';
});
