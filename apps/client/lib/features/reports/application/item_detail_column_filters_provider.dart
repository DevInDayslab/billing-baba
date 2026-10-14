import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemDetailColumnFiltersState {
  const ItemDetailColumnFiltersState({
    this.dateColumnFilter,
    this.typeColumnFilter,
    this.refNoColumnFilter,
    this.partyNameColumnFilter,
    this.quantityColumnFilter,
    this.priceColumnFilter,
    this.amountColumnFilter,
    this.closingQtyColumnFilter,
  });

  final DateColumnFilter? dateColumnFilter;
  final SelectColumnFilter? typeColumnFilter;
  final TextColumnFilter? refNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final AmountColumnFilter? quantityColumnFilter;
  final AmountColumnFilter? priceColumnFilter;
  final AmountColumnFilter? amountColumnFilter;
  final AmountColumnFilter? closingQtyColumnFilter;

  bool get hasActiveFilters =>
      (dateColumnFilter?.isActive ?? false) ||
      (typeColumnFilter?.isActive ?? false) ||
      (refNoColumnFilter?.isActive ?? false) ||
      (partyNameColumnFilter?.isActive ?? false) ||
      (quantityColumnFilter?.isActive ?? false) ||
      (priceColumnFilter?.isActive ?? false) ||
      (amountColumnFilter?.isActive ?? false) ||
      (closingQtyColumnFilter?.isActive ?? false);

  ItemDetailColumnFiltersState copyWith({
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    SelectColumnFilter? typeColumnFilter,
    bool clearTypeColumnFilter = false,
    TextColumnFilter? refNoColumnFilter,
    bool clearRefNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    AmountColumnFilter? quantityColumnFilter,
    bool clearQuantityColumnFilter = false,
    AmountColumnFilter? priceColumnFilter,
    bool clearPriceColumnFilter = false,
    AmountColumnFilter? amountColumnFilter,
    bool clearAmountColumnFilter = false,
    AmountColumnFilter? closingQtyColumnFilter,
    bool clearClosingQtyColumnFilter = false,
  }) {
    return ItemDetailColumnFiltersState(
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      typeColumnFilter: clearTypeColumnFilter
          ? null
          : (typeColumnFilter ?? this.typeColumnFilter),
      refNoColumnFilter: clearRefNoColumnFilter
          ? null
          : (refNoColumnFilter ?? this.refNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      quantityColumnFilter: clearQuantityColumnFilter
          ? null
          : (quantityColumnFilter ?? this.quantityColumnFilter),
      priceColumnFilter: clearPriceColumnFilter
          ? null
          : (priceColumnFilter ?? this.priceColumnFilter),
      amountColumnFilter: clearAmountColumnFilter
          ? null
          : (amountColumnFilter ?? this.amountColumnFilter),
      closingQtyColumnFilter: clearClosingQtyColumnFilter
          ? null
          : (closingQtyColumnFilter ?? this.closingQtyColumnFilter),
    );
  }
}

class ItemDetailColumnFilters extends Notifier<ItemDetailColumnFiltersState> {
  @override
  ItemDetailColumnFiltersState build() => const ItemDetailColumnFiltersState();

  void reset() {
    state = const ItemDetailColumnFiltersState();
  }

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDateColumnFilter: true)
        : state.copyWith(dateColumnFilter: filter);
  }

  void setTypeColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearTypeColumnFilter: true)
        : state.copyWith(typeColumnFilter: filter);
  }

  void setRefNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearRefNoColumnFilter: true)
        : state.copyWith(refNoColumnFilter: filter);
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true)
        : state.copyWith(partyNameColumnFilter: filter);
  }

  void setQuantityColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearQuantityColumnFilter: true)
        : state.copyWith(quantityColumnFilter: filter);
  }

  void setPriceColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPriceColumnFilter: true)
        : state.copyWith(priceColumnFilter: filter);
  }

  void setAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearAmountColumnFilter: true)
        : state.copyWith(amountColumnFilter: filter);
  }

  void setClosingQtyColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearClosingQtyColumnFilter: true)
        : state.copyWith(closingQtyColumnFilter: filter);
  }
}

final itemDetailColumnFiltersProvider =
    NotifierProvider<ItemDetailColumnFilters, ItemDetailColumnFiltersState>(
      ItemDetailColumnFilters.new,
    );
