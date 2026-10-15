import 'package:billing_baba/features/other_income/application/other_income_service.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_list_filter_utils.dart';
import 'package:billing_baba/features/other_income/models/other_income_model.dart';
import 'package:billing_baba/features/other_income/models/mappers/other_income_mapper.dart';
import 'package:billing_baba/features/other_income/models/requests/other_income_requests.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'other_incomes_provider.g.dart';

/// One-shot success message shown on the expenses list after save.
final otherIncomeSaveSuccessMessageProvider =
    NotifierProvider<OtherIncomeSaveSuccessMessage, String?>(
      OtherIncomeSaveSuccessMessage.new,
    );

class OtherIncomeSaveSuccessMessage extends Notifier<String?> {
  @override
  String? build() => null;

  void setMessage(String? value) => state = value;
}

const otherIncomeTransactionStatusOptions = [
  'All Status',
  'Paid',
  'Pending',
  'Partial',
];

class OtherIncomeFiltersState {
  const OtherIncomeFiltersState({
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

  OtherIncomeFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    String? selectedFirm,
    String? selectedUser,
    String? selectedStatus,
    int? currentPage,
    PurchaseColumnFilterFields? columnFilters,
  }) {
    return OtherIncomeFiltersState(
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

String _otherIncomeStatusLabel(OtherIncomeStatus? status) => switch (status) {
  OtherIncomeStatus.paid => 'Paid',
  OtherIncomeStatus.partial => 'Partial',
  OtherIncomeStatus.pending => 'Pending',
  null => '',
};

List<OtherIncomeTransactionModel> _applyOtherIncomeTransactionFilters(
  List<OtherIncomeTransactionModel> items,
  OtherIncomeFiltersState filters,
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
      _otherIncomeStatusLabel(transaction.status),
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

OtherIncomeListQuery _otherIncomeListQuery(OtherIncomeFiltersState filters) {
  final range = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );
  return OtherIncomeListQuery(
    page: filters.currentPage,
    from: range != null ? PurchaseConstants.formatApiDate(range.start) : null,
    to: range != null ? PurchaseConstants.formatApiDate(range.end) : null,
  );
}

@Riverpod(keepAlive: true)
class IncomeCategories extends _$IncomeCategories {
  @override
  Future<List<IncomeCategoryModel>> build() async {
    final service = await ref.read(otherIncomeServiceProvider.future);
    return service.fetchCategories();
  }

  Future<void> refresh() async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = await ref.read(otherIncomeServiceProvider.future);
      return service.fetchCategories();
    });
  }

