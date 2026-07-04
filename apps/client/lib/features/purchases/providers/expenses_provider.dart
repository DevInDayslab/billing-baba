import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expenses_provider.g.dart';

const _loyaltyCategoryId = 'loyalty_redeemed';
const _paymentDiscountCategoryId = 'payment_in_discount';

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

List<ExpenseCategoryModel> _mockExpenseCategories() {
  return const [
    ExpenseCategoryModel(
      id: _loyaltyCategoryId,
      name: 'Loyalty Redeemed',
      type: ExpenseCategoryType.indirect,
      variant: ExpenseCategoryVariant.loyaltyRedeemed,
      totalAmount: 103,
      balance: 0,
    ),
    ExpenseCategoryModel(
      id: _paymentDiscountCategoryId,
      name: 'Payment-in Discount',
      type: ExpenseCategoryType.direct,
      variant: ExpenseCategoryVariant.standard,
      totalAmount: 69,
      balance: 0,
    ),
    ExpenseCategoryModel(
      id: 'petrol',
      name: 'Petrol',
      type: ExpenseCategoryType.direct,
      variant: ExpenseCategoryVariant.standard,
      totalAmount: 0,
      balance: 0,
    ),
    ExpenseCategoryModel(
      id: 'rent',
      name: 'Rent',
      type: ExpenseCategoryType.direct,
      variant: ExpenseCategoryVariant.standard,
      totalAmount: 0,
      balance: 0,
    ),
    ExpenseCategoryModel(
      id: 'salary',
      name: 'Salary',
      type: ExpenseCategoryType.direct,
      variant: ExpenseCategoryVariant.standard,
      totalAmount: 0,
      balance: 0,
    ),
    ExpenseCategoryModel(
      id: 'tea',
      name: 'Tea',
      type: ExpenseCategoryType.indirect,
      variant: ExpenseCategoryVariant.standard,
      totalAmount: 0,
      balance: 0,
    ),
    ExpenseCategoryModel(
      id: 'transport',
      name: 'Transport',
      type: ExpenseCategoryType.direct,
      variant: ExpenseCategoryVariant.standard,
      totalAmount: 0,
      balance: 0,
    ),
  ];
}

List<ExpenseTransactionModel> _mockExpenseTransactions() {
  return [
    ExpenseTransactionModel(
      id: 'lr-1',
      categoryId: _loyaltyCategoryId,
      date: DateTime(2026, 2, 23),
      transactionNo: '9',
      party: 'ADVWDV',
      loyaltyPoints: 1.03,
      loyaltyValue: 103,
    ),
    ExpenseTransactionModel(
      id: 'pd-1',
      categoryId: _paymentDiscountCategoryId,
      date: DateTime(2026, 3, 20),
      transactionNo: '9',
      party: 'ADVWDV',
      paymentType: 'Cash',
      amount: 59,
      balance: 0,
      dueDate: DateTime(2026, 7, 2),
      status: ExpenseStatus.partial,
    ),
    ExpenseTransactionModel(
      id: 'pd-2',
      categoryId: _paymentDiscountCategoryId,
      date: DateTime(2026, 3, 20),
      transactionNo: '8',
      party: 'PARTYAV',
      paymentType: 'Cash',
      amount: 10,
      balance: 0,
      dueDate: DateTime(2026, 7, 2),
    ),
  ];
}

List<ExpenseItemModel> _mockExpenseItems() {
  return const [
    ExpenseItemModel(
      id: 'august-month',
      name: 'august month',
      category: 'Misc',
      amount: 19800,
    ),
    ExpenseItemModel(
      id: 'crips',
      name: 'Crips',
      category: 'Misc',
      amount: 26,
    ),
  ];
}

List<ExpenseTransactionModel> _mockItemExpenseTransactions() {
  return [
    ExpenseTransactionModel(
      id: 'crips-1',
      itemId: 'crips',
      date: DateTime(2026, 2, 16, 12, 30),
      transactionNo: '',
      party: '',
      paymentType: 'Cash',
      amount: 26,
      balance: 0,
      status: ExpenseStatus.paid,
    ),
  ];
}

@riverpod
class ExpenseCategories extends _$ExpenseCategories {
  @override
  List<ExpenseCategoryModel> build() => _mockExpenseCategories();

  void addCategory(ExpenseCategoryModel category) {
    if (state.any((c) => c.id == category.id)) return;
    state = [...state, category];
  }

  void updateCategoryTotals(String categoryId, double amount, double balance) {
    state = [
      for (final category in state)
        if (category.id == categoryId)
          ExpenseCategoryModel(
            id: category.id,
            name: category.name,
            type: category.type,
            variant: category.variant,
            totalAmount: category.totalAmount + amount,
            balance: category.balance + balance,
          )
        else
          category,
    ];
  }
}

@riverpod
class ExpenseTransactions extends _$ExpenseTransactions {
  @override
  List<ExpenseTransactionModel> build() => [
    ..._mockExpenseTransactions(),
    ..._mockItemExpenseTransactions(),
  ];

  void addTransaction(ExpenseTransactionModel transaction) {
    state = [transaction, ...state];
  }
}

@riverpod
class ExpenseItems extends _$ExpenseItems {
  @override
  List<ExpenseItemModel> build() => _mockExpenseItems();

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
  String? build() => _loyaltyCategoryId;

  String? get selected => state;
  set selected(String? id) => state = id;
}

@riverpod
class SelectedExpenseItemId extends _$SelectedExpenseItemId {
  @override
  String? build() => 'crips';

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
  final categories = ref.watch(expenseCategoriesProvider);
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
  final transactions = ref.watch(expenseTransactionsProvider);
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
  final transactions = ref.watch(expenseTransactionsProvider);
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
  final categories = ref.watch(expenseCategoriesProvider);
  return categories.fold<double>(0, (sum, c) => sum + c.totalAmount);
}
