import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManufacturingColumnFiltersState {
  const ManufacturingColumnFiltersState({
    this.dateColumnFilter,
    this.refNoColumnFilter,
    this.itemNameColumnFilter,
    this.quantityColumnFilter,
    this.costColumnFilter,
  });

  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? refNoColumnFilter;
  final TextColumnFilter? itemNameColumnFilter;
  final AmountColumnFilter? quantityColumnFilter;
  final AmountColumnFilter? costColumnFilter;

  bool get hasActiveFilters =>
      (dateColumnFilter?.isActive ?? false) ||
      (refNoColumnFilter?.isActive ?? false) ||
      (itemNameColumnFilter?.isActive ?? false) ||
      (quantityColumnFilter?.isActive ?? false) ||
      (costColumnFilter?.isActive ?? false);

  ManufacturingColumnFiltersState copyWith({
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? refNoColumnFilter,
    bool clearRefNoColumnFilter = false,
    TextColumnFilter? itemNameColumnFilter,
    bool clearItemNameColumnFilter = false,
    AmountColumnFilter? quantityColumnFilter,
    bool clearQuantityColumnFilter = false,
    AmountColumnFilter? costColumnFilter,
    bool clearCostColumnFilter = false,
  }) {
    return ManufacturingColumnFiltersState(
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
      costColumnFilter: clearCostColumnFilter
          ? null
          : (costColumnFilter ?? this.costColumnFilter),
    );
  }
}

class ManufacturingColumnFilters extends Notifier<ManufacturingColumnFiltersState> {
  @override
  ManufacturingColumnFiltersState build() =>
      const ManufacturingColumnFiltersState();

  void reset() {
    state = const ManufacturingColumnFiltersState();
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

  void setCostColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearCostColumnFilter: true)
        : state.copyWith(costColumnFilter: filter);
  }
}

final manufacturingColumnFiltersProvider =
    NotifierProvider<ManufacturingColumnFilters, ManufacturingColumnFiltersState>(
      ManufacturingColumnFilters.new,
    );
