import 'package:billing_baba/features/purchases/application/expense_service.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_list_filter_utils.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/models/mappers/expense_mapper.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expenses_provider.g.dart';

/// One-shot success message shown on the expenses list after save.
final expenseSaveSuccessMessageProvider =
    NotifierProvider<ExpenseSaveSuccessMessage, String?>(
      ExpenseSaveSuccessMessage.new,
    );

class ExpenseSaveSuccessMessage extends Notifier<String?> {
  @override
  String? build() => null;

  void setMessage(String? value) => state = value;
}

const expenseTransactionStatusOptions = [
  'All Status',
  'Paid',
  'Pending',
  'Partial',
];

class ExpenseFiltersState {
  const ExpenseFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
    this.columnFilters = const PurchaseColumnFilterFields(),
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedFirm;
  final String selectedUser;
  final String selectedStatus;
  final int currentPage;
  final PurchaseColumnFilterFields columnFilters;

  String get timeRangeLabel => timeRangeOption.label;

  bool get hasTransactionFilters =>
      columnFilters.hasColumnFilters || selectedStatus != 'All Status';

  ExpenseFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    String? selectedFirm,
    String? selectedUser,
    String? selectedStatus,
    int? currentPage,
    PurchaseColumnFilterFields? columnFilters,
  }) {
    return ExpenseFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: customDateRange ?? this.customDateRange,
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedUser: selectedUser ?? this.selectedUser,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
      columnFilters: columnFilters ?? this.columnFilters,
    );
  }
}

String _expenseStatusLabel(ExpenseStatus? status) => switch (status) {
  ExpenseStatus.paid => 'Paid',
  ExpenseStatus.partial => 'Partial',
  ExpenseStatus.pending => 'Pending',
  null => '',
};

List<ExpenseTransactionModel> _applyExpenseTransactionFilters(
  List<ExpenseTransactionModel> items,
  ExpenseFiltersState filters,
  String globalSearch,
) {
  final columns = filters.columnFilters;

  return items.where((transaction) {
    if (!purchaseFilterMatchesGlobalSearch(globalSearch, [
      transaction.party,
      transaction.transactionNo,
      transaction.paymentType ?? '',
    ])) {
      return false;
    }

    if (columns.columnDateRange != null &&
        !purchaseFilterIsWithinDateRange(
          transaction.date,
          columns.columnDateRange!,
        )) {
      return false;
    }

    if (!purchaseFilterMatchesText(
      columns.documentNoFilter,
      transaction.transactionNo,
    )) {
      return false;
    }

    if (!purchaseFilterMatchesParty(columns.selectedParty, transaction.party)) {
      return false;
    }

    if (!purchaseFilterMatchesPaymentTypes(
      columns.selectedPaymentTypes,
      transaction.paymentType ?? '',
    )) {
      return false;
    }

    if (columns.amountFilter != null) {
      final amount = transaction.amount;
      if (amount == null ||
          !purchaseFilterMatchesNumericFilter(amount, columns.amountFilter)) {
        return false;
      }
    }

    if (columns.balanceFilter != null) {
      final balance = transaction.balance;
      if (balance == null ||
          !purchaseFilterMatchesNumericFilter(balance, columns.balanceFilter)) {
        return false;
      }
    }

    if (columns.dueDateRange != null) {
      final dueDate = transaction.dueDate;
      if (dueDate == null ||
          !purchaseFilterIsWithinDateRange(dueDate, columns.dueDateRange!)) {
        return false;
      }
    }

    if (!purchaseFilterMatchesOption(
      filters.selectedStatus,
      'All Status',
      _expenseStatusLabel(transaction.status),
    )) {
      return false;
    }

    return true;
  }).toList();
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

ExpenseListQuery _expenseListQuery(ExpenseFiltersState filters) {
  final range = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );
  return ExpenseListQuery(
    page: filters.currentPage,
    from: range != null ? PurchaseConstants.formatApiDate(range.start) : null,
    to: range != null ? PurchaseConstants.formatApiDate(range.end) : null,
  );
}

