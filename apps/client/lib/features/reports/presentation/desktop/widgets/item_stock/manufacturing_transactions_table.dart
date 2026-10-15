import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/manufacturing_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/manufacturing_row_filter.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _indexColWidth = 48.0;
const _dateColWidth = 110.0;
const _refColWidth = 100.0;
const _itemColWidth = 200.0;
const _qtyColWidth = 100.0;
const _costColWidth = 120.0;

class ManufacturingTransactionsTable extends ConsumerWidget {
  const ManufacturingTransactionsTable({
    required this.totalQtyManufactured,
    required this.totalAmount,
    super.key,
  });

  final double totalQtyManufactured;
  final double totalAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(manufacturingReportProvider);
    final columnFilters = ref.watch(manufacturingColumnFiltersProvider);
    final isTableLoading = ref.watch(
      reportFiltersProvider.select((state) => state.isTableLoading),
    );
    final isReloading = reportIsTableReloading(reportAsync, isTableLoading);

    return ReportReloadScope(
      isReloading: isReloading,
      child: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
        data: (report) {
          final filteredRows = applyManufacturingColumnFilters(
            report.rows,
            columnFilters,
          );
          final meta = report.meta;

          final displayQty = columnFilters.hasActiveFilters
              ? filteredRows.fold<double>(0, (sum, row) => sum + row.quantity)
              : totalQtyManufactured;
          final displayAmount = columnFilters.hasActiveFilters
              ? filteredRows.fold<double>(0, (sum, row) => sum + row.cost)
              : totalAmount;

          final columns = _ManufacturingTableColumns.build(ref: ref);
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _ManufacturingTableRows.buildDataRow(
                index: (meta.page - 1) * meta.limit + i,
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
                          'MANUFACTURING REPORT',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'FILTERS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const ReportPageSizeFilter(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ReportSearchField(
                                hintText: 'Search by item name...',
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
                      const Divider(height: 1, color: _cardBorder),
                      Expanded(
                        child: ReportTableArea(
                          child: filteredRows.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No manufacturing records found for the selected period.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
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
                        child: Wrap(
                          spacing: AppSpacing.lg,
                          runSpacing: AppSpacing.sm,
                          alignment: WrapAlignment.end,
                          children: [
                            Text(
                              'Total Qty Manufactured: '
                              '${displayQty.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Total Amount: ${formatReportCurrency(displayAmount)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: reportTeal,
                              ),
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
                          .read(manufacturingReportProvider.notifier)
                          .goToPage(meta.page - 1)
                    : null,
                onNext: meta.page < meta.totalPages
                    ? () => ref
                          .read(manufacturingReportProvider.notifier)
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

class _ManufacturingTableColumns {
  const _ManufacturingTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(manufacturingColumnFiltersProvider);
    final filtersNotifier = ref.read(
      manufacturingColumnFiltersProvider.notifier,
    );

    return [
      const ResizableDataColumn(
        initialWidth: _indexColWidth,
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
            title: 'Ref no',
            type: FilterType.text,
            hintText: 'Ref no',
          ),
          initialValue: filters.refNoColumnFilter,
          onApply: (result) => filtersNotifier.setRefNoColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _itemColWidth,
        minWidth: 140,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'itemName',
            title: 'Item',
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
        initialWidth: _qtyColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'quantity',
            title: 'Qty',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.quantityColumnFilter,
          onApply: (result) => filtersNotifier.setQuantityColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _costColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'cost',
            title: 'Cost',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.costColumnFilter,
          onApply: (result) => filtersNotifier.setCostColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
    ];
  }
}

class _ManufacturingTableRows {
  const _ManufacturingTableRows._();

  static ResizableDataRow buildDataRow({
    required int index,
    required ReportManufacturingRow row,
    required bool isOdd,
  }) {
    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text('${index + 1}')),
        _DataCell(child: Text(formatReportDate(row.date))),
        _DataCell(
          child: Text(
            row.refNo,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          child: Text(
            row.itemName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            row.quantity.toStringAsFixed(2),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrencyCompact(row.cost),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

  static const _headerStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

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
        style: _headerStyle,
        overflow: TextOverflow.ellipsis,
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cellHorizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Align(alignment: alignment, child: child),
    );
  }
}
