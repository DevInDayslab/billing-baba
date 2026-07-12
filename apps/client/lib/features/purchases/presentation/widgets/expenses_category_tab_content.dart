import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/filter_icon.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/expense_status_badge.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/shared/purchase_transaction_table_layout.dart';
import 'package:billing_baba/features/purchases/providers/expenses_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _addExpenseRed = Color(0xFFD32F2F);

class ExpensesCategoryTabContent extends ConsumerWidget {
  const ExpensesCategoryTabContent({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCategories = ref.watch(expenseCategoriesProvider).requireValue;
    final categories = ref.watch(filteredExpenseCategoriesProvider);
    final selectedId = ref.watch(selectedExpenseCategoryIdProvider);

    final selectedCategory = selectedId == null
        ? null
        : allCategories
              .where((category) => category.id == selectedId)
              .firstOrNull;

    return InventorySplitLayout(
      listWidth: 340,
      listPanel: _CategoryListPanel(
        categories: categories,
        selectedId: selectedId,
        onSearchChanged: (query) => ref
            .read(expenseCategorySearchQueryProvider.notifier)
            .query = query,
        onCategorySelected: (id) => ref
            .read(selectedExpenseCategoryIdProvider.notifier)
            .selected = id,
        onAddExpense: () => context.push(AppRoutes.addExpense),
      ),
      detailPanel: selectedCategory != null
          ? _CategoryDetailPanel(category: selectedCategory)
          : const InventoryDetailPlaceholder(
              message: 'Select a category to view transactions',
            ),
    );
  }
}

class _CategoryListPanel extends StatelessWidget {
  const _CategoryListPanel({
    required this.categories,
    required this.selectedId,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.onAddExpense,
  });

