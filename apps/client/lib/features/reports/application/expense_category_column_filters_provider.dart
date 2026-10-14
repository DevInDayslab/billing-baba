import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const expenseCategoryTypeFilterOptions = [
  'Direct Expense',
  'Indirect Expense',
];

class ExpenseCategoryColumnFiltersState {
  const ExpenseCategoryColumnFiltersState({
    this.categoryColumnFilter,
    this.categoryTypeColumnFilter,
    this.amountColumnFilter,
  });

  final TextColumnFilter? categoryColumnFilter;
  final SelectColumnFilter? categoryTypeColumnFilter;
  final AmountColumnFilter? amountColumnFilter;

  bool get hasActiveFilters =>
      (categoryColumnFilter?.isActive ?? false) ||
      (categoryTypeColumnFilter?.isActive ?? false) ||
      (amountColumnFilter?.isActive ?? false);

  ExpenseCategoryColumnFiltersState copyWith({
    TextColumnFilter? categoryColumnFilter,
    bool clearCategoryColumnFilter = false,
    SelectColumnFilter? categoryTypeColumnFilter,
    bool clearCategoryTypeColumnFilter = false,
    AmountColumnFilter? amountColumnFilter,
    bool clearAmountColumnFilter = false,
  }) {
    return ExpenseCategoryColumnFiltersState(
      categoryColumnFilter: clearCategoryColumnFilter
          ? null
          : (categoryColumnFilter ?? this.categoryColumnFilter),
      categoryTypeColumnFilter: clearCategoryTypeColumnFilter
          ? null
          : (categoryTypeColumnFilter ?? this.categoryTypeColumnFilter),
      amountColumnFilter: clearAmountColumnFilter
          ? null
          : (amountColumnFilter ?? this.amountColumnFilter),
    );
  }
}

class ExpenseCategoryColumnFilters
    extends Notifier<ExpenseCategoryColumnFiltersState> {
  @override
  ExpenseCategoryColumnFiltersState build() =>
      const ExpenseCategoryColumnFiltersState();

  void reset() {
    state = const ExpenseCategoryColumnFiltersState();
  }

  void setCategoryColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearCategoryColumnFilter: true)
        : state.copyWith(categoryColumnFilter: filter);
  }

  void setCategoryTypeColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearCategoryTypeColumnFilter: true)
        : state.copyWith(categoryTypeColumnFilter: filter);
  }

  void setAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearAmountColumnFilter: true)
        : state.copyWith(amountColumnFilter: filter);
  }
}

final expenseCategoryColumnFiltersProvider =
    NotifierProvider<ExpenseCategoryColumnFilters,
        ExpenseCategoryColumnFiltersState>(
      ExpenseCategoryColumnFilters.new,
    );
