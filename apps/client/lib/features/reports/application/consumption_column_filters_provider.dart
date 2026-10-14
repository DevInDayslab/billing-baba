import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsumptionColumnFiltersState {
  const ConsumptionColumnFiltersState({
    this.dateColumnFilter,
    this.refNoColumnFilter,
    this.itemNameColumnFilter,
    this.quantityColumnFilter,
    this.valueColumnFilter,
  });

  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? refNoColumnFilter;
  final TextColumnFilter? itemNameColumnFilter;
  final AmountColumnFilter? quantityColumnFilter;
  final AmountColumnFilter? valueColumnFilter;

  bool get hasActiveFilters =>
      (dateColumnFilter?.isActive ?? false) ||
      (refNoColumnFilter?.isActive ?? false) ||
      (itemNameColumnFilter?.isActive ?? false) ||
      (quantityColumnFilter?.isActive ?? false) ||
      (valueColumnFilter?.isActive ?? false);

  ConsumptionColumnFiltersState copyWith({
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? refNoColumnFilter,
    bool clearRefNoColumnFilter = false,
    TextColumnFilter? itemNameColumnFilter,
    bool clearItemNameColumnFilter = false,
    AmountColumnFilter? quantityColumnFilter,
    bool clearQuantityColumnFilter = false,
    AmountColumnFilter? valueColumnFilter,
    bool clearValueColumnFilter = false,
  }) {
    return ConsumptionColumnFiltersState(
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      refNoColumnFilter: clearRefNoColumnFilter
          ? null
          : (refNoColumnFilter ?? this.refNoColumnFilter),
      itemNameColumnFilter: clearItemNameColumnFilter
          ? null
          : (itemNameColumnFilter ?? this.itemNameColumnFilter),
      quantityColumnFilter: clearQuantityColumnFilter
          ? null
          : (quantityColumnFilter ?? this.quantityColumnFilter),
      valueColumnFilter: clearValueColumnFilter
          ? null
          : (valueColumnFilter ?? this.valueColumnFilter),
    );
  }
}

class ConsumptionColumnFilters extends Notifier<ConsumptionColumnFiltersState> {
  @override
  ConsumptionColumnFiltersState build() =>
      const ConsumptionColumnFiltersState();

  void reset() {
    state = const ConsumptionColumnFiltersState();
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

  void setValueColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearValueColumnFilter: true)
        : state.copyWith(valueColumnFilter: filter);
  }
}

final consumptionColumnFiltersProvider =
    NotifierProvider<ConsumptionColumnFilters, ConsumptionColumnFiltersState>(
      ConsumptionColumnFilters.new,
    );
