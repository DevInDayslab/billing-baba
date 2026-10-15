import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/stock_summary_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/reports/utils/stock_summary_row_filter.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _indexColWidth = 48.0;
const _nameColWidth = 220.0;
const _salePriceColWidth = 120.0;
const _purchasePriceColWidth = 140.0;
const _stockQtyColWidth = 110.0;
const _stockValueColWidth = 130.0;

class StockSummaryTransactionsTable extends ConsumerWidget {
  const StockSummaryTransactionsTable({
    required this.totalStockValue,
    super.key,
  });

  final double totalStockValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(stockSummaryReportProvider);
    final columnFilters = ref.watch(stockSummaryColumnFiltersProvider);
    final filters = ref.watch(reportFiltersProvider);
    final isTableLoading = ref.watch(
      reportFiltersProvider.select((state) => state.isTableLoading),
    );
    final isReloading = reportIsTableReloading(reportAsync, isTableLoading);
    final filterNotifier = ref.read(reportFiltersProvider.notifier);

    return ReportReloadScope(
      isReloading: isReloading,
      child: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
        data: (report) {
          final filteredRows = applyStockSummaryColumnFilters(
            report.rows,
            columnFilters,
          );
          final meta = report.meta;

          final displayTotal = columnFilters.hasActiveFilters
              ? filteredRows.fold<double>(
                  0,
                  (sum, row) => sum + row.stockValue,
                )
              : totalStockValue;

          final columns = _StockSummaryTableColumns.build(ref: ref);
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _StockSummaryTableRows.buildDataRow(
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
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const ReportCategoryFilter(),
                            const ReportGodownFilter(),
                            const ReportDisabledDateFilter(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: filters.inStockOnly,
                                  onChanged: (value) => filterNotifier
                                      .setInStockOnly(value ?? false),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const Text(
                                  'Show items in stock',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            const ReportPageSizeFilter(),
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
                            Expanded(
                              child: ReportSearchField(
                                hintText: 'Search items...',
                                onChanged: filterNotifier.setSearchQuery,
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
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'No stock items to display.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'Add products with stock tracking to see them here.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
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
                                  text: 'Total Stock Value: ',
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
                          .read(stockSummaryReportProvider.notifier)
                          .goToPage(meta.page - 1)
                    : null,
                onNext: meta.page < meta.totalPages
                    ? () => ref
                          .read(stockSummaryReportProvider.notifier)
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

class _StockSummaryTableColumns {
  const _StockSummaryTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(stockSummaryColumnFiltersProvider);
    final filtersNotifier = ref.read(stockSummaryColumnFiltersProvider.notifier);

    return [
      const ResizableDataColumn(
        initialWidth: _indexColWidth,
        resizable: false,
        header: _HeaderCell(label: '#'),
      ),
      ResizableDataColumn(
        initialWidth: _nameColWidth,
        minWidth: 140,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'itemName',
            title: 'Item name',
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
        initialWidth: _salePriceColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'salePrice',
            title: 'Sale price',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.salePriceColumnFilter,
          onApply: (result) => filtersNotifier.setSalePriceColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _purchasePriceColWidth,
        minWidth: 120,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'purchasePrice',
            title: 'Purchase price',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.purchasePriceColumnFilter,
          onApply: (result) => filtersNotifier.setPurchasePriceColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _stockQtyColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'stockQty',
            title: 'Stock qty',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.stockQtyColumnFilter,
          onApply: (result) => filtersNotifier.setStockQtyColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _stockValueColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'stockValue',
            title: 'Stock value',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.stockValueColumnFilter,
          onApply: (result) => filtersNotifier.setStockValueColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
    ];
  }
}

class _StockSummaryTableRows {
  const _StockSummaryTableRows._();

  static ResizableDataRow buildDataRow({
    required int index,
    required ReportStockSummaryRow row,
    required bool isOdd,
  }) {
    final qtyText = formatQuantityValue(row.stockQty);
    final qtyColor = listQuantityColor(row.stockQty);

    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text('${index + 1}')),
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
            formatReportCurrencyCompact(row.salePrice),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrencyCompact(row.purchasePrice),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            qtyText,
            style: TextStyle(
              color: qtyColor,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrencyCompact(row.stockValue),
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
