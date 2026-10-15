import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockSummaryByItemCategoryColumnFiltersState {
  const StockSummaryByItemCategoryColumnFiltersState({
    this.categoryColumnFilter,
    this.saleAmountColumnFilter,
    this.purchaseAmountColumnFilter,
  });

  final TextColumnFilter? categoryColumnFilter;
  final AmountColumnFilter? saleAmountColumnFilter;
  final AmountColumnFilter? purchaseAmountColumnFilter;

  bool get hasActiveFilters =>
      (categoryColumnFilter?.isActive ?? false) ||
      (saleAmountColumnFilter?.isActive ?? false) ||
      (purchaseAmountColumnFilter?.isActive ?? false);

  StockSummaryByItemCategoryColumnFiltersState copyWith({
    TextColumnFilter? categoryColumnFilter,
    bool clearCategoryColumnFilter = false,
    AmountColumnFilter? saleAmountColumnFilter,
    bool clearSaleAmountColumnFilter = false,
    AmountColumnFilter? purchaseAmountColumnFilter,
    bool clearPurchaseAmountColumnFilter = false,
  }) {
    return StockSummaryByItemCategoryColumnFiltersState(
      categoryColumnFilter: clearCategoryColumnFilter
          ? null
          : (categoryColumnFilter ?? this.categoryColumnFilter),
      saleAmountColumnFilter: clearSaleAmountColumnFilter
          ? null
          : (saleAmountColumnFilter ?? this.saleAmountColumnFilter),
      purchaseAmountColumnFilter: clearPurchaseAmountColumnFilter
          ? null
          : (purchaseAmountColumnFilter ?? this.purchaseAmountColumnFilter),
    );
  }
}

class StockSummaryByItemCategoryColumnFilters
    extends Notifier<StockSummaryByItemCategoryColumnFiltersState> {
  @override
  StockSummaryByItemCategoryColumnFiltersState build() =>
      const StockSummaryByItemCategoryColumnFiltersState();

  void reset() {
    state = const StockSummaryByItemCategoryColumnFiltersState();
  }

  void setCategoryColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearCategoryColumnFilter: true)
        : state.copyWith(categoryColumnFilter: filter);
  }

  void setSaleAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearSaleAmountColumnFilter: true)
        : state.copyWith(saleAmountColumnFilter: filter);
  }

  void setPurchaseAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPurchaseAmountColumnFilter: true)
        : state.copyWith(purchaseAmountColumnFilter: filter);
  }
}

final stockSummaryByItemCategoryColumnFiltersProvider =
    NotifierProvider<
      StockSummaryByItemCategoryColumnFilters,
      StockSummaryByItemCategoryColumnFiltersState
    >(StockSummaryByItemCategoryColumnFilters.new);
