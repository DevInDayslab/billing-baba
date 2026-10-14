import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/expense_status_badge.dart';
import 'package:billing_baba/features/reports/application/expense_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/expense_row_filter.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/reports/utils/report_transaction_table_shared.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _dateColWidth = 110.0;
const _expNoColWidth = 110.0;
const _partyColWidth = 160.0;
const _categoryColWidth = 120.0;
const _paymentColWidth = 120.0;
const _amountColWidth = 110.0;
const _balanceColWidth = 110.0;
const _dueDateColWidth = 110.0;
const _statusColWidth = 100.0;

class ExpenseTransactionsTable extends ConsumerWidget {
  const ExpenseTransactionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(expensesReportProvider);
    final columnFilters = ref.watch(expenseColumnFiltersProvider);
    final isTableLoading = ref.watch(
      reportFiltersProvider.select((filters) => filters.isTableLoading),
    );
    final isReloading = reportIsTableReloading(reportAsync, isTableLoading);

    return ReportReloadScope(
      isReloading: isReloading,
      child: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
        data: (report) {
          final filteredRows = applyExpenseColumnFilters(
            report.rows,
            columnFilters,
          );
          final meta = report.meta;

          var totalAmount = 0.0;
          for (final row in filteredRows) {
            totalAmount += row.amount;
          }
          final displayTotal = columnFilters.hasActiveFilters
              ? totalAmount
              : report.totalAmount;

          final columns = _ExpenseTableColumns.build(
            ref: ref,
            rows: report.rows,
          );
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _ExpenseTableRows.buildDataRow(
                context: context,
                row: filteredRows[i],
                isOdd: i.isOdd,
              ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
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
                              'TRANSACTIONS',
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
                                hintText: 'Search expenses...',
                                onChanged: ref
                                    .read(reportFiltersProvider.notifier)
                                    .setSearchQuery,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              columnFilters.hasActiveFilters
                                  ? '${filteredRows.length} shown · ${meta.total} total'
                                  : '${meta.total} total',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.push(AppRoutes.purchaseExpenses),
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
                          border: Border(top: BorderSide(color: _cardBorder)),
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(fontSize: 14),
                              children: [
                                const TextSpan(
                                  text: 'Total Amount: ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: formatReportCurrency(displayTotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
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
              ),
              ReportPaginationBar(
                page: meta.page,
                totalPages: meta.totalPages,
                onPrevious: meta.page > 1
                    ? () => ref
                          .read(expensesReportProvider.notifier)
                          .goToPage(meta.page - 1)
                    : null,
                onNext: meta.page < meta.totalPages
                    ? () => ref
                          .read(expensesReportProvider.notifier)
                          .goToPage(meta.page + 1)
                    : null,
              ),
            ],
          );
        },
        skipLoadingOnReload: true,
      ),
    );
  }
}

class _ExpenseTableColumns {
  const _ExpenseTableColumns._();

  static List<ResizableDataColumn> build({
    required WidgetRef ref,
    required List<ReportExpenseRow> rows,
  }) {
    final filters = ref.watch(expenseColumnFiltersProvider);
    final filtersNotifier = ref.read(expenseColumnFiltersProvider.notifier);
    final categoryOptions = reportUniqueSortedValues([
      ...rows.map((row) => row.category),
    ]);
    final paymentOptions = reportUniqueSortedValues([
      ...expenseReportPaymentTypeFilterOptions,
      ...rows.map((row) => row.paymentType ?? ''),
    ]);

    return [
      ResizableDataColumn(
        initialWidth: _dateColWidth,
        minWidth: 96,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'date',
            title: 'Date',
            type: FilterType.date,
          ),
          initialValue: filters.dateColumnFilter,
          onApply: (result) => filtersNotifier.setDateColumnFilter(
            FilterUtils.fromResult(result) as DateColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _expNoColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'expenseNo',
            title: 'Exp no.',
            type: FilterType.text,
            hintText: 'Expense number',
          ),
          initialValue: filters.expenseNoColumnFilter,
          onApply: (result) => filtersNotifier.setExpenseNoColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _partyColWidth,
        minWidth: 120,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'partyName',
            title: 'Party',
            type: FilterType.text,
            hintText: 'Party name',
          ),
          initialValue: filters.partyNameColumnFilter,
          onApply: (result) => filtersNotifier.setPartyNameColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _categoryColWidth,
        header: TableColumnFilterTrigger(
          config: ColumnFilter(
            id: 'category',
            title: 'Category',
            type: FilterType.singleSelect,
            values: categoryOptions,
          ),
          initialValue: filters.categoryColumnFilter != null
              ? SelectColumnFilter(value: filters.categoryColumnFilter!.value)
              : null,
          onApply: (result) => filtersNotifier.setCategoryColumnFilter(
            FilterUtils.fromResult(result) as SelectColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _paymentColWidth,
        header: TableColumnFilterTrigger(
          config: ColumnFilter(
            id: 'paymentType',
            title: 'Payment type',
            type: FilterType.singleSelect,
            values: paymentOptions,
          ),
          initialValue: filters.paymentTypeColumnFilter != null
              ? SelectColumnFilter(
                  value: filters.paymentTypeColumnFilter!.value,
                )
              : null,
          onApply: (result) => filtersNotifier.setPaymentTypeColumnFilter(
            FilterUtils.fromResult(result) as SelectColumnFilter?,
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
      ResizableDataColumn(
        initialWidth: _balanceColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'balanceDue',
            title: 'Balance due',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.balanceDueColumnFilter,
          onApply: (result) => filtersNotifier.setBalanceDueColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _dueDateColWidth,
        minWidth: 96,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'dueDate',
            title: 'Due date',
            type: FilterType.date,
          ),
          initialValue: filters.dueDateColumnFilter,
          onApply: (result) => filtersNotifier.setDueDateColumnFilter(
            FilterUtils.fromResult(result) as DateColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _statusColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'status',
            title: 'Status',
            type: FilterType.singleSelect,
            values: expenseReportStatusFilterOptions,
          ),
          initialValue: filters.statusColumnFilter != null
              ? SelectColumnFilter(value: filters.statusColumnFilter!.value)
              : null,
          onApply: (result) => filtersNotifier.setStatusColumnFilter(
            FilterUtils.fromResult(result) as SelectColumnFilter?,
          ),
        ),
      ),
    ];
  }
}

class _ExpenseTableRows {
  const _ExpenseTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static ExpenseStatus _purchaseStatus(ExpenseReportPaymentStatus status) {
    return switch (status) {
      ExpenseReportPaymentStatus.paid => ExpenseStatus.paid,
      ExpenseReportPaymentStatus.partial => ExpenseStatus.partial,
      ExpenseReportPaymentStatus.pending => ExpenseStatus.pending,
    };
  }

  static ResizableDataRow buildDataRow({
    required BuildContext context,
    required ReportExpenseRow row,
    required bool isOdd,
  }) {
    return ResizableDataRow(
      onTap: row.id.isEmpty
          ? null
          : () => context.push('${AppRoutes.editExpense}/${row.id}'),
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(row.date))),
        _DataCell(child: Text(row.expenseNo)),
        _DataCell(
          child: Text(
            row.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          child: Text(
            row.category,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(child: Text(row.paymentType ?? '—')),
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
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            row.balanceDue > 0
                ? formatReportCurrencyCompact(row.balanceDue)
                : '—',
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          child: Text(
            row.dueDate != null ? _dateFormat.format(row.dueDate!) : '—',
          ),
        ),
        _DataCell(
          child: ExpenseStatusBadge(
            status: _purchaseStatus(row.status),
            plain: true,
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
