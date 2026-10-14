import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashFlowColumnFiltersState {
  const CashFlowColumnFiltersState({
    this.dateColumnFilter,
    this.refNoColumnFilter,
    this.partyNameColumnFilter,
    this.categoryColumnFilter,
    this.typeColumnFilter,
    this.moneyInColumnFilter,
    this.moneyOutColumnFilter,
    this.runningBalanceColumnFilter,
  });

  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? refNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final SelectColumnFilter? categoryColumnFilter;
  final SelectColumnFilter? typeColumnFilter;
  final AmountColumnFilter? moneyInColumnFilter;
  final AmountColumnFilter? moneyOutColumnFilter;
  final AmountColumnFilter? runningBalanceColumnFilter;

  bool get hasActiveFilters =>
      (dateColumnFilter?.isActive ?? false) ||
      (refNoColumnFilter?.isActive ?? false) ||
      (partyNameColumnFilter?.isActive ?? false) ||
      (categoryColumnFilter?.isActive ?? false) ||
      (typeColumnFilter?.isActive ?? false) ||
      (moneyInColumnFilter?.isActive ?? false) ||
      (moneyOutColumnFilter?.isActive ?? false) ||
      (runningBalanceColumnFilter?.isActive ?? false);

  CashFlowColumnFiltersState copyWith({
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? refNoColumnFilter,
    bool clearRefNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    SelectColumnFilter? categoryColumnFilter,
    bool clearCategoryColumnFilter = false,
    SelectColumnFilter? typeColumnFilter,
    bool clearTypeColumnFilter = false,
    AmountColumnFilter? moneyInColumnFilter,
    bool clearMoneyInColumnFilter = false,
    AmountColumnFilter? moneyOutColumnFilter,
    bool clearMoneyOutColumnFilter = false,
    AmountColumnFilter? runningBalanceColumnFilter,
    bool clearRunningBalanceColumnFilter = false,
  }) {
    return CashFlowColumnFiltersState(
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      refNoColumnFilter: clearRefNoColumnFilter
          ? null
          : (refNoColumnFilter ?? this.refNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      categoryColumnFilter: clearCategoryColumnFilter
          ? null
          : (categoryColumnFilter ?? this.categoryColumnFilter),
      typeColumnFilter: clearTypeColumnFilter
          ? null
          : (typeColumnFilter ?? this.typeColumnFilter),
      moneyInColumnFilter: clearMoneyInColumnFilter
          ? null
          : (moneyInColumnFilter ?? this.moneyInColumnFilter),
      moneyOutColumnFilter: clearMoneyOutColumnFilter
          ? null
          : (moneyOutColumnFilter ?? this.moneyOutColumnFilter),
      runningBalanceColumnFilter: clearRunningBalanceColumnFilter
          ? null
          : (runningBalanceColumnFilter ?? this.runningBalanceColumnFilter),
    );
  }
}

class CashFlowColumnFilters extends Notifier<CashFlowColumnFiltersState> {
  @override
  CashFlowColumnFiltersState build() => const CashFlowColumnFiltersState();

  void reset() {
    state = const CashFlowColumnFiltersState();
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

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true)
        : state.copyWith(partyNameColumnFilter: filter);
  }

  void setCategoryColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearCategoryColumnFilter: true)
        : state.copyWith(categoryColumnFilter: filter);
  }

  void setTypeColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearTypeColumnFilter: true)
        : state.copyWith(typeColumnFilter: filter);
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

  void setRunningBalanceColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearRunningBalanceColumnFilter: true)
        : state.copyWith(runningBalanceColumnFilter: filter);
  }
}

final cashFlowColumnFiltersProvider =
    NotifierProvider<CashFlowColumnFilters, CashFlowColumnFiltersState>(
      CashFlowColumnFilters.new,
    );

const cashFlowTypeFilterOptions = [
  'Sale',
  'Purchase',
  'Payment In',
  'Payment Out',
  'Expense',
];

const cashFlowCategoryFilterOptions = [
  'Sales',
  'Purchase',
  'Payment',
  'Expense',
];
