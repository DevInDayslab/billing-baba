import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/application/sale_purchase_by_party_group_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/reports/utils/sale_purchase_by_party_group_row_filter.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _partyGroupColWidth = 140.0;
const _partyColWidth = 200.0;
const _saleColWidth = 120.0;
const _purchaseColWidth = 120.0;

class SalePurchaseByPartyGroupTransactionsTable extends ConsumerWidget {
  const SalePurchaseByPartyGroupTransactionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(salePurchaseByPartyGroupReportProvider);
    final columnFilters = ref.watch(
      salePurchaseByPartyGroupColumnFiltersProvider,
    );
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
          final filteredRows = applySalePurchaseByPartyGroupColumnFilters(
            report.rows,
            columnFilters,
          );

          var totalSale = 0.0;
          var totalPurchase = 0.0;
          for (final row in report.rows) {
            totalSale += row.saleAmount;
            totalPurchase += row.purchaseAmount;
          }
          final netBalance = totalSale - totalPurchase;

          final columns = _SalePurchaseByPartyGroupTableColumns.build(ref: ref);
          final dataRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _SalePurchaseByPartyGroupTableRows.buildDataRow(
                row: filteredRows[i],
                isOdd: i.isOdd,
              ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 160,
                      child: ReportPartyGroupFilter(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const SizedBox(
                      width: 160,
                      child: ReportPartyTypeFilter(),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ReportSearchField(
                        onChanged: ref
                            .read(reportFiltersProvider.notifier)
                            .setSearchQuery,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      columnFilters.hasActiveFilters
                          ? '${filteredRows.length} shown · ${report.meta.total} total'
                          : '${report.meta.total} total',
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
                            'No data available for the selected period.',
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
                            rows: dataRows,
                          ),
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: reportCardBorder)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Total Sale: ${formatReportCurrency(totalSale)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total Purchase: ${formatReportCurrency(totalPurchase)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Text(
                      'Net Balance: ${formatReportCurrency(netBalance)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: reportTeal,
                      ),
                    ),
                  ],
                ),
              ),
              ReportPaginationBar(
                page: report.meta.page,
                totalPages: report.meta.totalPages,
                onPrevious: report.meta.page > 1
                    ? () => ref
                          .read(
                            salePurchaseByPartyGroupReportProvider.notifier,
                          )
                          .goToPage(report.meta.page - 1)
                    : null,
                onNext: report.meta.page < report.meta.totalPages
                    ? () => ref
                          .read(
                            salePurchaseByPartyGroupReportProvider.notifier,
                          )
                          .goToPage(report.meta.page + 1)
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

class _SalePurchaseByPartyGroupTableColumns {
  const _SalePurchaseByPartyGroupTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(salePurchaseByPartyGroupColumnFiltersProvider);
    final filtersNotifier = ref.read(
      salePurchaseByPartyGroupColumnFiltersProvider.notifier,
    );

    return [
      ResizableDataColumn(
        initialWidth: _partyGroupColWidth,
        minWidth: 100,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'partyGroup',
            title: 'Party group',
            type: FilterType.text,
            hintText: 'Party group',
          ),
          initialValue: filters.partyGroupColumnFilter,
          onApply: (result) => filtersNotifier.setPartyGroupColumnFilter(
            FilterUtils.fromResult(result) as TextColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _partyColWidth,
        minWidth: 140,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'partyName',
            title: 'Party name',
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
        initialWidth: _saleColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'saleAmount',
            title: 'Sale',
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
        initialWidth: _purchaseColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'purchaseAmount',
            title: 'Purchase',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.purchaseAmountColumnFilter,
          onApply: (result) => filtersNotifier.setPurchaseAmountColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
    ];
  }
}

class _SalePurchaseByPartyGroupTableRows {
  const _SalePurchaseByPartyGroupTableRows._();

  static ResizableDataRow buildDataRow({
    required ReportSalePurchaseByPartyGroupRow row,
    required bool isOdd,
  }) {
    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(
          child: Text(
            row.partyGroup,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
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
            formatReportCurrencyCompact(row.purchaseAmount),
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
