import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LowStockColumnFiltersState {
  const LowStockColumnFiltersState({
    this.itemNameColumnFilter,
    this.minStockColumnFilter,
    this.currentStockColumnFilter,
    this.shortageColumnFilter,
  });

  final TextColumnFilter? itemNameColumnFilter;
  final AmountColumnFilter? minStockColumnFilter;
  final AmountColumnFilter? currentStockColumnFilter;
  final AmountColumnFilter? shortageColumnFilter;

  bool get hasActiveFilters =>
      (itemNameColumnFilter?.isActive ?? false) ||
      (minStockColumnFilter?.isActive ?? false) ||
      (currentStockColumnFilter?.isActive ?? false) ||
      (shortageColumnFilter?.isActive ?? false);

  LowStockColumnFiltersState copyWith({
    TextColumnFilter? itemNameColumnFilter,
    bool clearItemNameColumnFilter = false,
    AmountColumnFilter? minStockColumnFilter,
    bool clearMinStockColumnFilter = false,
    AmountColumnFilter? currentStockColumnFilter,
    bool clearCurrentStockColumnFilter = false,
    AmountColumnFilter? shortageColumnFilter,
    bool clearShortageColumnFilter = false,
  }) {
    return LowStockColumnFiltersState(
      itemNameColumnFilter: clearItemNameColumnFilter
          ? null
          : (itemNameColumnFilter ?? this.itemNameColumnFilter),
      minStockColumnFilter: clearMinStockColumnFilter
          ? null
          : (minStockColumnFilter ?? this.minStockColumnFilter),
      currentStockColumnFilter: clearCurrentStockColumnFilter
          ? null
          : (currentStockColumnFilter ?? this.currentStockColumnFilter),
      shortageColumnFilter: clearShortageColumnFilter
          ? null
          : (shortageColumnFilter ?? this.shortageColumnFilter),
    );
  }
}

class LowStockColumnFilters extends Notifier<LowStockColumnFiltersState> {
  @override
  LowStockColumnFiltersState build() => const LowStockColumnFiltersState();

  void reset() {
    state = const LowStockColumnFiltersState();
  }

  void setItemNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearItemNameColumnFilter: true)
        : state.copyWith(itemNameColumnFilter: filter);
  }

  void setMinStockColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearMinStockColumnFilter: true)
        : state.copyWith(minStockColumnFilter: filter);
  }

  void setCurrentStockColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearCurrentStockColumnFilter: true)
        : state.copyWith(currentStockColumnFilter: filter);
  }

  void setShortageColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearShortageColumnFilter: true)
        : state.copyWith(shortageColumnFilter: filter);
  }
}

final lowStockColumnFiltersProvider =
    NotifierProvider<LowStockColumnFilters, LowStockColumnFiltersState>(
      LowStockColumnFilters.new,
    );
