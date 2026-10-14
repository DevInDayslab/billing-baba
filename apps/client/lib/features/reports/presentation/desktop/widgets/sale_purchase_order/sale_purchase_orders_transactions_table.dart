import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/application/sale_purchase_orders_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/reports/utils/report_order_filter_utils.dart';
import 'package:billing_baba/features/reports/utils/report_transaction_table_shared.dart';
import 'package:billing_baba/features/reports/utils/sale_purchase_orders_row_filter.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _dateColWidth = 110.0;
const _orderNoColWidth = 110.0;
const _nameColWidth = 160.0;
const _dueDateColWidth = 110.0;
const _statusColWidth = 100.0;
const _typeColWidth = 110.0;
const _amountColWidth = 100.0;

class SalePurchaseOrdersTransactionsTable extends ConsumerWidget {
  const SalePurchaseOrdersTransactionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(salePurchaseOrdersReportProvider);
    final reportFilters = ref.watch(reportFiltersProvider);
    final columnFilters = ref.watch(salePurchaseOrdersColumnFiltersProvider);
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
          final toolbarFiltered = filterSalePurchaseOrderRows(
            report.rows,
            reportFilters,
          );
          final filteredRows = applySalePurchaseOrdersColumnFilters(
            toolbarFiltered,
            columnFilters,
          );
          final meta = report.meta;

          var totalAmount = 0.0;
          for (final row in filteredRows) {
            totalAmount += row.amount;
          }
          final displayTotal = totalAmount;

          final columns = _SalePurchaseOrdersTableColumns.build(
            ref: ref,
            rows: toolbarFiltered,
          );
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _SalePurchaseOrdersTableRows.buildDataRow(
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'ORDERS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              columnFilters.hasActiveFilters
                                  ? '${filteredRows.length} shown · ${toolbarFiltered.length} on page'
                                  : '${toolbarFiltered.length} on page · ${meta.total} total',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
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
                                    'No orders found for the selected period.',
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
                                    color: reportTeal,
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
                          .read(salePurchaseOrdersReportProvider.notifier)
                          .goToPage(meta.page - 1)
                    : null,
                onNext: meta.page < meta.totalPages
                    ? () => ref
                          .read(salePurchaseOrdersReportProvider.notifier)
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

class _SalePurchaseOrdersTableColumns {
  const _SalePurchaseOrdersTableColumns._();

  static List<ResizableDataColumn> build({
    required WidgetRef ref,
    required List<ReportOrderRow> rows,
  }) {
    final filters = ref.watch(salePurchaseOrdersColumnFiltersProvider);
    final filtersNotifier =
        ref.read(salePurchaseOrdersColumnFiltersProvider.notifier);
    final statusOptions = reportUniqueSortedValues([
      ...salePurchaseOrderReportStatusFilterOptions,
      ...rows.map((row) => salePurchaseOrderStatusLabel(row.status)),
    ]);
    final typeOptions = reportUniqueSortedValues([
      ...salePurchaseOrderRowTypeFilterOptions,
      ...rows.map((row) => salePurchaseOrderRowTypeLabel(row.type)),
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
        initialWidth: _orderNoColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'orderNo',
            title: 'Order no.',
            type: FilterType.text,
            hintText: 'Order number',
          ),
          initialValue: filters.orderNoColumnFilter,
          onApply: (result) => filtersNotifier.setOrderNoColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _nameColWidth,
        minWidth: 120,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'partyName',
            title: 'Name',
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
          config: ColumnFilter(
            id: 'status',
            title: 'Status',
            type: FilterType.singleSelect,
            values: statusOptions,
          ),
          initialValue: filters.statusColumnFilter != null
              ? SelectColumnFilter(value: filters.statusColumnFilter!.value)
              : null,
          onApply: (result) => filtersNotifier.setStatusColumnFilter(
            FilterUtils.fromResult(result) as SelectColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _typeColWidth,
        header: TableColumnFilterTrigger(
          config: ColumnFilter(
            id: 'type',
            title: 'Type',
            type: FilterType.singleSelect,
            values: typeOptions,
          ),
          initialValue: filters.typeColumnFilter != null
              ? SelectColumnFilter(value: filters.typeColumnFilter!.value)
              : null,
          onApply: (result) => filtersNotifier.setTypeColumnFilter(
            FilterUtils.fromResult(result) as SelectColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'total',
            title: 'Total',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.totalColumnFilter,
          onApply: (result) => filtersNotifier.setTotalColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'advance',
            title: 'Advance',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.advanceColumnFilter,
          onApply: (result) => filtersNotifier.setAdvanceColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'balance',
            title: 'Balance',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.balanceColumnFilter,
          onApply: (result) => filtersNotifier.setBalanceColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
    ];
  }
}

class _SalePurchaseOrdersTableRows {
  const _SalePurchaseOrdersTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static ResizableDataRow buildDataRow({
    required ReportOrderRow row,
    required bool isOdd,
  }) {
    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(row.date))),
        _DataCell(child: Text(row.orderNo)),
        _DataCell(
          child: Text(
            row.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(child: Text(_dateFormat.format(row.dueDate))),
        _DataCell(child: Text(salePurchaseOrderStatusLabel(row.status))),
        _DataCell(child: Text(salePurchaseOrderRowTypeLabel(row.type))),
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
            row.advance > 0 ? formatReportCurrencyCompact(row.advance) : '—',
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            row.balance > 0 ? formatReportCurrencyCompact(row.balance) : '—',
            style: const TextStyle(
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
