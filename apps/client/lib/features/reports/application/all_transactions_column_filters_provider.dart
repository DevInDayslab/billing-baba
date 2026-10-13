import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllTransactionsColumnFiltersState {
  const AllTransactionsColumnFiltersState({
    this.dateColumnFilter,
    this.refNoColumnFilter,
    this.partyNameColumnFilter,
    this.categoryColumnFilter,
    this.typeColumnFilter,
    this.totalColumnFilter,
    this.receivedColumnFilter,
    this.balanceColumnFilter,
    this.dueDateColumnFilter,
    this.statusColumnFilter,
  });

  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? refNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final TextColumnFilter? categoryColumnFilter;
  final SelectColumnFilter? typeColumnFilter;
  final AmountColumnFilter? totalColumnFilter;
  final AmountColumnFilter? receivedColumnFilter;
  final AmountColumnFilter? balanceColumnFilter;
  final DateColumnFilter? dueDateColumnFilter;
  final TextColumnFilter? statusColumnFilter;

  bool get hasActiveFilters =>
      (dateColumnFilter?.isActive ?? false) ||
      (refNoColumnFilter?.isActive ?? false) ||
      (partyNameColumnFilter?.isActive ?? false) ||
      (categoryColumnFilter?.isActive ?? false) ||
      (typeColumnFilter?.isActive ?? false) ||
      (totalColumnFilter?.isActive ?? false) ||
      (receivedColumnFilter?.isActive ?? false) ||
      (balanceColumnFilter?.isActive ?? false) ||
      (dueDateColumnFilter?.isActive ?? false) ||
      (statusColumnFilter?.isActive ?? false);

  AllTransactionsColumnFiltersState copyWith({
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? refNoColumnFilter,
    bool clearRefNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    TextColumnFilter? categoryColumnFilter,
    bool clearCategoryColumnFilter = false,
    SelectColumnFilter? typeColumnFilter,
    bool clearTypeColumnFilter = false,
    AmountColumnFilter? totalColumnFilter,
    bool clearTotalColumnFilter = false,
    AmountColumnFilter? receivedColumnFilter,
    bool clearReceivedColumnFilter = false,
    AmountColumnFilter? balanceColumnFilter,
    bool clearBalanceColumnFilter = false,
    DateColumnFilter? dueDateColumnFilter,
    bool clearDueDateColumnFilter = false,
    TextColumnFilter? statusColumnFilter,
    bool clearStatusColumnFilter = false,
  }) {
    return AllTransactionsColumnFiltersState(
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
      totalColumnFilter: clearTotalColumnFilter
          ? null
          : (totalColumnFilter ?? this.totalColumnFilter),
      receivedColumnFilter: clearReceivedColumnFilter
          ? null
          : (receivedColumnFilter ?? this.receivedColumnFilter),
      balanceColumnFilter: clearBalanceColumnFilter
          ? null
          : (balanceColumnFilter ?? this.balanceColumnFilter),
      dueDateColumnFilter: clearDueDateColumnFilter
          ? null
          : (dueDateColumnFilter ?? this.dueDateColumnFilter),
      statusColumnFilter: clearStatusColumnFilter
          ? null
          : (statusColumnFilter ?? this.statusColumnFilter),
    );
  }
}

class AllTransactionsColumnFilters
    extends Notifier<AllTransactionsColumnFiltersState> {
  @override
  AllTransactionsColumnFiltersState build() =>
      const AllTransactionsColumnFiltersState();

  void reset() {
    state = const AllTransactionsColumnFiltersState();
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

  void setCategoryColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearCategoryColumnFilter: true)
        : state.copyWith(categoryColumnFilter: filter);
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

  void setReceivedColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearReceivedColumnFilter: true)
        : state.copyWith(receivedColumnFilter: filter);
  }

  void setBalanceColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearBalanceColumnFilter: true)
        : state.copyWith(balanceColumnFilter: filter);
  }

  void setDueDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDueDateColumnFilter: true)
        : state.copyWith(dueDateColumnFilter: filter);
  }

  void setStatusColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearStatusColumnFilter: true)
        : state.copyWith(statusColumnFilter: filter);
  }
}

final allTransactionsColumnFiltersProvider = NotifierProvider<
    AllTransactionsColumnFilters,
    AllTransactionsColumnFiltersState>(AllTransactionsColumnFilters.new);
