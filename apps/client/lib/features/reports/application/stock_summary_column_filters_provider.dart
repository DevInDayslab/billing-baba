import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockSummaryColumnFiltersState {
  const StockSummaryColumnFiltersState({
    this.itemNameColumnFilter,
    this.salePriceColumnFilter,
    this.purchasePriceColumnFilter,
    this.stockQtyColumnFilter,
    this.stockValueColumnFilter,
  });

  final TextColumnFilter? itemNameColumnFilter;
  final AmountColumnFilter? salePriceColumnFilter;
  final AmountColumnFilter? purchasePriceColumnFilter;
  final AmountColumnFilter? stockQtyColumnFilter;
  final AmountColumnFilter? stockValueColumnFilter;

  bool get hasActiveFilters =>
      (itemNameColumnFilter?.isActive ?? false) ||
      (salePriceColumnFilter?.isActive ?? false) ||
      (purchasePriceColumnFilter?.isActive ?? false) ||
      (stockQtyColumnFilter?.isActive ?? false) ||
      (stockValueColumnFilter?.isActive ?? false);

  StockSummaryColumnFiltersState copyWith({
    TextColumnFilter? itemNameColumnFilter,
    bool clearItemNameColumnFilter = false,
    AmountColumnFilter? salePriceColumnFilter,
    bool clearSalePriceColumnFilter = false,
    AmountColumnFilter? purchasePriceColumnFilter,
    bool clearPurchasePriceColumnFilter = false,
    AmountColumnFilter? stockQtyColumnFilter,
    bool clearStockQtyColumnFilter = false,
    AmountColumnFilter? stockValueColumnFilter,
    bool clearStockValueColumnFilter = false,
  }) {
    return StockSummaryColumnFiltersState(
      itemNameColumnFilter: clearItemNameColumnFilter
          ? null
          : (itemNameColumnFilter ?? this.itemNameColumnFilter),
      salePriceColumnFilter: clearSalePriceColumnFilter
          ? null
          : (salePriceColumnFilter ?? this.salePriceColumnFilter),
      purchasePriceColumnFilter: clearPurchasePriceColumnFilter
          ? null
          : (purchasePriceColumnFilter ?? this.purchasePriceColumnFilter),
      stockQtyColumnFilter: clearStockQtyColumnFilter
          ? null
          : (stockQtyColumnFilter ?? this.stockQtyColumnFilter),
      stockValueColumnFilter: clearStockValueColumnFilter
          ? null
          : (stockValueColumnFilter ?? this.stockValueColumnFilter),
    );
  }
}

class StockSummaryColumnFilters extends Notifier<StockSummaryColumnFiltersState> {
  @override
  StockSummaryColumnFiltersState build() =>
      const StockSummaryColumnFiltersState();

  void reset() {
    state = const StockSummaryColumnFiltersState();
  }

  void setItemNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearItemNameColumnFilter: true)
        : state.copyWith(itemNameColumnFilter: filter);
  }

  void setSalePriceColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearSalePriceColumnFilter: true)
        : state.copyWith(salePriceColumnFilter: filter);
  }

  void setPurchasePriceColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPurchasePriceColumnFilter: true)
        : state.copyWith(purchasePriceColumnFilter: filter);
  }

  void setStockQtyColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearStockQtyColumnFilter: true)
        : state.copyWith(stockQtyColumnFilter: filter);
  }

  void setStockValueColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearStockValueColumnFilter: true)
        : state.copyWith(stockValueColumnFilter: filter);
  }
}

final stockSummaryColumnFiltersProvider =
    NotifierProvider<StockSummaryColumnFilters, StockSummaryColumnFiltersState>(
      StockSummaryColumnFilters.new,
    );
