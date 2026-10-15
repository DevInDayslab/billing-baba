import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/other_income/application/other_incomes_provider.dart';
import 'package:billing_baba/features/other_income/models/other_income_model.dart';
import 'package:billing_baba/features/other_income/presentation/desktop/widgets/add_other_income_item_dialog.dart';
import 'package:billing_baba/features/other_income/presentation/desktop/widgets/shared/other_income_list_panel_layout.dart';
import 'package:billing_baba/features/other_income/presentation/desktop/widgets/shared/other_income_transaction_resizable_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/column_filter_trigger.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_types.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _addOtherIncomeGreen = Color(0xFFD32F2F);

const _itemNameFilterConfig = ColumnFilter(
  id: 'expense_item_name',
  title: 'Item',
  type: FilterType.text,
  hintText: 'Item name',
);

const _itemAmountFilterConfig = ColumnFilter(
  id: 'expense_item_amount',
  title: 'Amount',
  type: FilterType.number,
);

class OtherIncomeItemsTabContent extends ConsumerWidget {
  const OtherIncomeItemsTabContent({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(otherIncomeTransactionsProvider).requireValue;
    final items = ref.watch(filteredIncomeItemsProvider);
    final allItems = ref.watch(incomeItemsProvider);
    final selectedId = ref.watch(selectedIncomeItemIdProvider);

    final selectedItem = selectedId == null
        ? null
        : allItems.where((item) => item.id == selectedId).firstOrNull;

    return InventorySplitLayout(
      listPanel: _ItemListPanel(
        items: items,
        selectedId: selectedId,
        onSearchChanged: (query) =>
            ref.read(incomeItemSearchQueryProvider.notifier).query = query,
        onItemSelected: (id) =>
            ref.read(selectedIncomeItemIdProvider.notifier).selected = id,
        onAddOtherIncome: () => context.push(AppRoutes.addOtherIncome),
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
    required this.onAddOtherIncome,
  });

  final List<IncomeItemModel> items;
  final String? selectedId;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onItemSelected;
  final VoidCallback onAddOtherIncome;

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
              OutlinedButton.icon(
                onPressed: () => showAddExpenseItemDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Item'),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: onAddOtherIncome,
                style: FilledButton.styleFrom(
                  backgroundColor: _addOtherIncomeGreen,
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
                  'Add Other Income',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const _ItemListHeader(),
        Expanded(
          child: items.isEmpty
              ? const InventoryListEmptyState(message: 'No items found')
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.id == selectedId;
                    return _ItemListRow(
                      index: index,
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

class _ItemListHeader extends ConsumerWidget {
  const _ItemListHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameFilter = ref.watch(expenseItemListNameFilterProvider);
    final amountFilter = ref.watch(expenseItemListAmountFilterProvider);

    return ExpenseListPanelHeader(
      leftLabel: 'ITEM',
      rightLabel: 'AMOUNT',
      leftFilter: TableColumnFilterTrigger(
        config: _itemNameFilterConfig,
        iconOnly: true,
        initialValue: nameFilter,
        onApply: (result) => ref
            .read(expenseItemListNameFilterProvider.notifier)
            .apply(FilterUtils.fromResult(result) as TextColumnFilter?),
      ),
      rightFilter: TableColumnFilterTrigger(
        config: _itemAmountFilterConfig,
        iconOnly: true,
        initialValue: amountFilter,
        onApply: (result) => ref
            .read(expenseItemListAmountFilterProvider.notifier)
            .apply(FilterUtils.fromResult(result) as AmountColumnFilter?),
      ),
    );
  }
}

class _ItemListRow extends StatelessWidget {
  const _ItemListRow({
    required this.index,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final int index;
  final IncomeItemModel item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ExpenseListPanelRow(
      index: index,
      primaryText: item.name,
      amountText: OtherIncomeItemsTabContent._currencyFormat.format(item.amount),
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class _ItemDetailPanel extends ConsumerWidget {
  const _ItemDetailPanel({required this.item});

  final IncomeItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(itemOtherIncomeTransactionsProvider(item.id));
    final filters = ref.watch(otherIncomeFiltersProvider);
    final searchQuery = ref.watch(incomeItemTransactionSearchQueryProvider);

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
                  onChanged: (query) =>
                      ref
                              .read(
                                incomeItemTransactionSearchQueryProvider
                                    .notifier,
                              )
                              .query =
                          query,
                ),
              ),
              if (filters.hasTransactionFilters ||
                  searchQuery.trim().isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: ref
                      .read(otherIncomeFiltersProvider.notifier)
                      .clearAllFilters,
                  child: const Text('Clear Filters'),
                ),
              ],
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
                : OtherIncomeResizableTable(
                    transactions: transactions,
                    variant: transactions.first.categoryVariant,
                  ),
          ),
        ),
      ],
    );
  }
}
