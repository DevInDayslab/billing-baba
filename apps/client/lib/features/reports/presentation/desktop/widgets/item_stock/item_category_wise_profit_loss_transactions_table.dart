import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/item_category_wise_profit_loss_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/item_category_wise_profit_loss_row_filter.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
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
const _purchaseColWidth = 130.0;
const _profitColWidth = 160.0;

class ItemCategoryWiseProfitLossTransactionsTable extends ConsumerStatefulWidget {
  const ItemCategoryWiseProfitLossTransactionsTable({super.key});

  @override
  ConsumerState<ItemCategoryWiseProfitLossTransactionsTable> createState() =>
      _ItemCategoryWiseProfitLossTransactionsTableState();
}

class _ItemCategoryWiseProfitLossTransactionsTableState
    extends ConsumerState<ItemCategoryWiseProfitLossTransactionsTable> {
  bool _categoriesHavingSale = false;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(itemCategoryWiseProfitLossReportProvider);
    final columnFilters = ref.watch(
      itemCategoryWiseProfitLossColumnFiltersProvider,
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
          var sourceRows = report.rows;
          if (_categoriesHavingSale) {
            sourceRows =
                sourceRows.where((row) => row.saleAmount > 0).toList();
          }

          final filteredRows = applyItemCategoryWiseProfitLossColumnFilters(
            sourceRows,
            columnFilters,
          );

          var totalSale = 0.0;
          var totalProfit = 0.0;
          for (final row in filteredRows) {
            totalSale += row.saleAmount;
            totalProfit += categoryWiseProfitLoss(row);
          }

          final columns = _ItemCategoryWiseProfitLossTableColumns.build(
            ref: ref,
          );
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _ItemCategoryWiseProfitLossTableRows.buildDataRow(
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
                          'ITEM CATEGORY WISE PROFIT AND LOSS',
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _categoriesHavingSale,
                                  onChanged: (value) => setState(
                                    () => _categoriesHavingSale = value ?? false,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const Text(
                                  'Categories Having Sale',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
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
                                hintText: 'Search categories...',
                                onChanged: ref
                                    .read(reportFiltersProvider.notifier)
                                    .setSearchQuery,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              columnFilters.hasActiveFilters ||
                                      _categoriesHavingSale
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
                      const Divider(height: 1, color: _cardBorder),
                      Expanded(
                        child: ReportTableArea(
                          child: filteredRows.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No profit or loss data for the selected period.',
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
                              'Total Sale: ${formatReportCurrency(totalSale)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Total Profit (+) / Loss (-): '
                              '${formatReportCurrency(totalProfit)}',
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
}

class _ItemCategoryWiseProfitLossTableColumns {
  const _ItemCategoryWiseProfitLossTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(itemCategoryWiseProfitLossColumnFiltersProvider);
    final filtersNotifier = ref.read(
      itemCategoryWiseProfitLossColumnFiltersProvider.notifier,
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
        initialWidth: _purchaseColWidth,
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
      ResizableDataColumn(
        initialWidth: _profitColWidth,
        header: TableColumnFilterTrigger(
          alignment: Alignment.centerRight,
          config: const ColumnFilter(
            id: 'profit',
            title: 'Net Profit (+) / Loss (-)',
            type: FilterType.number,
          ),
          initialValue: filters.profitColumnFilter,
          onApply: (result) => filtersNotifier.setProfitColumnFilter(
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

class _ItemCategoryWiseProfitLossTableRows {
  const _ItemCategoryWiseProfitLossTableRows._();

  static ResizableDataRow buildDataRow({
    required int index,
    required ReportCategoryAmountRow row,
    required bool isOdd,
  }) {
    final profit = categoryWiseProfitLoss(row);
    final profitColor = profit >= 0
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);

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
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrency(profit),
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: profitColor,
              fontWeight: FontWeight.w600,
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
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _cellHorizontalPadding,
          vertical: AppSpacing.sm,
        ),
        child: child,
      ),
    );
  }
}
