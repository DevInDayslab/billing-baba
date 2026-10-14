import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/all_transactions_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/day_book_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/utils/all_transactions_export.dart';
import 'package:billing_baba/features/reports/utils/all_transactions_row_filter.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _indexColWidth = 48.0;
const _dateColWidth = 110.0;
const _refColWidth = 100.0;
const _partyColWidth = 160.0;
const _categoryColWidth = 100.0;
const _typeColWidth = 110.0;
const _totalColWidth = 96.0;
const _receivedColWidth = 100.0;
const _balanceColWidth = 96.0;
const _dueDateColWidth = 100.0;
const _statusColWidth = 88.0;
const _printColWidth = 64.0;

class AllTransactionsTransactionsTable extends ConsumerWidget {
  const AllTransactionsTransactionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(allTransactionsReportProvider);
    final columnFilters = ref.watch(allTransactionsColumnFiltersProvider);
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
          final filteredRows = applyAllTransactionsColumnFilters(
            report.rows,
            columnFilters,
          );
          final meta = report.meta;
          final rowOffset = (meta.page - 1) * meta.limit;
          final columns = _AllTransactionsTableColumns.build(
            ref: ref,
            rows: report.rows,
          );
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _AllTransactionsTableRows.buildDataRow(
                context: context,
                row: filteredRows[i],
                displayIndex: rowOffset + i + 1,
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
                                  ? '${filteredRows.length} shown · ${meta.total} total'
                                  : '${meta.total} total',
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
                                    'No transactions to display.',
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
                    ],
                  ),
                ),
              ),
              ReportPaginationBar(
                page: meta.page,
                totalPages: meta.totalPages,
                onPrevious: meta.page > 1
                    ? () => ref
                          .read(allTransactionsReportProvider.notifier)
                          .goToPage(meta.page - 1)
                    : null,
                onNext: meta.page < meta.totalPages
                    ? () => ref
                          .read(allTransactionsReportProvider.notifier)
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

class _AllTransactionsTableColumns {
  const _AllTransactionsTableColumns._();

  static List<ResizableDataColumn> build({
    required WidgetRef ref,
    required List<ReportTransactionRow> rows,
  }) {
    final filters = ref.watch(allTransactionsColumnFiltersProvider);
    final filtersNotifier =
        ref.read(allTransactionsColumnFiltersProvider.notifier);
    final typeOptions = _uniqueSortedValues([
      ...dayBookTypeFilterOptions,
      ...rows.map((row) => row.type),
    ]);

    return [
      const ResizableDataColumn(
        initialWidth: _indexColWidth,
        minWidth: _indexColWidth,
        maxWidth: _indexColWidth,
        resizable: false,
        header: _HeaderCell(label: '#'),
      ),
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
        initialWidth: _partyColWidth,
        minWidth: 120,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'partyName',
            title: 'Party Name',
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
          config: const ColumnFilter(
            id: 'category',
            title: 'Category',
            type: FilterType.text,
            hintText: 'Category',
          ),
          initialValue: filters.categoryColumnFilter,
          onApply: (result) => filtersNotifier.setCategoryColumnFilter(
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
        initialWidth: _receivedColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'received',
            title: 'Received',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.receivedColumnFilter,
          onApply: (result) => filtersNotifier.setReceivedColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _balanceColWidth,
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
      ResizableDataColumn(
        initialWidth: _dueDateColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'dueDate',
            title: 'Due Date',
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
            type: FilterType.text,
            hintText: 'Status',
          ),
          initialValue: filters.statusColumnFilter,
          onApply: (result) => filtersNotifier.setStatusColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _printColWidth,
        resizable: false,
        header: _HeaderCell(label: 'Print'),
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

class _AllTransactionsTableRows {
  const _AllTransactionsTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static ResizableDataRow buildDataRow({
    required BuildContext context,
    required ReportTransactionRow row,
    required int displayIndex,
    required bool isOdd,
  }) {
    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text('$displayIndex')),
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
            formatReportCurrencyCompact(row.total),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            row.received > 0 ? formatReportCurrencyCompact(row.received) : '',
            style: row.received > 0
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
            row.balance > 0 ? formatReportCurrencyCompact(row.balance) : '',
            style: row.balance > 0
                ? const TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.w500,
                    fontFeatures: [FontFeature.tabularFigures()],
                  )
                : null,
          ),
        ),
        _DataCell(
          child: Text(
            row.dueDate != null ? _dateFormat.format(row.dueDate!) : '',
          ),
        ),
        _DataCell(child: Text(row.status)),
        _DataCell(
          child: IconButton(
            onPressed: () => reportPrintRow(
              context: context,
              title: 'Transaction ${row.refNo}',
              headers: allTransactionsExportHeaders,
              row: allTransactionsExportRow(row, displayIndex),
            ),
            icon: const Icon(Icons.print_outlined, size: 18),
            color: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
