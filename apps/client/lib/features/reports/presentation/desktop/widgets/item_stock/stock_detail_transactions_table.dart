import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_stock_utils.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/application/stock_detail_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/utils/stock_detail_row_filter.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _indexColWidth = 48.0;
const _nameColWidth = 220.0;
const _qtyColWidth = 100.0;

class StockDetailTransactionsTable extends ConsumerWidget {
  const StockDetailTransactionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(stockDetailReportProvider);
    final columnFilters = ref.watch(stockDetailColumnFiltersProvider);
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
          final filteredRows = applyStockDetailColumnFilters(
            report.rows,
            columnFilters,
          );
          final meta = report.meta;

          final columns = _StockDetailTableColumns.build(ref: ref);
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _StockDetailTableRows.buildDataRow(
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
                          'DETAILS',
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
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const ReportCategoryFilter(),
                            const ReportGodownFilter(),
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
                                hintText: 'Search items...',
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
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'No data for the selected period.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'Adjust the date range or record sales and purchases.',
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
                    ],
                  ),
                ),
              ),
              ReportPaginationBar(
                page: meta.page,
                totalPages: meta.totalPages,
                onPrevious: meta.page > 1
                    ? () => ref
                          .read(stockDetailReportProvider.notifier)
                          .goToPage(meta.page - 1)
                    : null,
                onNext: meta.page < meta.totalPages
                    ? () => ref
                          .read(stockDetailReportProvider.notifier)
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

class _StockDetailTableColumns {
  const _StockDetailTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(stockDetailColumnFiltersProvider);
    final filtersNotifier = ref.read(stockDetailColumnFiltersProvider.notifier);

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
        initialWidth: _qtyColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'opening',
            title: 'Opening',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.openingColumnFilter,
          onApply: (result) => filtersNotifier.setOpeningColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _qtyColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'in',
            title: 'In',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.inColumnFilter,
          onApply: (result) => filtersNotifier.setInColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _qtyColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'out',
            title: 'Out',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.outColumnFilter,
          onApply: (result) => filtersNotifier.setOutColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _qtyColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'closing',
            title: 'Closing',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.closingColumnFilter,
          onApply: (result) => filtersNotifier.setClosingColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
    ];
  }
}

class _StockDetailTableRows {
  const _StockDetailTableRows._();

  static ResizableDataRow buildDataRow({
    required int index,
    required ReportStockDetailRow row,
    required bool isOdd,
  }) {
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
            formatQuantityValue(row.openingQty),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatQuantityValue(row.inQty),
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatQuantityValue(row.outQty),
            style: const TextStyle(
              color: Color(0xFFC62828),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatQuantityValue(row.closingQty),
            style: TextStyle(
              color: listQuantityColor(row.closingQty),
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
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
