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

class ExpensesItemsTabContent extends ConsumerWidget {
  const ExpensesItemsTabContent({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _dateTimeFormat = DateFormat('dd/MM/yyyy, HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredExpenseItemsProvider);
    final allItems = ref.watch(expenseItemsProvider);
    final selectedId = ref.watch(selectedExpenseItemIdProvider);

    final selectedItem = selectedId == null
        ? null
        : allItems.where((item) => item.id == selectedId).firstOrNull;

    return InventorySplitLayout(
      listWidth: 340,
      listPanel: _ItemListPanel(
        items: items,
        selectedId: selectedId,
        onSearchChanged: (query) =>
            ref.read(expenseItemSearchQueryProvider.notifier).update(query),
        onItemSelected: (id) =>
            ref.read(selectedExpenseItemIdProvider.notifier).select(id),
        onAddExpense: () => context.push(AppRoutes.addExpense),
      ),
      detailPanel: selectedItem != null
          ? _ItemDetailPanel(item: selectedItem)
          : const InventoryDetailPlaceholder(
              message: 'Select an item to view transactions',
            ),
    );
  }
}

class _ItemListPanel extends StatelessWidget {
  const _ItemListPanel({
    required this.items,
    required this.selectedId,
    required this.onSearchChanged,
    required this.onItemSelected,
    required this.onAddExpense,
  });

  final List<ExpenseItemModel> items;
  final String? selectedId;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onItemSelected;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: InventorySearchField(
                  hint: 'Search',
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: onAddExpense,
                style: FilledButton.styleFrom(
                  backgroundColor: _addExpenseRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 12,
                  ),
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
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: _ItemListHeader(),
        ),
        Expanded(
          child: items.isEmpty
              ? const InventoryListEmptyState(message: 'No items found')
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.id == selectedId;
                    return _ItemListRow(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => onItemSelected(item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ItemListHeader extends StatelessWidget {
  const _ItemListHeader();

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
                Text('ITEM', style: InventoryStyles.listHeaderStyle),
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

class _ItemListRow extends StatelessWidget {
  const _ItemListRow({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final ExpenseItemModel item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                ExpensesItemsTabContent._currencyFormat.format(item.amount),
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

class _ItemDetailPanel extends ConsumerWidget {
  const _ItemDetailPanel({required this.item});

  final ExpenseItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(itemExpenseTransactionsProvider(item.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: InventorySearchField(
            hint: 'Search',
            onChanged: (query) => ref
                .read(expenseItemTransactionSearchQueryProvider.notifier)
                .update(query),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: InventoryListHeader(
            columns: [
              InventoryListColumn(label: 'DATE', showFilter: true),
              InventoryListColumn(label: 'EXP NO.', showFilter: true),
              InventoryListColumn(label: 'PARTY', showFilter: true),
              InventoryListColumn(label: 'PAYMENT TYPE', showFilter: true),
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
                    message: 'No transactions for this item',
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) => _ItemTransactionRow(
                      transaction: transactions[index],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ItemTransactionRow extends StatelessWidget {
  const _ItemTransactionRow({required this.transaction});

  final ExpenseTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: inventorySelectedRowColor,
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: InventoryListRowLayout(
        flexValues: const [1, 1, 1, 1, 1, 1, 1, 1],
        trailing: const InventoryListRowMenu(),
        children: [
          Text(
            ExpensesItemsTabContent._dateTimeFormat.format(transaction.date),
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
            transaction.amount != null
                ? '${transaction.amount!.toInt()}'
                : '',
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            transaction.balance != null
                ? '${transaction.balance!.toInt()}'
                : '',
            style: InventoryStyles.listCellStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            transaction.dueDate != null
                ? DateFormat('dd/MM/yyyy').format(transaction.dueDate!)
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
