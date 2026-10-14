import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemWiseDiscountColumnFiltersState {
  const ItemWiseDiscountColumnFiltersState({
    this.itemNameColumnFilter,
    this.saleQtyColumnFilter,
    this.discountAmountColumnFilter,
    this.discountPercentColumnFilter,
  });

  final TextColumnFilter? itemNameColumnFilter;
  final AmountColumnFilter? saleQtyColumnFilter;
  final AmountColumnFilter? discountAmountColumnFilter;
  final AmountColumnFilter? discountPercentColumnFilter;

  bool get hasActiveFilters =>
      (itemNameColumnFilter?.isActive ?? false) ||
      (saleQtyColumnFilter?.isActive ?? false) ||
      (discountAmountColumnFilter?.isActive ?? false) ||
      (discountPercentColumnFilter?.isActive ?? false);

  ItemWiseDiscountColumnFiltersState copyWith({
    TextColumnFilter? itemNameColumnFilter,
    bool clearItemNameColumnFilter = false,
    AmountColumnFilter? saleQtyColumnFilter,
    bool clearSaleQtyColumnFilter = false,
    AmountColumnFilter? discountAmountColumnFilter,
    bool clearDiscountAmountColumnFilter = false,
    AmountColumnFilter? discountPercentColumnFilter,
    bool clearDiscountPercentColumnFilter = false,
  }) {
    return ItemWiseDiscountColumnFiltersState(
      itemNameColumnFilter: clearItemNameColumnFilter
          ? null
          : (itemNameColumnFilter ?? this.itemNameColumnFilter),
      saleQtyColumnFilter: clearSaleQtyColumnFilter
          ? null
          : (saleQtyColumnFilter ?? this.saleQtyColumnFilter),
      discountAmountColumnFilter: clearDiscountAmountColumnFilter
          ? null
          : (discountAmountColumnFilter ?? this.discountAmountColumnFilter),
      discountPercentColumnFilter: clearDiscountPercentColumnFilter
          ? null
          : (discountPercentColumnFilter ?? this.discountPercentColumnFilter),
    );
  }
}

class ItemWiseDiscountColumnFilters
    extends Notifier<ItemWiseDiscountColumnFiltersState> {
  @override
  ItemWiseDiscountColumnFiltersState build() =>
      const ItemWiseDiscountColumnFiltersState();

  void reset() {
    state = const ItemWiseDiscountColumnFiltersState();
  }

  void setItemNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearItemNameColumnFilter: true)
        : state.copyWith(itemNameColumnFilter: filter);
  }

  void setSaleQtyColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearSaleQtyColumnFilter: true)
        : state.copyWith(saleQtyColumnFilter: filter);
  }

  void setDiscountAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDiscountAmountColumnFilter: true)
        : state.copyWith(discountAmountColumnFilter: filter);
  }

  void setDiscountPercentColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDiscountPercentColumnFilter: true)
        : state.copyWith(discountPercentColumnFilter: filter);
  }
}

final itemWiseDiscountColumnFiltersProvider =
    NotifierProvider<
      ItemWiseDiscountColumnFilters,
      ItemWiseDiscountColumnFiltersState
    >(ItemWiseDiscountColumnFilters.new);