@Riverpod(keepAlive: true)
class ExpenseCategories extends _$ExpenseCategories {
  @override
  Future<List<ExpenseCategoryModel>> build() async {
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

  Future<String?> addCategory(
    String name, {
    String categoryType = 'direct',
  }) async {
    try {
      final service = await ref.read(expenseServiceProvider.future);
      await service.createCategory(
        CreateExpenseCategoryRequest(name: name, categoryType: categoryType),
      );
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<String?> updateCategory(
    String id,
    UpdateExpenseCategoryRequest request,
  ) async {
    try {
      final service = await ref.read(expenseServiceProvider.future);
      await service.updateCategory(id, request);
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<String?> deleteCategory(String id) async {
    try {
      final service = await ref.read(expenseServiceProvider.future);
      await service.deleteCategory(id);
      await refresh();
      ref.invalidate(expenseTransactionsProvider);
      ref.invalidate(expenseItemsProvider);
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
    // Only refetch when API query inputs change. Column/status filters are
    // applied client-side in categoryExpenseTransactions / itemExpenseTransactions.
    ref.watch(
      expenseFiltersProvider.select(
        (filters) => (
          filters.timeRangeOption,
          filters.customDateRange,
          filters.currentPage,
        ),
      ),
    );
    final filters = ref.read(expenseFiltersProvider);
    final service = await ref.read(expenseServiceProvider.future);
    return service.fetchExpenses(query: _expenseListQuery(filters));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final filters = ref.read(expenseFiltersProvider);
      final service = await ref.read(expenseServiceProvider.future);
      return service.fetchExpenses(query: _expenseListQuery(filters));
    });
  }

  Future<String?> updateExpense(
    String id,
    UpdateExpenseRequest request,
  ) async {
    try {
      final service = await ref.read(expenseServiceProvider.future);
      await service.updateExpense(id, request);
      await refresh();
      ref.invalidate(expenseCategoriesProvider);
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<String?> deleteExpense(String id) async {
    try {
      final service = await ref.read(expenseServiceProvider.future);
      await service.deleteExpense(id);
      await refresh();
      ref.invalidate(expenseCategoriesProvider);
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }
}

typedef ExpensePageData = ({
  List<ExpenseCategoryModel> categories,
  List<ExpenseTransactionModel> transactions,
});

@riverpod
Future<ExpensePageData> expensesPageData(Ref ref) async {
  final categories = await ref.watch(expenseCategoriesProvider.future);
  final transactions = await ref.watch(expenseTransactionsProvider.future);
  return (categories: categories, transactions: transactions);
}

@riverpod
List<ExpenseItemModel> expenseItems(Ref ref) {
  final transactionsAsync = ref.watch(expenseTransactionsProvider);
  final categoriesAsync = ref.watch(expenseCategoriesProvider);
  final categoryNames = categoriesAsync.maybeWhen(
    data: (categories) => {
      for (final category in categories) category.id: category.name,
    },
    orElse: () => const <String, String>{},
  );

  return transactionsAsync.maybeWhen(
    data: (transactions) => ExpenseMapper.groupTransactionsToItems(
      transactions,
      categoryNames: categoryNames,
    ),
    orElse: () => const <ExpenseItemModel>[],
  );
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

  void setColumnDateRange(DateTimeRange range) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(columnDateRange: range),
    );
  }

  void clearColumnDateRange() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearColumnDateRange: true),
      currentPage: 1,
    );
  }

  void setDocumentNo(String value) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(documentNoFilter: value),
    );
  }

  void setParty(String party) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(selectedParty: party),
    );
  }

  void togglePaymentType(String paymentType) {
    final updated = Set<String>.from(state.columnFilters.selectedPaymentTypes);
    if (updated.contains(paymentType)) {
      updated.remove(paymentType);
    } else {
      updated.add(paymentType);
    }
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(
        selectedPaymentTypes: updated,
      ),
    );
  }

  void clearPaymentTypes() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearPaymentTypes: true),
    );
  }

  void applyAmountFilter(PurchaseNumericFilter filter) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(amountFilter: filter),
    );
  }

  void clearAmountFilter() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearAmountFilter: true),
    );
  }

  void applyBalanceFilter(PurchaseNumericFilter filter) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(balanceFilter: filter),
    );
  }

  void clearBalanceFilter() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearBalanceFilter: true),
    );
  }

  void setDueDateRange(DateTimeRange range) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(dueDateRange: range),
    );
  }

  void clearDueDateRange() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearDueDateRange: true),
      currentPage: 1,
    );
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status);
  }

  void clearAllFilters() {
    state = state.copyWith(
      selectedStatus: 'All Status',
      columnFilters: const PurchaseColumnFilterFields(),
    );
    ref.read(expenseTransactionSearchQueryProvider.notifier).query = '';
    ref.read(expenseItemTransactionSearchQueryProvider.notifier).query = '';
  }
}

final expenseCategoryListNameFilterProvider =
    NotifierProvider<ExpenseCategoryListNameFilter, TextColumnFilter?>(
      ExpenseCategoryListNameFilter.new,
    );

