import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemCategoryWiseProfitLossColumnFiltersState {
  const ItemCategoryWiseProfitLossColumnFiltersState({
    this.categoryColumnFilter,
    this.saleAmountColumnFilter,
    this.purchaseAmountColumnFilter,
    this.profitColumnFilter,
  });

  final TextColumnFilter? categoryColumnFilter;
  final AmountColumnFilter? saleAmountColumnFilter;
  final AmountColumnFilter? purchaseAmountColumnFilter;
  final AmountColumnFilter? profitColumnFilter;

  bool get hasActiveFilters =>
      (categoryColumnFilter?.isActive ?? false) ||
      (saleAmountColumnFilter?.isActive ?? false) ||
      (purchaseAmountColumnFilter?.isActive ?? false) ||
      (profitColumnFilter?.isActive ?? false);

  ItemCategoryWiseProfitLossColumnFiltersState copyWith({
    TextColumnFilter? categoryColumnFilter,
    bool clearCategoryColumnFilter = false,
    AmountColumnFilter? saleAmountColumnFilter,
    bool clearSaleAmountColumnFilter = false,
    AmountColumnFilter? purchaseAmountColumnFilter,
    bool clearPurchaseAmountColumnFilter = false,
    AmountColumnFilter? profitColumnFilter,
    bool clearProfitColumnFilter = false,
  }) {
    return ItemCategoryWiseProfitLossColumnFiltersState(
      categoryColumnFilter: clearCategoryColumnFilter
          ? null
          : (categoryColumnFilter ?? this.categoryColumnFilter),
      saleAmountColumnFilter: clearSaleAmountColumnFilter
          ? null
          : (saleAmountColumnFilter ?? this.saleAmountColumnFilter),
      purchaseAmountColumnFilter: clearPurchaseAmountColumnFilter
          ? null
          : (purchaseAmountColumnFilter ?? this.purchaseAmountColumnFilter),
      profitColumnFilter: clearProfitColumnFilter
          ? null
          : (profitColumnFilter ?? this.profitColumnFilter),
    );
  }
}

class ItemCategoryWiseProfitLossColumnFilters
    extends Notifier<ItemCategoryWiseProfitLossColumnFiltersState> {
  @override
  ItemCategoryWiseProfitLossColumnFiltersState build() =>
      const ItemCategoryWiseProfitLossColumnFiltersState();

  void reset() {
    state = const ItemCategoryWiseProfitLossColumnFiltersState();
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

  void setProfitColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearProfitColumnFilter: true)
        : state.copyWith(profitColumnFilter: filter);
  }
}

final itemCategoryWiseProfitLossColumnFiltersProvider =
    NotifierProvider<
      ItemCategoryWiseProfitLossColumnFilters,
      ItemCategoryWiseProfitLossColumnFiltersState
    >(ItemCategoryWiseProfitLossColumnFilters.new);
