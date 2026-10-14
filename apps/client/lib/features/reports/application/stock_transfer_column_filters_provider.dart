import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockTransferColumnFiltersState {
  const StockTransferColumnFiltersState({
    this.dateColumnFilter,
    this.refNoColumnFilter,
    this.fromGodownColumnFilter,
    this.toGodownColumnFilter,
    this.itemNameColumnFilter,
    this.quantityColumnFilter,
  });

  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? refNoColumnFilter;
  final TextColumnFilter? fromGodownColumnFilter;
  final TextColumnFilter? toGodownColumnFilter;
  final TextColumnFilter? itemNameColumnFilter;
  final AmountColumnFilter? quantityColumnFilter;

  bool get hasActiveFilters =>
      (dateColumnFilter?.isActive ?? false) ||
      (refNoColumnFilter?.isActive ?? false) ||
      (fromGodownColumnFilter?.isActive ?? false) ||
      (toGodownColumnFilter?.isActive ?? false) ||
      (itemNameColumnFilter?.isActive ?? false) ||
      (quantityColumnFilter?.isActive ?? false);

  StockTransferColumnFiltersState copyWith({
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? refNoColumnFilter,
    bool clearRefNoColumnFilter = false,
    TextColumnFilter? fromGodownColumnFilter,
    bool clearFromGodownColumnFilter = false,
    TextColumnFilter? toGodownColumnFilter,
    bool clearToGodownColumnFilter = false,
    TextColumnFilter? itemNameColumnFilter,
    bool clearItemNameColumnFilter = false,
    AmountColumnFilter? quantityColumnFilter,
    bool clearQuantityColumnFilter = false,
  }) {
    return StockTransferColumnFiltersState(
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      refNoColumnFilter: clearRefNoColumnFilter
          ? null
          : (refNoColumnFilter ?? this.refNoColumnFilter),
      fromGodownColumnFilter: clearFromGodownColumnFilter
          ? null
          : (fromGodownColumnFilter ?? this.fromGodownColumnFilter),
      toGodownColumnFilter: clearToGodownColumnFilter
          ? null
          : (toGodownColumnFilter ?? this.toGodownColumnFilter),
      itemNameColumnFilter: clearItemNameColumnFilter
          ? null
          : (itemNameColumnFilter ?? this.itemNameColumnFilter),
      quantityColumnFilter: clearQuantityColumnFilter
          ? null
          : (quantityColumnFilter ?? this.quantityColumnFilter),
    );
  }
}

class StockTransferColumnFilters extends Notifier<StockTransferColumnFiltersState> {
  @override
  StockTransferColumnFiltersState build() =>
      const StockTransferColumnFiltersState();

  void reset() {
    state = const StockTransferColumnFiltersState();
  }

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDateColumnFilter: true)
        : state.copyWith(dateColumnFilter: filter);
  }

  void setRefNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearRefNoColumnFilter: true)
        : state.copyWith(refNoColumnFilter: filter);
  }

  void setFromGodownColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearFromGodownColumnFilter: true)
        : state.copyWith(fromGodownColumnFilter: filter);
  }

  void setToGodownColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearToGodownColumnFilter: true)
        : state.copyWith(toGodownColumnFilter: filter);
  }

  void setItemNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearItemNameColumnFilter: true)
        : state.copyWith(itemNameColumnFilter: filter);
  }

  void setQuantityColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearQuantityColumnFilter: true)
        : state.copyWith(quantityColumnFilter: filter);
  }
}

final stockTransferColumnFiltersProvider =
    NotifierProvider<StockTransferColumnFilters, StockTransferColumnFiltersState>(
      StockTransferColumnFilters.new,
    );
