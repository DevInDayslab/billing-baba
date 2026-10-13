import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/day_book_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/day_book_export.dart';
import 'package:billing_baba/features/reports/utils/day_book_row_filter.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _nameColWidth = 180.0;
const _refColWidth = 110.0;
const _typeColWidth = 120.0;
const _totalColWidth = 100.0;
const _moneyInColWidth = 110.0;
const _moneyOutColWidth = 110.0;
const _actionsColWidth = 110.0;

class DayBookTransactionsTable extends ConsumerWidget {
  const DayBookTransactionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(dayBookReportProvider);
    final columnFilters = ref.watch(dayBookColumnFiltersProvider);
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
          final filteredRows = applyDayBookColumnFilters(
            report.rows,
            columnFilters,
          );

          var totalMoneyIn = 0.0;
          var totalMoneyOut = 0.0;
          for (final row in filteredRows) {
            totalMoneyIn += row.moneyIn;
            totalMoneyOut += row.moneyOut;
          }
          final netTotal = totalMoneyIn - totalMoneyOut;

          final columns = _DayBookTableColumns.build(
            ref: ref,
            rows: report.rows,
          );
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _DayBookTableRows.buildDataRow(
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
                                  ? '${filteredRows.length} shown · ${report.rows.length} total'
                                  : '${report.rows.length} total',
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
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 180,
                              child: ReportTransactionTypeFilter(),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            const Expanded(
                              child: ReportSearchField(
                                hintText: 'Search transactions...',
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
                            label: 'Total Money-In',
                            amount: formatReportCurrency(totalMoneyIn),
                            color: reportTeal,
                          ),
                          ReportMoneySummaryItem(
                            label: 'Total Money-Out',
                            amount: formatReportCurrency(totalMoneyOut),
                            color: reportAddRed,
                          ),
                          ReportMoneySummaryItem(
                            label: 'Total Money In - Total Money Out',
                            amount: formatReportCurrency(netTotal),
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

class _DayBookTableColumns {
  const _DayBookTableColumns._();

  static List<ResizableDataColumn> build({
    required WidgetRef ref,
    required List<ReportTransactionRow> rows,
  }) {
    final filters = ref.watch(dayBookColumnFiltersProvider);
    final filtersNotifier = ref.read(dayBookColumnFiltersProvider.notifier);
    final typeOptions = _uniqueSortedValues([
      ...dayBookTypeFilterOptions,
      ...rows.map((row) => row.type),
    ]);

    return [
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
        initialWidth: _totalColWidth,
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
        initialWidth: _moneyInColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'moneyIn',
            title: 'Money In',
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
        initialWidth: _moneyOutColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'moneyOut',
            title: 'Money Out',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.moneyOutColumnFilter,
          onApply: (result) => filtersNotifier.setMoneyOutColumnFilter(
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

  static List<String> _uniqueSortedValues(Iterable<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }
}

class _DayBookTableRows {
  const _DayBookTableRows._();

  static ResizableDataRow buildDataRow({
    required BuildContext context,
    required ReportTransactionRow row,
    required bool isOdd,
  }) {
    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(
          child: Text(
            row.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(child: Text(row.refNo)),
        _DataCell(child: Text(row.type)),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(formatReportCurrencyCompact(row.total)),
        ),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => reportPrintRow(
                  context: context,
                  title: 'Day Book ${row.refNo}',
                  headers: dayBookExportHeaders,
                  row: dayBookExportRow(row),
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
