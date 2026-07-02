import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/expense_status_badge.dart';
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
    final categories = ref.watch(filteredExpenseCategoriesProvider);
    final allCategories = ref.watch(expenseCategoriesProvider);
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
        onSearchChanged: (query) =>
            ref.read(expenseCategorySearchQueryProvider.notifier).update(query),
        onCategorySelected: (id) =>
            ref.read(selectedExpenseCategoryIdProvider.notifier).select(id),
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
      child: const Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text('CATEGORY', style: InventoryStyles.listHeaderStyle),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
              ],
            ),
          ),
          Text('AMOUNT', style: InventoryStyles.listHeaderStyle),
          SizedBox(width: 28),
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
    final amountText = category.totalAmount == category.totalAmount.roundToDouble()
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
          child: InventorySearchField(
            hint: 'Search',
            onChanged: (query) => ref
                .read(expenseTransactionSearchQueryProvider.notifier)
                .update(query),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: category.variant == ExpenseCategoryVariant.loyaltyRedeemed
              ? const InventoryListHeader(
                  columns: [
                    InventoryListColumn(label: 'DATE', showFilter: true),
                    InventoryListColumn(
                      label: 'TRANSACTION NO.',
                      flex: 2,
                      showFilter: true,
                    ),
                    InventoryListColumn(label: 'PARTY', showFilter: true),
                    InventoryListColumn(
                      label: 'LOYALTY REDEEMED IN POINTS',
                      flex: 2,
                      showFilter: true,
                    ),
                    InventoryListColumn(
                      label: 'LOYALTY VALUE REDEEMED',
                      flex: 2,
                      showFilter: true,
                    ),
                  ],
                )
              : const InventoryListHeader(
                  columns: [
                    InventoryListColumn(label: 'DATE', showFilter: true),
                    InventoryListColumn(label: 'EXP NO.', showFilter: true),
                    InventoryListColumn(label: 'PARTY', showFilter: true),
                    InventoryListColumn(
                      label: 'PAYMENT TYPE',
                      showFilter: true,
                    ),
                    InventoryListColumn(label: 'AMOUNT', showFilter: true),
                    InventoryListColumn(label: 'BALANCE', showFilter: true),
                    InventoryListColumn(label: 'DUE DATE', showFilter: true),
                    InventoryListColumn(label: 'STATUS', showFilter: true),
                  ],
                ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: transactions.isEmpty
                ? const InventoryListEmptyState(
                    message: 'No transactions in this category',
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return category.variant ==
                              ExpenseCategoryVariant.loyaltyRedeemed
                          ? _LoyaltyTransactionRow(transaction: transaction)
                          : _StandardTransactionRow(transaction: transaction);
                    },
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: InventoryListRowLayout(
        flexValues: const [1, 2, 1, 2, 2],
        children: [
          Text(
            ExpensesCategoryTabContent._dateFormat.format(transaction.date),
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            transaction.transactionNo,
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            transaction.party,
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${transaction.loyaltyPoints}',
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${transaction.loyaltyValue?.toInt()}',
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StandardTransactionRow extends StatelessWidget {
  const _StandardTransactionRow({required this.transaction});

  final ExpenseTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: InventoryListRowLayout(
        flexValues: const [1, 1, 1, 1, 1, 1, 1, 1],
        children: [
          Text(
            ExpensesCategoryTabContent._dateFormat.format(transaction.date),
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            transaction.transactionNo,
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            transaction.party,
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            transaction.paymentType ?? '',
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${transaction.amount?.toInt()}',
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${transaction.balance?.toInt()}',
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            transaction.dueDate != null
                ? ExpensesCategoryTabContent._dateFormat.format(
                    transaction.dueDate!,
                  )
                : '',
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          transaction.status != null
              ? ExpenseStatusBadge(status: transaction.status!)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
