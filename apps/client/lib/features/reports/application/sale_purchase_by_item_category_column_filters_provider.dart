import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalePurchaseByItemCategoryColumnFiltersState {
  const SalePurchaseByItemCategoryColumnFiltersState({
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

  SalePurchaseByItemCategoryColumnFiltersState copyWith({
    TextColumnFilter? categoryColumnFilter,
    bool clearCategoryColumnFilter = false,
    AmountColumnFilter? saleAmountColumnFilter,
    bool clearSaleAmountColumnFilter = false,
    AmountColumnFilter? purchaseAmountColumnFilter,
    bool clearPurchaseAmountColumnFilter = false,
  }) {
    return SalePurchaseByItemCategoryColumnFiltersState(
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

class SalePurchaseByItemCategoryColumnFilters
    extends Notifier<SalePurchaseByItemCategoryColumnFiltersState> {
  @override
  SalePurchaseByItemCategoryColumnFiltersState build() =>
      const SalePurchaseByItemCategoryColumnFiltersState();

  void reset() {
    state = const SalePurchaseByItemCategoryColumnFiltersState();
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

final salePurchaseByItemCategoryColumnFiltersProvider =
    NotifierProvider<
      SalePurchaseByItemCategoryColumnFilters,
      SalePurchaseByItemCategoryColumnFiltersState
    >(SalePurchaseByItemCategoryColumnFilters.new);
