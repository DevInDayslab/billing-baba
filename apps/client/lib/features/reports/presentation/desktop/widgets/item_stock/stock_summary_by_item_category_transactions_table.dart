import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/application/stock_summary_by_item_category_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/reports/utils/stock_summary_by_item_category_row_filter.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _indexColWidth = 48.0;
const _categoryColWidth = 220.0;
const _saleColWidth = 130.0;
const _stockValueColWidth = 130.0;

class StockSummaryByItemCategoryTransactionsTable extends ConsumerWidget {
  const StockSummaryByItemCategoryTransactionsTable({
    required this.includeZeroStock,
    required this.lowStockOnly,
    super.key,
  });

  final bool includeZeroStock;
  final bool lowStockOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(stockSummaryByItemCategoryReportProvider);
    final columnFilters = ref.watch(
      stockSummaryByItemCategoryColumnFiltersProvider,
    );
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
          final sourceRows = _sourceRows(
            report: report,
            includeZeroStock: includeZeroStock,
            lowStockOnly: lowStockOnly,
            inventoryCategories: ref.watch(categoriesProvider),
          );

          final filteredRows = applyStockSummaryByItemCategoryColumnFilters(
            sourceRows,
            columnFilters,
          );

          var totalStockValue = 0.0;
          var totalSaleValue = 0.0;
          for (final row in filteredRows) {
            totalStockValue += row.purchaseAmount;
            totalSaleValue += row.saleAmount;
          }

          final columns = _StockSummaryByItemCategoryTableColumns.build(
            ref: ref,
          );
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _StockSummaryByItemCategoryTableRows.buildDataRow(
                index: i,
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
                          'STOCK SUMMARY REPORT BY ITEM CATEGORY',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _SummaryChip(
                              label: 'Categories',
                              value: '${filteredRows.length}',
                              icon: Icons.category_outlined,
                            ),
                            _SummaryChip(
                              label: 'Stock Value',
                              value: formatReportCurrency(totalStockValue),
                              icon: Icons.payments_outlined,
                              highlight: true,
                            ),
                            _SummaryChip(
                              label: 'Sale Value',
                              value: formatReportCurrency(totalSaleValue),
                              icon: Icons.trending_up_outlined,
                            ),
                            const ReportCategoryFilter(),
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
                                hintText: 'Search category...',
                                onChanged: ref
                                    .read(reportFiltersProvider.notifier)
                                    .setSearchQuery,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              columnFilters.hasActiveFilters
                                  ? '${filteredRows.length} shown · ${sourceRows.length} total'
                                  : '${sourceRows.length} total',
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
                                    'No stock data found for the selected filters.',
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
                              'Grand Total Stock Value: '
                              '${formatReportCurrency(totalStockValue)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Grand Total Sale Value: '
                              '${formatReportCurrency(totalSaleValue)}',
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
            ],
          );
        },
        skipLoadingOnReload: true,
      ),
    );
  }

  static List<ReportCategoryAmountRow> _sourceRows({
    required CategoryAmountReportData report,
    required bool includeZeroStock,
    required bool lowStockOnly,
    required List<InventoryCategory> inventoryCategories,
  }) {
    final rows = List<ReportCategoryAmountRow>.from(report.rows);
    final lowStockNames = report.lowStockCategoryNames;

    if (includeZeroStock) {
      final byName = {for (final row in rows) row.category: row};
      for (final category in inventoryCategories) {
        byName.putIfAbsent(
          category.name,
          () => ReportCategoryAmountRow(
            category: category.name,
            saleAmount: 0,
            purchaseAmount: 0,
          ),
        );
      }
      byName.putIfAbsent(
        'Uncategorized',
        () => const ReportCategoryAmountRow(
          category: 'Uncategorized',
          saleAmount: 0,
          purchaseAmount: 0,
        ),
      );
      rows
        ..clear()
        ..addAll(byName.values);
      rows.sort(
        (a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()),
      );
    }

    if (lowStockOnly) {
      return rows
          .where((row) => lowStockNames.contains(row.category))
          .toList();
    }

    return rows;
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? reportTeal.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: highlight
              ? reportTeal.withValues(alpha: 0.35)
              : _cardBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: highlight ? reportTeal : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: highlight ? reportTeal : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockSummaryByItemCategoryTableColumns {
  const _StockSummaryByItemCategoryTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(
      stockSummaryByItemCategoryColumnFiltersProvider,
    );
    final filtersNotifier = ref.read(
      stockSummaryByItemCategoryColumnFiltersProvider.notifier,
    );

    return [
      const ResizableDataColumn(
        initialWidth: _indexColWidth,
        resizable: false,
        header: _HeaderCell(label: '#'),
      ),
      ResizableDataColumn(
        initialWidth: _categoryColWidth,
        minWidth: 140,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'category',
            title: 'Category',
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
        initialWidth: _saleColWidth,
        header: TableColumnFilterTrigger(
          alignment: Alignment.centerRight,
          config: const ColumnFilter(
            id: 'saleAmount',
            title: 'Sale',
            type: FilterType.number,
          ),
          initialValue: filters.saleAmountColumnFilter,
          onApply: (result) => filtersNotifier.setSaleAmountColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _stockValueColWidth,
        header: TableColumnFilterTrigger(
          alignment: Alignment.centerRight,
          config: const ColumnFilter(
            id: 'purchaseAmount',
            title: 'Purchase',
            type: FilterType.number,
          ),
          initialValue: filters.purchaseAmountColumnFilter,
          onApply: (result) => filtersNotifier.setPurchaseAmountColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
    ];
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
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _StockSummaryByItemCategoryTableRows {
  const _StockSummaryByItemCategoryTableRows._();

  static ResizableDataRow buildDataRow({
    required int index,
    required ReportCategoryAmountRow row,
    required bool isOdd,
  }) {
    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
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
            formatReportCurrency(row.saleAmount),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrency(row.purchaseAmount),
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
