import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemWiseProfitLossColumnFiltersState {
  const ItemWiseProfitLossColumnFiltersState({
    this.itemNameColumnFilter,
    this.saleAmountColumnFilter,
    this.purchaseAmountColumnFilter,
    this.profitColumnFilter,
  });

  final TextColumnFilter? itemNameColumnFilter;
  final AmountColumnFilter? saleAmountColumnFilter;
  final AmountColumnFilter? purchaseAmountColumnFilter;
  final AmountColumnFilter? profitColumnFilter;

  bool get hasActiveFilters =>
      (itemNameColumnFilter?.isActive ?? false) ||
      (saleAmountColumnFilter?.isActive ?? false) ||
      (purchaseAmountColumnFilter?.isActive ?? false) ||
      (profitColumnFilter?.isActive ?? false);

  ItemWiseProfitLossColumnFiltersState copyWith({
    TextColumnFilter? itemNameColumnFilter,
    bool clearItemNameColumnFilter = false,
    AmountColumnFilter? saleAmountColumnFilter,
    bool clearSaleAmountColumnFilter = false,
    AmountColumnFilter? purchaseAmountColumnFilter,
    bool clearPurchaseAmountColumnFilter = false,
    AmountColumnFilter? profitColumnFilter,
    bool clearProfitColumnFilter = false,
  }) {
    return ItemWiseProfitLossColumnFiltersState(
      itemNameColumnFilter: clearItemNameColumnFilter
          ? null
          : (itemNameColumnFilter ?? this.itemNameColumnFilter),
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

class ItemWiseProfitLossColumnFilters
    extends Notifier<ItemWiseProfitLossColumnFiltersState> {
  @override
  ItemWiseProfitLossColumnFiltersState build() =>
      const ItemWiseProfitLossColumnFiltersState();

  void reset() {
    state = const ItemWiseProfitLossColumnFiltersState();
  }

  void setItemNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearItemNameColumnFilter: true)
        : state.copyWith(itemNameColumnFilter: filter);
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

final itemWiseProfitLossColumnFiltersProvider =
    NotifierProvider<
      ItemWiseProfitLossColumnFilters,
      ItemWiseProfitLossColumnFiltersState
    >(ItemWiseProfitLossColumnFilters.new);
