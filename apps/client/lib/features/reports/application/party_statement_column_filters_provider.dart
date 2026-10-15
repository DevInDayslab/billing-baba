import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyStatementColumnFiltersState {
  const PartyStatementColumnFiltersState({
    this.dateColumnFilter,
    this.typeColumnFilter,
    this.refNoColumnFilter,
    this.totalColumnFilter,
    this.balanceColumnFilter,
  });

  final DateColumnFilter? dateColumnFilter;
  final SelectColumnFilter? typeColumnFilter;
  final TextColumnFilter? refNoColumnFilter;
  final AmountColumnFilter? totalColumnFilter;
  final AmountColumnFilter? balanceColumnFilter;

  bool get hasActiveFilters =>
      (dateColumnFilter?.isActive ?? false) ||
      (typeColumnFilter?.isActive ?? false) ||
      (refNoColumnFilter?.isActive ?? false) ||
      (totalColumnFilter?.isActive ?? false) ||
      (balanceColumnFilter?.isActive ?? false);

  PartyStatementColumnFiltersState copyWith({
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    SelectColumnFilter? typeColumnFilter,
    bool clearTypeColumnFilter = false,
    TextColumnFilter? refNoColumnFilter,
    bool clearRefNoColumnFilter = false,
    AmountColumnFilter? totalColumnFilter,
    bool clearTotalColumnFilter = false,
    AmountColumnFilter? balanceColumnFilter,
    bool clearBalanceColumnFilter = false,
  }) {
    return PartyStatementColumnFiltersState(
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      typeColumnFilter: clearTypeColumnFilter
          ? null
          : (typeColumnFilter ?? this.typeColumnFilter),
      refNoColumnFilter: clearRefNoColumnFilter
          ? null
          : (refNoColumnFilter ?? this.refNoColumnFilter),
      totalColumnFilter: clearTotalColumnFilter
          ? null
          : (totalColumnFilter ?? this.totalColumnFilter),
      balanceColumnFilter: clearBalanceColumnFilter
          ? null
          : (balanceColumnFilter ?? this.balanceColumnFilter),
    );
  }
}

class PartyStatementColumnFilters
    extends Notifier<PartyStatementColumnFiltersState> {
  @override
  PartyStatementColumnFiltersState build() =>
      const PartyStatementColumnFiltersState();

  void reset() {
    state = const PartyStatementColumnFiltersState();
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

  void setTotalColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearTotalColumnFilter: true)
        : state.copyWith(totalColumnFilter: filter);
  }

  void setBalanceColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearBalanceColumnFilter: true)
        : state.copyWith(balanceColumnFilter: filter);
  }
}

final partyStatementColumnFiltersProvider =
    NotifierProvider<PartyStatementColumnFilters,
        PartyStatementColumnFiltersState>(
      PartyStatementColumnFilters.new,
    );
