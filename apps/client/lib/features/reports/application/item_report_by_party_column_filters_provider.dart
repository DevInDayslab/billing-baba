import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemReportByPartyColumnFiltersState {
  const ItemReportByPartyColumnFiltersState({
    this.itemNameColumnFilter,
    this.partyNameColumnFilter,
    this.quantityColumnFilter,
    this.amountColumnFilter,
  });

  final TextColumnFilter? itemNameColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final AmountColumnFilter? quantityColumnFilter;
  final AmountColumnFilter? amountColumnFilter;

  bool get hasActiveFilters =>
      (itemNameColumnFilter?.isActive ?? false) ||
      (partyNameColumnFilter?.isActive ?? false) ||
      (quantityColumnFilter?.isActive ?? false) ||
      (amountColumnFilter?.isActive ?? false);

  ItemReportByPartyColumnFiltersState copyWith({
    TextColumnFilter? itemNameColumnFilter,
    bool clearItemNameColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    AmountColumnFilter? quantityColumnFilter,
    bool clearQuantityColumnFilter = false,
    AmountColumnFilter? amountColumnFilter,
    bool clearAmountColumnFilter = false,
  }) {
    return ItemReportByPartyColumnFiltersState(
      itemNameColumnFilter: clearItemNameColumnFilter
          ? null
          : (itemNameColumnFilter ?? this.itemNameColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      quantityColumnFilter: clearQuantityColumnFilter
          ? null
          : (quantityColumnFilter ?? this.quantityColumnFilter),
      amountColumnFilter: clearAmountColumnFilter
          ? null
          : (amountColumnFilter ?? this.amountColumnFilter),
    );
  }
}

class ItemReportByPartyColumnFilters
    extends Notifier<ItemReportByPartyColumnFiltersState> {
  @override
  ItemReportByPartyColumnFiltersState build() =>
      const ItemReportByPartyColumnFiltersState();

  void reset() {
    state = const ItemReportByPartyColumnFiltersState();
  }

  void setItemNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearItemNameColumnFilter: true)
        : state.copyWith(itemNameColumnFilter: filter);
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

  void setAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearAmountColumnFilter: true)
        : state.copyWith(amountColumnFilter: filter);
  }
}

final itemReportByPartyColumnFiltersProvider =
    NotifierProvider<
      ItemReportByPartyColumnFilters,
      ItemReportByPartyColumnFiltersState
    >(ItemReportByPartyColumnFilters.new);
