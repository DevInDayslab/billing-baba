import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseItemColumnFiltersState {
  const ExpenseItemColumnFiltersState({
    this.itemNameColumnFilter,
    this.categoryColumnFilter,
    this.amountColumnFilter,
  });

  final TextColumnFilter? itemNameColumnFilter;
  final TextColumnFilter? categoryColumnFilter;
  final AmountColumnFilter? amountColumnFilter;

  bool get hasActiveFilters =>
      (itemNameColumnFilter?.isActive ?? false) ||
      (categoryColumnFilter?.isActive ?? false) ||
      (amountColumnFilter?.isActive ?? false);

  ExpenseItemColumnFiltersState copyWith({
    TextColumnFilter? itemNameColumnFilter,
    bool clearItemNameColumnFilter = false,
    TextColumnFilter? categoryColumnFilter,
    bool clearCategoryColumnFilter = false,
    AmountColumnFilter? amountColumnFilter,
    bool clearAmountColumnFilter = false,
  }) {
    return ExpenseItemColumnFiltersState(
      itemNameColumnFilter: clearItemNameColumnFilter
          ? null
          : (itemNameColumnFilter ?? this.itemNameColumnFilter),
      categoryColumnFilter: clearCategoryColumnFilter
          ? null
          : (categoryColumnFilter ?? this.categoryColumnFilter),
      amountColumnFilter: clearAmountColumnFilter
          ? null
          : (amountColumnFilter ?? this.amountColumnFilter),
    );
  }
}

class ExpenseItemColumnFilters extends Notifier<ExpenseItemColumnFiltersState> {
  @override
  ExpenseItemColumnFiltersState build() => const ExpenseItemColumnFiltersState();

  void reset() {
    state = const ExpenseItemColumnFiltersState();
  }

  void setItemNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearItemNameColumnFilter: true)
        : state.copyWith(itemNameColumnFilter: filter);
  }

  void setCategoryColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearCategoryColumnFilter: true)
        : state.copyWith(categoryColumnFilter: filter);
  }

  void setAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearAmountColumnFilter: true)
        : state.copyWith(amountColumnFilter: filter);
  }
}

final expenseItemColumnFiltersProvider =
    NotifierProvider<ExpenseItemColumnFilters, ExpenseItemColumnFiltersState>(
      ExpenseItemColumnFilters.new,
    );
