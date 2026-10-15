import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/other_income/application/other_incomes_provider.dart';
import 'package:billing_baba/features/other_income/models/other_income_model.dart';
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

const _categoryNameFilterConfig = ColumnFilter(
  id: 'expense_category_name',
  title: 'Category',
  type: FilterType.text,
  hintText: 'Category name',
);

const _categoryAmountFilterConfig = ColumnFilter(
  id: 'expense_category_amount',
  title: 'Amount',
  type: FilterType.number,
);

class OtherIncomeCategoryTabContent extends ConsumerWidget {
  const OtherIncomeCategoryTabContent({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCategories = ref.watch(incomeCategoriesProvider).requireValue;
    final categories = ref.watch(filteredIncomeCategoriesProvider);
    final selectedId = ref.watch(selectedIncomeCategoryIdProvider);

    final selectedCategory = selectedId == null
        ? null
        : allCategories
              .where((category) => category.id == selectedId)
              .firstOrNull;

    return InventorySplitLayout(
      listPanel: _CategoryListPanel(
        categories: categories,
        selectedId: selectedId,
        onSearchChanged: (query) =>
            ref.read(incomeCategorySearchQueryProvider.notifier).query = query,
        onCategorySelected: (id) =>
            ref.read(selectedIncomeCategoryIdProvider.notifier).selected = id,
        onAddOtherIncome: () => context.push(AppRoutes.addOtherIncome),
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
    required this.onAddOtherIncome,
  });

  final List<IncomeCategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onAddOtherIncome;

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
                  onPressed: onAddOtherIncome,
                  style: FilledButton.styleFrom(
                    backgroundColor: _addOtherIncomeGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
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
              ),
            ],
          ),
        ),
        const _CategoryListHeader(),
        Expanded(
          child: categories.isEmpty
              ? const InventoryListEmptyState(message: 'No categories found')
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category.id == selectedId;
                    return _CategoryListRow(
                      index: index,
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

class _CategoryListHeader extends ConsumerWidget {
  const _CategoryListHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameFilter = ref.watch(expenseCategoryListNameFilterProvider);
    final amountFilter = ref.watch(expenseCategoryListAmountFilterProvider);

    return ExpenseListPanelHeader(
      leftLabel: 'CATEGORY',
      rightLabel: 'AMOUNT',
      leftFilter: TableColumnFilterTrigger(
        config: _categoryNameFilterConfig,
        iconOnly: true,
        initialValue: nameFilter,
        onApply: (result) => ref
            .read(expenseCategoryListNameFilterProvider.notifier)
            .apply(FilterUtils.fromResult(result) as TextColumnFilter?),
      ),
      rightFilter: TableColumnFilterTrigger(
        config: _categoryAmountFilterConfig,
        iconOnly: true,
        initialValue: amountFilter,
        onApply: (result) => ref
            .read(expenseCategoryListAmountFilterProvider.notifier)
            .apply(FilterUtils.fromResult(result) as AmountColumnFilter?),
      ),
    );
  }
}

class _CategoryListRow extends StatelessWidget {
  const _CategoryListRow({
    required this.index,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final int index;
  final IncomeCategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amountText =
        category.totalAmount == category.totalAmount.roundToDouble()
        ? category.totalAmount.toInt().toString()
        : category.totalAmount.toStringAsFixed(2);

    return ExpenseListPanelRow(
      index: index,
      primaryText: category.name,
      amountText: amountText,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class _CategoryDetailPanel extends ConsumerWidget {
  const _CategoryDetailPanel({required this.category});

  final IncomeCategoryModel category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(
      categoryOtherIncomeTransactionsProvider(category.id),
    );
    final filters = ref.watch(otherIncomeFiltersProvider);
    final searchQuery = ref.watch(otherIncomeTransactionSearchQueryProvider);

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
                    'Total: ${OtherIncomeCategoryTabContent._currencyFormat.format(category.totalAmount)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Balance: ${OtherIncomeCategoryTabContent._currencyFormat.format(category.balance)}',
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
                  onChanged: (query) =>
                      ref
                              .read(
                                otherIncomeTransactionSearchQueryProvider.notifier,
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
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: transactions.isEmpty
                ? InventoryListEmptyState(
                    message: category.variant.isSyncOnly
                        ? 'Transactions appear here automatically when '
                              'loyalty points are redeemed or payment-in '
                              'discounts are given'
                        : 'No transactions in this category',
                  )
                : OtherIncomeResizableTable(
                    transactions: transactions,
                    variant: category.variant,
                  ),
          ),
        ),
      ],
    );
  }
}
