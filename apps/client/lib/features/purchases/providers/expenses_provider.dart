import 'package:billing_baba/features/purchases/application/expense_service.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expenses_provider.g.dart';

class ExpenseFiltersState {
  const ExpenseFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedFirm;
  final String selectedUser;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  ExpenseFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    String? selectedFirm,
    String? selectedUser,
    int? currentPage,
  }) {
    return ExpenseFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: customDateRange ?? this.customDateRange,
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedUser: selectedUser ?? this.selectedUser,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

DateTimeRange? _resolveTimeRange(
  TimeRangeOption option,
  DateTimeRange? custom,
) {
  final now = DateTime.now();
  final today = _startOfDay(now);

  return switch (option) {
    TimeRangeOption.allTime => null,
    TimeRangeOption.today => DateTimeRange(start: today, end: _endOfDay(today)),
    TimeRangeOption.thisWeek => DateTimeRange(
      start: today.subtract(Duration(days: today.weekday % 7)),
      end: _endOfDay(
        today.add(Duration(days: 6 - (today.weekday % 7))),
      ),
    ),
    TimeRangeOption.thisMonth => DateTimeRange(
      start: DateTime(now.year, now.month),
      end: _endOfDay(DateTime(now.year, now.month + 1, 0)),
    ),
    TimeRangeOption.thisYear => DateTimeRange(
      start: DateTime(now.year),
      end: _endOfDay(DateTime(now.year, 12, 31)),
    ),
    TimeRangeOption.custom => custom,
  };
}

@Riverpod(keepAlive: true)
class ExpenseCategories extends _$ExpenseCategories {
  @override
  Future<List<ExpenseCategoryModel>> build() async {
    ref.watch(expenseFiltersProvider);
    final service = await ref.read(expenseServiceProvider.future);
    return service.fetchCategories();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(expenseServiceProvider.future);
      return service.fetchCategories();
    });
  }

  Future<String?> addCategory(String name) async {
    try {
      final service = await ref.read(expenseServiceProvider.future);
      await service.createCategory(
        CreateExpenseCategoryRequest(name: name),
      );
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }
}

@Riverpod(keepAlive: true)
class ExpenseTransactions extends _$ExpenseTransactions {
  @override
  Future<List<ExpenseTransactionModel>> build() async {
    ref.watch(expenseFiltersProvider);
    final filters = ref.read(expenseFiltersProvider);
    final service = await ref.read(expenseServiceProvider.future);
    return service.fetchExpenses(
      query: ExpenseListQuery(
        page: filters.currentPage,
        from: _resolveTimeRange(
          filters.timeRangeOption,
          filters.customDateRange,
        )?.start.toUtc().toIso8601String(),
        to: _resolveTimeRange(
          filters.timeRangeOption,
          filters.customDateRange,
        )?.end.toUtc().toIso8601String(),
      ),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final filters = ref.read(expenseFiltersProvider);
      final service = await ref.read(expenseServiceProvider.future);
      return service.fetchExpenses(
        query: ExpenseListQuery(page: filters.currentPage),
      );
    });
  }
}

@riverpod
class ExpenseItems extends _$ExpenseItems {
  @override
  List<ExpenseItemModel> build() => const [];

  void upsertItem(ExpenseItemModel item) {
    final index = state.indexWhere((existing) => existing.id == item.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = item;
      state = updated;
    } else {
      state = [item, ...state];
    }
  }
}

@riverpod
class ExpenseTabIndex extends _$ExpenseTabIndex {
  @override
  int build() => 0;

  int get tabIndex => state;
  set tabIndex(int index) => state = index;
}

@riverpod
class SelectedExpenseCategoryId extends _$SelectedExpenseCategoryId {
  @override
  String? build() => null;

  String? get selected => state;
  set selected(String? id) => state = id;
}

@riverpod
class SelectedExpenseItemId extends _$SelectedExpenseItemId {
  @override
  String? build() => null;

  String? get selected => state;
  set selected(String? id) => state = id;
}

@riverpod
class ExpenseCategorySearchQuery extends _$ExpenseCategorySearchQuery {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

@riverpod
class ExpenseTransactionSearchQuery extends _$ExpenseTransactionSearchQuery {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

@riverpod
class ExpenseItemSearchQuery extends _$ExpenseItemSearchQuery {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

@riverpod
class ExpenseItemTransactionSearchQuery
    extends _$ExpenseItemTransactionSearchQuery {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

@riverpod
class ExpenseFilters extends _$ExpenseFilters {
  @override
  ExpenseFiltersState build() => const ExpenseFiltersState();

  void setTimeRange(String label) {
    state = state.copyWith(
      timeRangeOption: TimeRangeOptionX.fromLabel(label),
      currentPage: 1,
    );
    ref.invalidate(expenseTransactionsProvider);
  }

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
  }
}

@riverpod
List<ExpenseCategoryModel> filteredExpenseCategories(Ref ref) {
  final categoriesAsync = ref.watch(expenseCategoriesProvider);
  final categories = categoriesAsync.maybeWhen(
    data: (items) => items,
    orElse: () => const <ExpenseCategoryModel>[],
  );
  final query = ref
      .watch(expenseCategorySearchQueryProvider)
      .trim()
      .toLowerCase();

  if (query.isEmpty) return categories;
  return categories.where((c) => c.name.toLowerCase().contains(query)).toList();
}

@riverpod
List<ExpenseTransactionModel> categoryExpenseTransactions(
  Ref ref,
  String categoryId,
) {
  final transactionsAsync = ref.watch(expenseTransactionsProvider);
  final transactions = transactionsAsync.maybeWhen(
    data: (items) => items,
    orElse: () => const <ExpenseTransactionModel>[],
  );
  final query = ref
      .watch(expenseTransactionSearchQueryProvider)
      .trim()
      .toLowerCase();

  return transactions.where((t) {
    if (t.categoryId != categoryId) return false;
    if (query.isEmpty) return true;
    return t.party.toLowerCase().contains(query) ||
        t.transactionNo.toLowerCase().contains(query);
  }).toList();
}

@riverpod
List<ExpenseItemModel> filteredExpenseItems(Ref ref) {
  final items = ref.watch(expenseItemsProvider);
  final query = ref.watch(expenseItemSearchQueryProvider).trim().toLowerCase();

  if (query.isEmpty) return items;
  return items.where((item) {
    return item.name.toLowerCase().contains(query) ||
        item.category.toLowerCase().contains(query);
  }).toList();
}

@riverpod
List<ExpenseTransactionModel> itemExpenseTransactions(
  Ref ref,
  String itemId,
) {
  final transactionsAsync = ref.watch(expenseTransactionsProvider);
  final transactions = transactionsAsync.maybeWhen(
    data: (items) => items,
    orElse: () => const <ExpenseTransactionModel>[],
  );
  final query = ref
      .watch(expenseItemTransactionSearchQueryProvider)
      .trim()
      .toLowerCase();

  return transactions.where((t) {
    if (t.itemId != itemId) return false;
    if (query.isEmpty) return true;
    return t.party.toLowerCase().contains(query) ||
        t.transactionNo.toLowerCase().contains(query) ||
        (t.paymentType?.toLowerCase().contains(query) ?? false);
  }).toList();
}

@riverpod
double expensesTotalAmount(Ref ref) {
  final categoriesAsync = ref.watch(expenseCategoriesProvider);
  final categories = categoriesAsync.maybeWhen(
    data: (items) => items,
    orElse: () => const <ExpenseCategoryModel>[],
  );
  return categories.fold<double>(0, (sum, c) => sum + c.totalAmount);
}
