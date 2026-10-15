import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockDetailColumnFiltersState {
  const StockDetailColumnFiltersState({
    this.itemNameColumnFilter,
    this.openingColumnFilter,
    this.inColumnFilter,
    this.outColumnFilter,
    this.closingColumnFilter,
  });

  final TextColumnFilter? itemNameColumnFilter;
  final AmountColumnFilter? openingColumnFilter;
  final AmountColumnFilter? inColumnFilter;
  final AmountColumnFilter? outColumnFilter;
  final AmountColumnFilter? closingColumnFilter;

  bool get hasActiveFilters =>
      (itemNameColumnFilter?.isActive ?? false) ||
      (openingColumnFilter?.isActive ?? false) ||
      (inColumnFilter?.isActive ?? false) ||
      (outColumnFilter?.isActive ?? false) ||
      (closingColumnFilter?.isActive ?? false);

  StockDetailColumnFiltersState copyWith({
    TextColumnFilter? itemNameColumnFilter,
    bool clearItemNameColumnFilter = false,
    AmountColumnFilter? openingColumnFilter,
    bool clearOpeningColumnFilter = false,
    AmountColumnFilter? inColumnFilter,
    bool clearInColumnFilter = false,
    AmountColumnFilter? outColumnFilter,
    bool clearOutColumnFilter = false,
    AmountColumnFilter? closingColumnFilter,
    bool clearClosingColumnFilter = false,
  }) {
    return StockDetailColumnFiltersState(
      itemNameColumnFilter: clearItemNameColumnFilter
          ? null
          : (itemNameColumnFilter ?? this.itemNameColumnFilter),
      openingColumnFilter: clearOpeningColumnFilter
          ? null
          : (openingColumnFilter ?? this.openingColumnFilter),
      inColumnFilter: clearInColumnFilter
          ? null
          : (inColumnFilter ?? this.inColumnFilter),
      outColumnFilter: clearOutColumnFilter
          ? null
          : (outColumnFilter ?? this.outColumnFilter),
      closingColumnFilter: clearClosingColumnFilter
          ? null
          : (closingColumnFilter ?? this.closingColumnFilter),
    );
  }
}

class StockDetailColumnFilters extends Notifier<StockDetailColumnFiltersState> {
  @override
  StockDetailColumnFiltersState build() =>
      const StockDetailColumnFiltersState();

  void reset() {
    state = const StockDetailColumnFiltersState();
  }

  void setItemNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearItemNameColumnFilter: true)
        : state.copyWith(itemNameColumnFilter: filter);
  }

  void setOpeningColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearOpeningColumnFilter: true)
        : state.copyWith(openingColumnFilter: filter);
  }

  void setInColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearInColumnFilter: true)
        : state.copyWith(inColumnFilter: filter);
  }

  void setOutColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearOutColumnFilter: true)
        : state.copyWith(outColumnFilter: filter);
  }

  void setClosingColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearClosingColumnFilter: true)
        : state.copyWith(closingColumnFilter: filter);
  }
}

final stockDetailColumnFiltersProvider =
    NotifierProvider<StockDetailColumnFilters, StockDetailColumnFiltersState>(
      StockDetailColumnFilters.new,
    );
