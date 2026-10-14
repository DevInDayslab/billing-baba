import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/expense_item_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/expense_item_row_filter.dart';
import 'package:billing_baba/features/reports/utils/expense_report_navigation.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _itemColWidth = 220.0;
const _categoryColWidth = 180.0;
const _amountColWidth = 140.0;

class ExpenseItemTransactionsTable extends ConsumerWidget {
  const ExpenseItemTransactionsTable({
    required this.rows,
    required this.totalAmount,
    super.key,
  });

  final List<ReportExpenseItemRow> rows;
  final double totalAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columnFilters = ref.watch(expenseItemColumnFiltersProvider);
    final searchQuery = ref.watch(
      reportFiltersProvider.select((filters) => filters.searchQuery),
    );
    final filteredRows = applyExpenseItemColumnFilters(
      rows,
      columnFilters,
      searchQuery,
    );

    final displayTotal = columnFilters.hasActiveFilters ||
            searchQuery.trim().isNotEmpty
        ? filteredRows.fold<double>(0, (sum, row) => sum + row.amount)
        : totalAmount;

    final columns = _ExpenseItemTableColumns.build(ref: ref);
    final tableRows = [
      for (var i = 0; i < filteredRows.length; i++)
        _ExpenseItemTableRows.buildDataRow(
          ref: ref,
          row: filteredRows[i],
          isOdd: i.isOdd,
        ),
    ];

    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Text(
                    'EXPENSE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: ReportSearchField(
                      hintText: 'Search items...',
                      onChanged: ref
                          .read(reportFiltersProvider.notifier)
                          .setSearchQuery,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    columnFilters.hasActiveFilters ||
                            searchQuery.trim().isNotEmpty
                        ? '${filteredRows.length} shown · ${rows.length} total'
                        : '${rows.length} total',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.purchaseExpenses),
                    style: FilledButton.styleFrom(
                      backgroundColor: reportActiveBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Add Expense',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _cardBorder),
            Expanded(
              child: ReportTableArea(
                child: filteredRows.isEmpty
                    ? const Center(
                        child: Text(
                          'No expense records found for the selected period.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: ResizableDataTable(
                          columns: columns,
                          rows: tableRows,
                        ),
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: reportCardBorder)),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 14),
                    children: [
                      const TextSpan(
                        text: 'Total Expense: ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextSpan(
                        text: formatReportCurrency(displayTotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: reportAddRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseItemTableColumns {
  const _ExpenseItemTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(expenseItemColumnFiltersProvider);
    final filtersNotifier = ref.read(expenseItemColumnFiltersProvider.notifier);

    return [
      ResizableDataColumn(
        initialWidth: _itemColWidth,
        minWidth: 140,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'expenseItem',
            title: 'Expense item',
            type: FilterType.text,
            hintText: 'Item name',
          ),
          initialValue: filters.itemNameColumnFilter,
          onApply: (result) => filtersNotifier.setItemNameColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _categoryColWidth,
        minWidth: 120,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'expenseCategory',
            title: 'Expense category',
            type: FilterType.text,
            hintText: 'Category name',
          ),
          initialValue: filters.categoryColumnFilter,
          onApply: (result) => filtersNotifier.setCategoryColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'amount',
            title: 'Amount',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.amountColumnFilter,
          onApply: (result) => filtersNotifier.setAmountColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
    ];
  }
}

class _ExpenseItemTableRows {
  const _ExpenseItemTableRows._();

  static ResizableDataRow buildDataRow({
    required WidgetRef ref,
    required ReportExpenseItemRow row,
    required bool isOdd,
  }) {
    return ResizableDataRow(
      onTap: () => openExpenseReportForItem(
        ref,
        itemName: row.itemName,
        categoryId: row.categoryId,
        categoryName: row.category.isNotEmpty ? row.category : null,
      ),
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(
          child: Text(
            row.itemName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              color: reportActiveBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _DataCell(
          child: Text(
            row.category,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrencyCompact(row.amount),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.child,
    this.alignment = Alignment.centerLeft,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _cellHorizontalPadding,
          vertical: AppSpacing.sm,
        ),
        child: Align(alignment: alignment, child: child),
      ),
    );
  }
}
