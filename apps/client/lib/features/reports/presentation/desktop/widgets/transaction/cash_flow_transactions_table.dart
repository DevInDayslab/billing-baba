import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/cash_flow_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart'
    show ReportMoneySummaryFooter, ReportMoneySummaryItem;
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/cash_flow_export.dart';
import 'package:billing_baba/features/reports/utils/cash_flow_row_filter.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/reports/utils/report_transaction_table_shared.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _dateColWidth = 110.0;
const _refColWidth = 110.0;
const _nameColWidth = 160.0;
const _categoryColWidth = 100.0;
const _typeColWidth = 110.0;
const _moneyColWidth = 100.0;
const _runningColWidth = 110.0;
const _actionsColWidth = 110.0;

class CashFlowTransactionsTable extends ConsumerStatefulWidget {
  const CashFlowTransactionsTable({super.key});

  @override
  ConsumerState<CashFlowTransactionsTable> createState() =>
      _CashFlowTransactionsTableState();
}

class _CashFlowTransactionsTableState
    extends ConsumerState<CashFlowTransactionsTable> {
  bool _showZeroAmount = false;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(cashFlowReportProvider);
    final columnFilters = ref.watch(cashFlowColumnFiltersProvider);
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
          final visibleRows = report.rows.where((row) {
            if (_showZeroAmount) return true;
            return row.moneyIn > 0 || row.moneyOut > 0;
          }).toList();

          final rowsWithBalance = _attachRunningBalances(
            visibleRows,
            report.openingBalance,
          );
          final filteredRows = applyCashFlowColumnFilters(
            rowsWithBalance,
            columnFilters,
          );

          var totalCashIn = 0.0;
          var totalCashOut = 0.0;
          for (final entry in filteredRows) {
            totalCashIn += entry.transaction.moneyIn;
            totalCashOut += entry.transaction.moneyOut;
          }

          final closing = columnFilters.hasActiveFilters
              ? report.openingBalance + totalCashIn - totalCashOut
              : report.closingBalance;

          final columns = _CashFlowTableColumns.build(
            ref: ref,
            rows: visibleRows,
          );
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _CashFlowTableRows.buildDataRow(
                context: context,
                entry: filteredRows[i],
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
                              'Transactions',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              columnFilters.hasActiveFilters
                                  ? '${filteredRows.length} shown · ${visibleRows.length} total'
                                  : '${visibleRows.length} total',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: ReportSearchField(
                          hintText: 'Search transactions...',
                          onChanged: ref
                              .read(reportFiltersProvider.notifier)
                              .setSearchQuery,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _showZeroAmount,
                              onChanged: (value) => setState(
                                () => _showZeroAmount = value ?? false,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            const Text(
                              'Show zero amount transaction',
                              style: TextStyle(fontSize: 13),
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
                                    'No transactions to show',
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
                      ReportMoneySummaryFooter(
                        items: [
                          ReportMoneySummaryItem(
                            label: 'Total Cash-in',
                            amount: formatReportCurrency(
                              columnFilters.hasActiveFilters
                                  ? totalCashIn
                                  : report.totalMoneyIn,
                            ),
                            color: reportTeal,
                          ),
                          ReportMoneySummaryItem(
                            label: 'Total Cash-out',
                            amount: formatReportCurrency(
                              columnFilters.hasActiveFilters
                                  ? totalCashOut
                                  : report.totalMoneyOut,
                            ),
                            color: reportAddRed,
                          ),
                          ReportMoneySummaryItem(
                            label: 'Closing Cash-in Hand',
                            amount: formatReportCurrency(closing),
                            color: reportTeal,
                            bold: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        skipLoadingOnReload: true,
      ),
    );
  }
}

List<ReportCashFlowTableRow> _attachRunningBalances(
  List<ReportTransactionRow> rows,
  double opening,
) {
  var balance = opening;
  final result = <ReportCashFlowTableRow>[];
  for (final row in rows) {
    balance += row.moneyIn - row.moneyOut;
    result.add(
      ReportCashFlowTableRow(
        transaction: row,
        runningBalance: balance,
      ),
    );
  }
  return result;
}

class _CashFlowTableColumns {
  const _CashFlowTableColumns._();

  static List<ResizableDataColumn> build({
    required WidgetRef ref,
    required List<ReportTransactionRow> rows,
  }) {
    final filters = ref.watch(cashFlowColumnFiltersProvider);
    final filtersNotifier = ref.read(cashFlowColumnFiltersProvider.notifier);
    final typeOptions = reportUniqueSortedValues([
      ...cashFlowTypeFilterOptions,
      ...rows.map((row) => row.type),
    ]);
    final categoryOptions = reportUniqueSortedValues([
      ...cashFlowCategoryFilterOptions,
      ...rows.map((row) => row.category),
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
        initialWidth: _refColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'refNo',
            title: 'Ref no.',
            type: FilterType.text,
            hintText: 'Reference number',
          ),
          initialValue: filters.refNoColumnFilter,
          onApply: (result) => filtersNotifier.setRefNoColumnFilter(
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
        initialWidth: _moneyColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'moneyIn',
            title: 'Cash In',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.moneyInColumnFilter,
          onApply: (result) => filtersNotifier.setMoneyInColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _moneyColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'moneyOut',
            title: 'Cash Out',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.moneyOutColumnFilter,
          onApply: (result) => filtersNotifier.setMoneyOutColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _runningColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'runningBalance',
            title: 'Running Bal.',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.runningBalanceColumnFilter,
          onApply: (result) => filtersNotifier.setRunningBalanceColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _actionsColWidth,
        resizable: false,
        header: _HeaderCell(label: 'Print/ Share'),
      ),
    ];
  }
}

class _CashFlowTableRows {
  const _CashFlowTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static ResizableDataRow buildDataRow({
    required BuildContext context,
    required ReportCashFlowTableRow entry,
    required bool isOdd,
  }) {
    final row = entry.transaction;
    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(row.date))),
        _DataCell(child: Text(row.refNo)),
        _DataCell(
          child: Text(
            row.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(child: Text(row.category)),
        _DataCell(child: Text(row.type)),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            row.moneyIn > 0 ? formatReportCurrencyCompact(row.moneyIn) : '',
            style: row.moneyIn > 0
                ? const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                    fontFeatures: [FontFeature.tabularFigures()],
                  )
                : null,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            row.moneyOut > 0 ? formatReportCurrencyCompact(row.moneyOut) : '',
            style: row.moneyOut > 0
                ? const TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.w500,
                    fontFeatures: [FontFeature.tabularFigures()],
                  )
                : null,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrencyCompact(entry.runningBalance),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => reportPrintRow(
                  context: context,
                  title: 'Cash Flow ${row.refNo}',
                  headers: cashFlowExportHeaders,
                  row: cashFlowExportRow(row, entry.runningBalance),
                ),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const Tooltip(
                message: 'Share is not available yet.',
                child: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.share_outlined, size: 18),
                  color: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
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
