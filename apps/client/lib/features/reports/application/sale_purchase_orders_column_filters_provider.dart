import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalePurchaseOrdersColumnFiltersState {
  const SalePurchaseOrdersColumnFiltersState({
    this.dateColumnFilter,
    this.orderNoColumnFilter,
    this.partyNameColumnFilter,
    this.dueDateColumnFilter,
    this.statusColumnFilter,
    this.typeColumnFilter,
    this.totalColumnFilter,
    this.advanceColumnFilter,
    this.balanceColumnFilter,
  });

  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? orderNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final DateColumnFilter? dueDateColumnFilter;
  final SelectColumnFilter? statusColumnFilter;
  final SelectColumnFilter? typeColumnFilter;
  final AmountColumnFilter? totalColumnFilter;
  final AmountColumnFilter? advanceColumnFilter;
  final AmountColumnFilter? balanceColumnFilter;

  bool get hasActiveFilters =>
      (dateColumnFilter?.isActive ?? false) ||
      (orderNoColumnFilter?.isActive ?? false) ||
      (partyNameColumnFilter?.isActive ?? false) ||
      (dueDateColumnFilter?.isActive ?? false) ||
      (statusColumnFilter?.isActive ?? false) ||
      (typeColumnFilter?.isActive ?? false) ||
      (totalColumnFilter?.isActive ?? false) ||
      (advanceColumnFilter?.isActive ?? false) ||
      (balanceColumnFilter?.isActive ?? false);

  SalePurchaseOrdersColumnFiltersState copyWith({
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? orderNoColumnFilter,
    bool clearOrderNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    DateColumnFilter? dueDateColumnFilter,
    bool clearDueDateColumnFilter = false,
    SelectColumnFilter? statusColumnFilter,
    bool clearStatusColumnFilter = false,
    SelectColumnFilter? typeColumnFilter,
    bool clearTypeColumnFilter = false,
    AmountColumnFilter? totalColumnFilter,
    bool clearTotalColumnFilter = false,
    AmountColumnFilter? advanceColumnFilter,
    bool clearAdvanceColumnFilter = false,
    AmountColumnFilter? balanceColumnFilter,
    bool clearBalanceColumnFilter = false,
  }) {
    return SalePurchaseOrdersColumnFiltersState(
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      orderNoColumnFilter: clearOrderNoColumnFilter
          ? null
          : (orderNoColumnFilter ?? this.orderNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      dueDateColumnFilter: clearDueDateColumnFilter
          ? null
          : (dueDateColumnFilter ?? this.dueDateColumnFilter),
      statusColumnFilter: clearStatusColumnFilter
          ? null
          : (statusColumnFilter ?? this.statusColumnFilter),
      typeColumnFilter: clearTypeColumnFilter
          ? null
          : (typeColumnFilter ?? this.typeColumnFilter),
      totalColumnFilter: clearTotalColumnFilter
          ? null
          : (totalColumnFilter ?? this.totalColumnFilter),
      advanceColumnFilter: clearAdvanceColumnFilter
          ? null
          : (advanceColumnFilter ?? this.advanceColumnFilter),
      balanceColumnFilter: clearBalanceColumnFilter
          ? null
          : (balanceColumnFilter ?? this.balanceColumnFilter),
    );
  }
}

class SalePurchaseOrdersColumnFilters
    extends Notifier<SalePurchaseOrdersColumnFiltersState> {
  @override
  SalePurchaseOrdersColumnFiltersState build() =>
      const SalePurchaseOrdersColumnFiltersState();

  void reset() {
    state = const SalePurchaseOrdersColumnFiltersState();
  }

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDateColumnFilter: true)
        : state.copyWith(dateColumnFilter: filter);
  }

  void setOrderNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearOrderNoColumnFilter: true)
        : state.copyWith(orderNoColumnFilter: filter);
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true)
        : state.copyWith(partyNameColumnFilter: filter);
  }

  void setDueDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDueDateColumnFilter: true)
        : state.copyWith(dueDateColumnFilter: filter);
  }

  void setStatusColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearStatusColumnFilter: true)
        : state.copyWith(statusColumnFilter: filter);
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

  void setAdvanceColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearAdvanceColumnFilter: true)
        : state.copyWith(advanceColumnFilter: filter);
  }

  void setBalanceColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearBalanceColumnFilter: true)
        : state.copyWith(balanceColumnFilter: filter);
  }
}

final salePurchaseOrdersColumnFiltersProvider = NotifierProvider<
    SalePurchaseOrdersColumnFilters,
    SalePurchaseOrdersColumnFiltersState>(SalePurchaseOrdersColumnFilters.new);

const salePurchaseOrderReportStatusFilterOptions = [
  'Open',
  'Closed',
  'Partial',
  'Cancelled',
];
