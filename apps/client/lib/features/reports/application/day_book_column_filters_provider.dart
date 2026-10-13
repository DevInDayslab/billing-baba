import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DayBookColumnFiltersState {
  const DayBookColumnFiltersState({
    this.partyNameColumnFilter,
    this.refNoColumnFilter,
    this.typeColumnFilter,
    this.totalColumnFilter,
    this.moneyInColumnFilter,
    this.moneyOutColumnFilter,
  });

  final TextColumnFilter? partyNameColumnFilter;
  final TextColumnFilter? refNoColumnFilter;
  final SelectColumnFilter? typeColumnFilter;
  final AmountColumnFilter? totalColumnFilter;
  final AmountColumnFilter? moneyInColumnFilter;
  final AmountColumnFilter? moneyOutColumnFilter;

  bool get hasActiveFilters =>
      (partyNameColumnFilter?.isActive ?? false) ||
      (refNoColumnFilter?.isActive ?? false) ||
      (typeColumnFilter?.isActive ?? false) ||
      (totalColumnFilter?.isActive ?? false) ||
      (moneyInColumnFilter?.isActive ?? false) ||
      (moneyOutColumnFilter?.isActive ?? false);

  DayBookColumnFiltersState copyWith({
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    TextColumnFilter? refNoColumnFilter,
    bool clearRefNoColumnFilter = false,
    SelectColumnFilter? typeColumnFilter,
    bool clearTypeColumnFilter = false,
    AmountColumnFilter? totalColumnFilter,
    bool clearTotalColumnFilter = false,
    AmountColumnFilter? moneyInColumnFilter,
    bool clearMoneyInColumnFilter = false,
    AmountColumnFilter? moneyOutColumnFilter,
    bool clearMoneyOutColumnFilter = false,
  }) {
    return DayBookColumnFiltersState(
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      refNoColumnFilter: clearRefNoColumnFilter
          ? null
          : (refNoColumnFilter ?? this.refNoColumnFilter),
      typeColumnFilter: clearTypeColumnFilter
          ? null
          : (typeColumnFilter ?? this.typeColumnFilter),
      totalColumnFilter: clearTotalColumnFilter
          ? null
          : (totalColumnFilter ?? this.totalColumnFilter),
      moneyInColumnFilter: clearMoneyInColumnFilter
          ? null
          : (moneyInColumnFilter ?? this.moneyInColumnFilter),
      moneyOutColumnFilter: clearMoneyOutColumnFilter
          ? null
          : (moneyOutColumnFilter ?? this.moneyOutColumnFilter),
    );
  }
}

class DayBookColumnFilters extends Notifier<DayBookColumnFiltersState> {
  @override
  DayBookColumnFiltersState build() => const DayBookColumnFiltersState();

  void reset() {
    state = const DayBookColumnFiltersState();
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true)
        : state.copyWith(partyNameColumnFilter: filter);
  }

  void setRefNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearRefNoColumnFilter: true)
        : state.copyWith(refNoColumnFilter: filter);
  }

  void setTypeColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearTypeColumnFilter: true)
        : state.copyWith(typeColumnFilter: filter);
  }

  void setTotalColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearTotalColumnFilter: true)
        : state.copyWith(totalColumnFilter: filter);
  }

  void setMoneyInColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearMoneyInColumnFilter: true)
        : state.copyWith(moneyInColumnFilter: filter);
  }

  void setMoneyOutColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearMoneyOutColumnFilter: true)
        : state.copyWith(moneyOutColumnFilter: filter);
  }
}

final dayBookColumnFiltersProvider =
    NotifierProvider<DayBookColumnFilters, DayBookColumnFiltersState>(
      DayBookColumnFilters.new,
    );

const dayBookTypeFilterOptions = [
  'Sale',
  'Purchase',
  'Payment In',
  'Payment Out',
  'Expense',
];
