import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/bill_wise_profit_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_preview_dialog.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/bill_wise_profit_export.dart';
import 'package:billing_baba/features/reports/utils/bill_wise_profit_row_filter.dart';
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

const _dateColWidth = 110.0;
const _invoiceColWidth = 120.0;
const _partyColWidth = 180.0;
const _saleAmountColWidth = 140.0;
const _profitColWidth = 140.0;
const _detailsColWidth = 80.0;

class BillWiseProfitTransactionsTable extends ConsumerWidget {
  const BillWiseProfitTransactionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(billWiseProfitReportProvider);
    final columnFilters = ref.watch(billWiseProfitColumnFiltersProvider);
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
          final filteredRows = applyBillWiseProfitColumnFilters(
            report.rows,
            columnFilters,
          );
          final meta = report.meta;

          var totalSale = 0.0;
          var totalProfit = 0.0;
          for (final row in filteredRows) {
            totalSale += row.saleAmount;
            totalProfit += row.profit;
          }

          final columns = _BillWiseProfitTableColumns.build(ref: ref);
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _BillWiseProfitTableRows.buildDataRow(
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
                      const Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Text(
                          'PROFIT ON SALE INVOICES',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'FILTERS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: ReportSearchField(
                                hintText: 'Party filter',
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
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Divider(height: 1, color: _cardBorder),
                      Expanded(
                        child: ReportTableArea(
                          child: filteredRows.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No data for selected period',
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
                      const Divider(height: 1, color: _cardBorder),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Summary',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Text(
                                  'Total Sale Amount: '
                                  '${formatReportCurrency(totalSale)}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(width: AppSpacing.xl),
                                Text(
                                  'Total Profit(+)/Loss(-): '
                                  '${formatReportCurrency(totalProfit)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: reportTeal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                          .read(billWiseProfitReportProvider.notifier)
                          .goToPage(meta.page - 1)
                    : null,
                onNext: meta.page < meta.totalPages
                    ? () => ref
                          .read(billWiseProfitReportProvider.notifier)
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

class _BillWiseProfitTableColumns {
  const _BillWiseProfitTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(billWiseProfitColumnFiltersProvider);
    final filtersNotifier = ref.read(billWiseProfitColumnFiltersProvider.notifier);

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
        initialWidth: _invoiceColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'invoiceNo',
            title: 'Invoice no',
            type: FilterType.text,
            hintText: 'Invoice number',
          ),
          initialValue: filters.invoiceNoColumnFilter,
          onApply: (result) => filtersNotifier.setInvoiceNoColumnFilter(
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
        initialWidth: _saleAmountColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'saleAmount',
            title: 'Total Sale Amount',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.saleAmountColumnFilter,
          onApply: (result) => filtersNotifier.setSaleAmountColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _profitColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'profit',
            title: 'Profit (+) / Loss (-)',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.profitColumnFilter,
          onApply: (result) => filtersNotifier.setProfitColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      const ResizableDataColumn(
        initialWidth: _detailsColWidth,
        resizable: false,
        header: _HeaderCell(label: 'Details'),
      ),
    ];
  }
}

class _BillWiseProfitTableRows {
  const _BillWiseProfitTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static ResizableDataRow buildDataRow({
    required BuildContext context,
    required ReportBillWiseProfitRow row,
    required bool isOdd,
  }) {
    final profitColor = row.profit >= 0 ? reportTeal : reportAddRed;

    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(row.date))),
        _DataCell(child: Text(row.invoiceNo)),
        _DataCell(
          child: Text(
            row.partyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrencyCompact(row.saleAmount),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrencyCompact(row.profit),
            style: TextStyle(
              color: profitColor,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          child: IconButton(
            onPressed: () => reportPrintRow(
              context: context,
              title: 'Bill ${row.invoiceNo}',
              filename: 'bill-${row.invoiceNo}',
              headers: billWiseProfitExportHeaders,
              row: billWiseProfitExportRow(row),
              meta: ReportPreviewMeta(
                party: row.partyName,
                invoiceDate: formatReportDate(row.date),
                invoiceNumber: row.invoiceNo,
              ),
            ),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            tooltip: 'Preview',
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