  Future<String?> addCategory(
    String name, {
    String categoryType = 'direct',
  }) async {
    try {
      final service = await ref.read(otherIncomeServiceProvider.future);
      await service.createCategory(
        CreateIncomeCategoryRequest(name: name, categoryType: categoryType),
      );
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<String?> updateCategory(
    String id,
    UpdateIncomeCategoryRequest request,
  ) async {
    try {
      final service = await ref.read(otherIncomeServiceProvider.future);
      await service.updateCategory(id, request);
      await refresh();
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<String?> deleteCategory(String id) async {
    try {
      final service = await ref.read(otherIncomeServiceProvider.future);
      await service.deleteCategory(id);
      await refresh();
      ref.invalidate(otherIncomeTransactionsProvider);
      ref.invalidate(incomeItemsProvider);
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }
}

@Riverpod(keepAlive: true)
class IncomeCatalogItems extends _$IncomeCatalogItems {
  @override
  Future<List<IncomeCatalogItemModel>> build() async {
    final service = await ref.read(otherIncomeServiceProvider.future);
    return service.fetchIncomeCatalogItems();
  }

  Future<void> refresh() async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = await ref.read(otherIncomeServiceProvider.future);
      return service.fetchIncomeCatalogItems();
    });
  }

  Future<IncomeCatalogItemModel?> createItem(
    CreateIncomeItemRequest request,
  ) async {
    try {
      final service = await ref.read(otherIncomeServiceProvider.future);
      final created = await service.createOtherIncomeCatalogItem(request);
      await refresh();
      ref.invalidate(incomeItemsProvider);
      return created;
    } catch (_) {
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
class OtherIncomeTransactions extends _$OtherIncomeTransactions {
  @override
  Future<List<OtherIncomeTransactionModel>> build() async {
    // Only refetch when API query inputs change. Column/status filters are
    // applied client-side in categoryOtherIncomeTransactions / itemOtherIncomeTransactions.
    ref.watch(
      otherIncomeFiltersProvider.select(
        (filters) => (
          filters.timeRangeOption,
          filters.customDateRange,
          filters.currentPage,
        ),
      ),
    );
    final filters = ref.read(otherIncomeFiltersProvider);
    final service = await ref.read(otherIncomeServiceProvider.future);
    return service.fetchOtherIncomes(query: _otherIncomeListQuery(filters));
  }

  Future<void> refresh() async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final filters = ref.read(otherIncomeFiltersProvider);
      final service = await ref.read(otherIncomeServiceProvider.future);
      return service.fetchOtherIncomes(query: _otherIncomeListQuery(filters));
    });
  }

  Future<String?> updateOtherIncome(
    String id,
    UpdateOtherIncomeRequest request,
  ) async {
    try {
      final service = await ref.read(otherIncomeServiceProvider.future);
      await service.updateOtherIncome(id, request);
      await refresh();
      ref.invalidate(incomeCategoriesProvider);
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }

  Future<String?> deleteOtherIncome(String id) async {
    try {
      final service = await ref.read(otherIncomeServiceProvider.future);
      await service.deleteOtherIncome(id);
      await refresh();
      ref.invalidate(incomeCategoriesProvider);
      return null;
    } catch (error) {
      return PurchaseErrorMapper.messageFor(error);
    }
  }
}

typedef OtherIncomePageData = ({
  List<IncomeCategoryModel> categories,
  List<OtherIncomeTransactionModel> transactions,
});

@riverpod
Future<OtherIncomePageData> otherIncomesPageData(Ref ref) async {
  final categories = await ref.watch(incomeCategoriesProvider.future);
  final transactions = await ref.watch(otherIncomeTransactionsProvider.future);
  return (categories: categories, transactions: transactions);
}

@riverpod
List<IncomeItemModel> incomeItems(Ref ref) {
  final catalogAsync = ref.watch(incomeCatalogItemsProvider);
  final transactionsAsync = ref.watch(otherIncomeTransactionsProvider);

  return catalogAsync.maybeWhen(
    data: (catalog) => OtherIncomeMapper.catalogToListItems(
      catalog,
      transactions: transactionsAsync.value ?? const [],
    ),
    orElse: () => const <IncomeItemModel>[],
  );
}

@riverpod
class OtherIncomeTabIndex extends _$OtherIncomeTabIndex {
  @override
  int build() => 0;

  int get tabIndex => state;
  set tabIndex(int index) => state = index;
}

@riverpod
class SelectedIncomeCategoryId extends _$SelectedIncomeCategoryId {
  @override
  String? build() => null;

  String? get selected => state;
  set selected(String? id) => state = id;
}

@riverpod
class SelectedIncomeItemId extends _$SelectedIncomeItemId {
  @override
  String? build() => null;

  String? get selected => state;
  set selected(String? id) => state = id;
}

@riverpod
class IncomeCategorySearchQuery extends _$IncomeCategorySearchQuery {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

@riverpod
class OtherIncomeTransactionSearchQuery extends _$OtherIncomeTransactionSearchQuery {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

@riverpod
class IncomeItemSearchQuery extends _$IncomeItemSearchQuery {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

@riverpod
class IncomeItemTransactionSearchQuery
    extends _$IncomeItemTransactionSearchQuery {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

@riverpod
class OtherIncomeFilters extends _$OtherIncomeFilters {
  @override
  OtherIncomeFiltersState build() => const OtherIncomeFiltersState();

  void setTimeRange(String label) {
    state = state.copyWith(
      timeRangeOption: TimeRangeOptionX.fromLabel(label),
      currentPage: 1,
    );
    ref.invalidate(otherIncomeTransactionsProvider);
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
    ref.read(otherIncomeTransactionSearchQueryProvider.notifier).query = '';
    ref.read(incomeItemTransactionSearchQueryProvider.notifier).query = '';
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
List<IncomeCategoryModel> filteredIncomeCategories(Ref ref) {
  final categoriesAsync = ref.watch(incomeCategoriesProvider);
  final categories = categoriesAsync.maybeWhen(
    data: (items) => items,
    orElse: () => const <IncomeCategoryModel>[],
  );
  final query = ref
      .watch(incomeCategorySearchQueryProvider)
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
List<OtherIncomeTransactionModel> categoryOtherIncomeTransactions(
  Ref ref,
  String categoryId,
) {
  final transactionsAsync = ref.watch(otherIncomeTransactionsProvider);
  final transactions =
      transactionsAsync.value ?? const <OtherIncomeTransactionModel>[];
  final filters = ref.watch(otherIncomeFiltersProvider);
  final query = ref.watch(otherIncomeTransactionSearchQueryProvider);

  final scoped = transactions
      .where((transaction) => transaction.categoryId == categoryId)
      .toList();
  return _applyOtherIncomeTransactionFilters(scoped, filters, query);
}

@riverpod
List<IncomeItemModel> filteredIncomeItems(Ref ref) {
  final items = ref.watch(incomeItemsProvider);
  final query = ref.watch(incomeItemSearchQueryProvider).trim().toLowerCase();
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
List<OtherIncomeTransactionModel> itemOtherIncomeTransactions(
  Ref ref,
  String itemId,
) {
  final transactionsAsync = ref.watch(otherIncomeTransactionsProvider);
  final transactions =
      transactionsAsync.value ?? const <OtherIncomeTransactionModel>[];
  final filters = ref.watch(otherIncomeFiltersProvider);
  final query = ref.watch(incomeItemTransactionSearchQueryProvider);

  final scoped = transactions
      .where(
        (transaction) =>
            transaction.incomeItemId == itemId || transaction.itemId == itemId,
      )
      .toList();
  return _applyOtherIncomeTransactionFilters(scoped, filters, query);
}

@riverpod
List<String> otherIncomeTransactionPartyOptions(Ref ref) {
  final transactionsAsync = ref.watch(otherIncomeTransactionsProvider);
  final transactions = transactionsAsync.maybeWhen(
    data: (items) => items,
    orElse: () => const <OtherIncomeTransactionModel>[],
  );
  final parties = transactions.map((t) => t.party).toSet().toList()..sort();
  return ['All Parties', ...parties];
}

@riverpod
double expensesTotalAmount(Ref ref) {
  final categoriesAsync = ref.watch(incomeCategoriesProvider);
  final categories = categoriesAsync.maybeWhen(
    data: (items) => items,
    orElse: () => const <IncomeCategoryModel>[],
  );
  return categories.fold<double>(0, (sum, c) => sum + c.totalAmount);
}
