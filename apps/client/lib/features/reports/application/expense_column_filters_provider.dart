import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseColumnFiltersState {
  const ExpenseColumnFiltersState({
    this.dateColumnFilter,
    this.expenseNoColumnFilter,
    this.partyNameColumnFilter,
    this.categoryColumnFilter,
    this.paymentTypeColumnFilter,
    this.amountColumnFilter,
    this.balanceDueColumnFilter,
    this.dueDateColumnFilter,
    this.statusColumnFilter,
  });

  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? expenseNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final SelectColumnFilter? categoryColumnFilter;
  final SelectColumnFilter? paymentTypeColumnFilter;
  final AmountColumnFilter? amountColumnFilter;
  final AmountColumnFilter? balanceDueColumnFilter;
  final DateColumnFilter? dueDateColumnFilter;
  final SelectColumnFilter? statusColumnFilter;

  bool get hasActiveFilters =>
      (dateColumnFilter?.isActive ?? false) ||
      (expenseNoColumnFilter?.isActive ?? false) ||
      (partyNameColumnFilter?.isActive ?? false) ||
      (categoryColumnFilter?.isActive ?? false) ||
      (paymentTypeColumnFilter?.isActive ?? false) ||
      (amountColumnFilter?.isActive ?? false) ||
      (balanceDueColumnFilter?.isActive ?? false) ||
      (dueDateColumnFilter?.isActive ?? false) ||
      (statusColumnFilter?.isActive ?? false);

  ExpenseColumnFiltersState copyWith({
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? expenseNoColumnFilter,
    bool clearExpenseNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    SelectColumnFilter? categoryColumnFilter,
    bool clearCategoryColumnFilter = false,
    SelectColumnFilter? paymentTypeColumnFilter,
    bool clearPaymentTypeColumnFilter = false,
    AmountColumnFilter? amountColumnFilter,
    bool clearAmountColumnFilter = false,
    AmountColumnFilter? balanceDueColumnFilter,
    bool clearBalanceDueColumnFilter = false,
    DateColumnFilter? dueDateColumnFilter,
    bool clearDueDateColumnFilter = false,
    SelectColumnFilter? statusColumnFilter,
    bool clearStatusColumnFilter = false,
  }) {
    return ExpenseColumnFiltersState(
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      expenseNoColumnFilter: clearExpenseNoColumnFilter
          ? null
          : (expenseNoColumnFilter ?? this.expenseNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      categoryColumnFilter: clearCategoryColumnFilter
          ? null
          : (categoryColumnFilter ?? this.categoryColumnFilter),
      paymentTypeColumnFilter: clearPaymentTypeColumnFilter
          ? null
          : (paymentTypeColumnFilter ?? this.paymentTypeColumnFilter),
      amountColumnFilter: clearAmountColumnFilter
          ? null
          : (amountColumnFilter ?? this.amountColumnFilter),
      balanceDueColumnFilter: clearBalanceDueColumnFilter
          ? null
          : (balanceDueColumnFilter ?? this.balanceDueColumnFilter),
      dueDateColumnFilter: clearDueDateColumnFilter
          ? null
          : (dueDateColumnFilter ?? this.dueDateColumnFilter),
      statusColumnFilter: clearStatusColumnFilter
          ? null
          : (statusColumnFilter ?? this.statusColumnFilter),
    );
  }
}

class ExpenseColumnFilters extends Notifier<ExpenseColumnFiltersState> {
  @override
  ExpenseColumnFiltersState build() => const ExpenseColumnFiltersState();

  void reset() {
    state = const ExpenseColumnFiltersState();
  }

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDateColumnFilter: true)
        : state.copyWith(dateColumnFilter: filter);
  }

  void setExpenseNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearExpenseNoColumnFilter: true)
        : state.copyWith(expenseNoColumnFilter: filter);
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

  void setPaymentTypeColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPaymentTypeColumnFilter: true)
        : state.copyWith(paymentTypeColumnFilter: filter);
  }

  void setAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearAmountColumnFilter: true)
        : state.copyWith(amountColumnFilter: filter);
  }

  void setBalanceDueColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearBalanceDueColumnFilter: true)
        : state.copyWith(balanceDueColumnFilter: filter);
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
}

final expenseColumnFiltersProvider =
    NotifierProvider<ExpenseColumnFilters, ExpenseColumnFiltersState>(
      ExpenseColumnFilters.new,
    );

const expenseReportStatusFilterOptions = ['Paid', 'Partial', 'Pending'];

const expenseReportPaymentTypeFilterOptions = [
  'Cash',
  'UPI',
  'Cheque',
  'Bank Transfer',
  'Card',
];