  final List<ExpenseCategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              InventorySearchField(
                hint: 'Search',
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: inventoryButtonHeight,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAddExpense,
                  style: FilledButton.styleFrom(
                    backgroundColor: _addExpenseRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Add Expense',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: _CategoryListHeader(),
        ),
        Expanded(
          child: categories.isEmpty
              ? const InventoryListEmptyState(message: 'No categories found')
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category.id == selectedId;
                    return _CategoryListRow(
                      category: category,
                      isSelected: isSelected,
                      onTap: () => onCategorySelected(category.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryListHeader extends StatelessWidget {
  const _CategoryListHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Text('CATEGORY', style: InventoryStyles.listHeaderStyle),
                const SizedBox(width: 4),
                AppFilterIcon(color: Colors.grey.shade500, size: 16),
              ],
            ),
          ),
          Row(
            children: [
              const Text('AMOUNT', style: InventoryStyles.listHeaderStyle),
              const SizedBox(width: 4),
              AppFilterIcon(color: Colors.grey.shade500, size: 16),
            ],
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

class _CategoryListRow extends StatelessWidget {
  const _CategoryListRow({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final ExpenseCategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amountText =
        category.totalAmount == category.totalAmount.roundToDouble()
        ? category.totalAmount.toInt().toString()
        : category.totalAmount.toStringAsFixed(2);

    return Material(
      color: isSelected ? inventorySelectedRowColor : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: inventoryCardBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                amountText,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              const InventoryListRowMenu(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryDetailPanel extends ConsumerWidget {
  const _CategoryDetailPanel({required this.category});

  final ExpenseCategoryModel category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(
      categoryExpenseTransactionsProvider(category.id),
    );
    final filters = ref.watch(expenseFiltersProvider);
    final searchQuery = ref.watch(expenseTransactionSearchQueryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name.toUpperCase(),
                      style: InventoryStyles.panelTitleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.typeLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total: ${ExpensesCategoryTabContent._currencyFormat.format(category.totalAmount)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Balance: ${ExpensesCategoryTabContent._currencyFormat.format(category.balance)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: InventorySearchField(
                  hint: 'Search',
                  onChanged: (query) => ref
                      .read(expenseTransactionSearchQueryProvider.notifier)
                      .query = query,
                ),
              ),
              if (filters.hasTransactionFilters ||
                  searchQuery.trim().isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: ref
                      .read(expenseFiltersProvider.notifier)
                      .clearAllFilters,
                  child: const Text('Clear Filters'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: transactions.isEmpty
                ? const InventoryListEmptyState(
                    message: 'No transactions in this category',
                  )
                : ExpenseTransactionTableViewport(
                    minWidth: category.variant ==
                            ExpenseCategoryVariant.loyaltyRedeemed
                        ? expenseTransactionLoyaltyMinTableWidth
                        : expenseTransactionStandardMinTableWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        category.variant ==
                                ExpenseCategoryVariant.loyaltyRedeemed
                            ? const ExpenseLoyaltyTransactionFilterHeader()
                            : const ExpenseStandardTransactionFilterHeader(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              return category.variant ==
                                      ExpenseCategoryVariant.loyaltyRedeemed
                                  ? _LoyaltyTransactionRow(
                                      transaction: transaction,
                                    )
                                  : _StandardTransactionRow(
                                      transaction: transaction,
                                    );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _LoyaltyTransactionRow extends StatelessWidget {
  const _LoyaltyTransactionRow({required this.transaction});

  final ExpenseTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return PurchaseTransactionTableDataRow(
      onTap: () => context.push(
        '${AppRoutes.editExpense}/${transaction.id}',
      ),
      children: [
        PurchaseTransactionTableCell(
          width: expenseTransactionDateColWidth,
          child: Text(
            ExpensesCategoryTabContent._dateFormat.format(transaction.date),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionInvoiceColWidth,
          child: Text(
            transaction.transactionNo,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: expenseTransactionPartyColFlex,
          child: PurchaseTransactionTableCell(
            child: Text(
              transaction.party,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionAmountColWidth,
          child: Text(
            '${transaction.loyaltyPoints}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionAmountColWidth,
          showDivider: false,
          child: Text(
            '${transaction.loyaltyValue?.toInt()}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StandardTransactionRow extends StatelessWidget {
  const _StandardTransactionRow({required this.transaction});

  final ExpenseTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return PurchaseTransactionTableDataRow(
      onTap: () => context.push(
        '${AppRoutes.editExpense}/${transaction.id}',
      ),
      children: [
        PurchaseTransactionTableCell(
          width: expenseTransactionDateColWidth,
          child: Text(
            ExpensesCategoryTabContent._dateFormat.format(transaction.date),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionInvoiceColWidth,
          child: Text(
            transaction.transactionNo,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: expenseTransactionPartyColFlex,
          child: PurchaseTransactionTableCell(
            child: Text(
              transaction.party,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionPaymentColWidth,
          child: Text(
            transaction.paymentType ?? '',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            '${transaction.amount?.toInt()}',
            style: purchaseTransactionAmountTextStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionBalanceColWidth,
          alignment: Alignment.centerRight,
          child: Text(
            '${transaction.balance?.toInt()}',
            style: purchaseTransactionAmountTextStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionDueDateColWidth,
          child: Text(
            transaction.dueDate != null
                ? ExpensesCategoryTabContent._dateFormat.format(
                    transaction.dueDate!,
                  )
                : '',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionStatusColWidth,
          showDivider: false,
          child: transaction.status != null
              ? ExpenseStatusBadge(status: transaction.status!)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

PurchaseColumnFilterActions _expenseTransactionFilterActions(
  ExpenseFilters notifier,
) {
  return PurchaseColumnFilterActions(
    onDateRange: notifier.setColumnDateRange,
    onDueDateRange: notifier.setDueDateRange,
    onClearDateRange: notifier.clearColumnDateRange,
    onClearDueDateRange: notifier.clearDueDateRange,
    onDocumentNo: notifier.setDocumentNo,
    onParty: notifier.setParty,
    onTogglePaymentType: notifier.togglePaymentType,
    onClearPaymentTypes: notifier.clearPaymentTypes,
    onApplyAmountFilter: notifier.applyAmountFilter,
    onClearAmountFilter: notifier.clearAmountFilter,
    onApplyBalanceFilter: notifier.applyBalanceFilter,
    onClearBalanceFilter: notifier.clearBalanceFilter,
    onStatus: notifier.setStatus,
  );
}

class ExpenseStandardTransactionFilterHeader extends ConsumerWidget {
  const ExpenseStandardTransactionFilterHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(expenseFiltersProvider);
    final columns = filters.columnFilters;
    final notifier = ref.read(expenseFiltersProvider.notifier);
    final partyOptions = ref.watch(expenseTransactionPartyOptionsProvider);
    final actions = _expenseTransactionFilterActions(notifier);

    return PurchaseTransactionTableHeaderRow(
      children: [
        PurchaseTransactionTableCell(
          width: expenseTransactionDateColWidth,
          child: purchaseColumnFilterCell(
            label: 'DATE',
            kind: PurchaseColumnFilterKind.date,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.date,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: expenseTransactionStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionInvoiceColWidth,
          child: purchaseColumnFilterCell(
            label: 'EXP NO.',
            kind: PurchaseColumnFilterKind.documentNo,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.documentNo,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: expenseTransactionStatusOptions,
            selectedStatus: filters.selectedStatus,
            documentNoHint: 'Search exp no',
          ),
        ),
        Expanded(
          flex: expenseTransactionPartyColFlex,
          child: PurchaseTransactionTableCell(
            child: purchaseColumnFilterCell(
              label: 'PARTY',
              kind: PurchaseColumnFilterKind.partyName,
              headerStyle: purchaseTransactionTableHeaderStyle,
              isActive: purchaseColumnFilterIsActive(
                PurchaseColumnFilterKind.partyName,
                columns,
              ),
              columns: columns,
              actions: actions,
              partyOptions: partyOptions,
              statusOptions: expenseTransactionStatusOptions,
              selectedStatus: filters.selectedStatus,
            ),
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionPaymentColWidth,
          child: purchaseColumnFilterCell(
            label: 'PAYMENT TYPE',
            kind: PurchaseColumnFilterKind.paymentType,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.paymentType,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: expenseTransactionStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionAmountColWidth,
          alignment: Alignment.centerRight,
          child: purchaseColumnFilterCell(
            label: 'AMOUNT',
            kind: PurchaseColumnFilterKind.amount,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.amount,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: expenseTransactionStatusOptions,
            selectedStatus: filters.selectedStatus,
            alignment: Alignment.centerRight,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionBalanceColWidth,
          alignment: Alignment.centerRight,
          child: purchaseColumnFilterCell(
            label: 'BALANCE',
            kind: PurchaseColumnFilterKind.balanceDue,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.balanceDue,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: expenseTransactionStatusOptions,
            selectedStatus: filters.selectedStatus,
            alignment: Alignment.centerRight,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionDueDateColWidth,
          child: purchaseColumnFilterCell(
            label: 'DUE DATE',
            kind: PurchaseColumnFilterKind.dueDate,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.dueDate,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: expenseTransactionStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionStatusColWidth,
          showDivider: false,
          child: purchaseColumnFilterCell(
            label: 'STATUS',
            kind: PurchaseColumnFilterKind.status,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnStatusFilterIsActive(filters.selectedStatus),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: expenseTransactionStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
      ],
    );
  }
}

class ExpenseLoyaltyTransactionFilterHeader extends ConsumerWidget {
  const ExpenseLoyaltyTransactionFilterHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(expenseFiltersProvider);
    final columns = filters.columnFilters;
    final notifier = ref.read(expenseFiltersProvider.notifier);
    final partyOptions = ref.watch(expenseTransactionPartyOptionsProvider);
    final actions = _expenseTransactionFilterActions(notifier);

    return PurchaseTransactionTableHeaderRow(
      children: [
        PurchaseTransactionTableCell(
          width: expenseTransactionDateColWidth,
          child: purchaseColumnFilterCell(
            label: 'DATE',
            kind: PurchaseColumnFilterKind.date,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.date,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: expenseTransactionStatusOptions,
            selectedStatus: filters.selectedStatus,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionInvoiceColWidth,
          child: purchaseColumnFilterCell(
            label: 'TRANSACTION NO.',
            kind: PurchaseColumnFilterKind.documentNo,
            headerStyle: purchaseTransactionTableHeaderStyle,
            isActive: purchaseColumnFilterIsActive(
              PurchaseColumnFilterKind.documentNo,
              columns,
            ),
            columns: columns,
            actions: actions,
            partyOptions: partyOptions,
            statusOptions: expenseTransactionStatusOptions,
            selectedStatus: filters.selectedStatus,
            documentNoHint: 'Search transaction no',
          ),
        ),
        Expanded(
          flex: expenseTransactionPartyColFlex,
          child: PurchaseTransactionTableCell(
            child: purchaseColumnFilterCell(
              label: 'PARTY',
              kind: PurchaseColumnFilterKind.partyName,
              headerStyle: purchaseTransactionTableHeaderStyle,
              isActive: purchaseColumnFilterIsActive(
                PurchaseColumnFilterKind.partyName,
                columns,
              ),
              columns: columns,
              actions: actions,
              partyOptions: partyOptions,
              statusOptions: expenseTransactionStatusOptions,
              selectedStatus: filters.selectedStatus,
            ),
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionAmountColWidth,
          child: Text(
            'LOYALTY REDEEMED IN POINTS',
            style: purchaseTransactionTableHeaderStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PurchaseTransactionTableCell(
          width: expenseTransactionAmountColWidth,
          showDivider: false,
          child: Text(
            'LOYALTY VALUE REDEEMED',
            style: purchaseTransactionTableHeaderStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