final expenseCategoryListAmountFilterProvider =
    NotifierProvider<ExpenseCategoryListAmountFilter, AmountColumnFilter?>(
      ExpenseCategoryListAmountFilter.new,
    );

final expenseItemListNameFilterProvider =
    NotifierProvider<ExpenseItemListNameFilter, TextColumnFilter?>(
      ExpenseItemListNameFilter.new,
    );

final expenseItemListAmountFilterProvider =
    NotifierProvider<ExpenseItemListAmountFilter, AmountColumnFilter?>(
      ExpenseItemListAmountFilter.new,
    );

class ExpenseCategoryListNameFilter extends Notifier<TextColumnFilter?> {
  @override
  TextColumnFilter? build() => null;

  void apply(TextColumnFilter? filter) => state = filter;
}

class ExpenseCategoryListAmountFilter extends Notifier<AmountColumnFilter?> {
  @override
  AmountColumnFilter? build() => null;

  void apply(AmountColumnFilter? filter) => state = filter;
}

class ExpenseItemListNameFilter extends Notifier<TextColumnFilter?> {
  @override
  TextColumnFilter? build() => null;

  void apply(TextColumnFilter? filter) => state = filter;
}

class ExpenseItemListAmountFilter extends Notifier<AmountColumnFilter?> {
  @override
  AmountColumnFilter? build() => null;

  void apply(AmountColumnFilter? filter) => state = filter;
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
  final nameFilter = ref.watch(expenseCategoryListNameFilterProvider);
  final amountFilter = ref.watch(expenseCategoryListAmountFilterProvider);

  return categories.where((category) {
    if (query.isNotEmpty && !category.name.toLowerCase().contains(query)) {
      return false;
    }
    if (nameFilter != null &&
        nameFilter.isActive &&
        !nameFilter.matches(category.name)) {
      return false;
    }
    if (amountFilter != null &&
        amountFilter.isActive &&
        !amountFilter.matches(category.totalAmount)) {
      return false;
    }
    return true;
  }).toList();
}

@riverpod
List<ExpenseTransactionModel> categoryExpenseTransactions(
  Ref ref,
  String categoryId,
) {
  final transactionsAsync = ref.watch(expenseTransactionsProvider);
  final transactions =
      transactionsAsync.value ?? const <ExpenseTransactionModel>[];
  final filters = ref.watch(expenseFiltersProvider);
  final query = ref.watch(expenseTransactionSearchQueryProvider);

  final scoped = transactions
      .where((transaction) => transaction.categoryId == categoryId)
      .toList();
  return _applyExpenseTransactionFilters(scoped, filters, query);
}

@riverpod
List<ExpenseItemModel> filteredExpenseItems(Ref ref) {
  final items = ref.watch(expenseItemsProvider);
  final query = ref.watch(expenseItemSearchQueryProvider).trim().toLowerCase();
  final nameFilter = ref.watch(expenseItemListNameFilterProvider);
  final amountFilter = ref.watch(expenseItemListAmountFilterProvider);

  return items.where((item) {
    if (query.isNotEmpty) {
      final matchesQuery =
          item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
      if (!matchesQuery) return false;
    }
    if (nameFilter != null &&
        nameFilter.isActive &&
        !nameFilter.matches(item.name)) {
      return false;
    }
    if (amountFilter != null &&
        amountFilter.isActive &&
        !amountFilter.matches(item.amount)) {
      return false;
    }
    return true;
  }).toList();
}

@riverpod
List<ExpenseTransactionModel> itemExpenseTransactions(
  Ref ref,
  String itemId,
) {
  final transactionsAsync = ref.watch(expenseTransactionsProvider);
  final transactions =
      transactionsAsync.value ?? const <ExpenseTransactionModel>[];
  final filters = ref.watch(expenseFiltersProvider);
  final query = ref.watch(expenseItemTransactionSearchQueryProvider);

  final scoped = transactions
      .where((transaction) => transaction.itemId == itemId)
      .toList();
  return _applyExpenseTransactionFilters(scoped, filters, query);
}

@riverpod
List<String> expenseTransactionPartyOptions(Ref ref) {
  final transactionsAsync = ref.watch(expenseTransactionsProvider);
  final transactions = transactionsAsync.maybeWhen(
    data: (items) => items,
    orElse: () => const <ExpenseTransactionModel>[],
  );
  final parties = transactions.map((t) => t.party).toSet().toList()..sort();
  return ['All Parties', ...parties];
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
