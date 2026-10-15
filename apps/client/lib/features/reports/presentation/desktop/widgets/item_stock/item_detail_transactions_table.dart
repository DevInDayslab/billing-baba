import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/item_detail_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/utils/item_detail_ledger.dart';
import 'package:billing_baba/features/reports/utils/item_detail_row_filter.dart';
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
const _typeColWidth = 96.0;
const _refColWidth = 110.0;
const _partyColWidth = 160.0;
const _qtyColWidth = 88.0;
const _priceColWidth = 96.0;
const _amountColWidth = 104.0;
const _closingColWidth = 110.0;

List<ReportItemDetailTableRow> ledgerRowsForItemDetailReport(
  ItemDetailReportData report,
) {
  if (report.ledgerRows != null) return report.ledgerRows!;
  return buildItemDetailLedgerRows(
    report.rows,
    openingQty: report.openingQuantity,
    newestFirst: true,
  );
}

class ItemDetailTransactionsTable extends ConsumerWidget {
  const ItemDetailTransactionsTable({
    required this.selectedItemId,
    super.key,
  });

  final String? selectedItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(itemDetailReportProvider);
    final columnFilters = ref.watch(itemDetailColumnFiltersProvider);
    final isTableLoading = ref.watch(
      reportFiltersProvider.select((state) => state.isTableLoading),
    );
    final isReloading = reportIsTableReloading(reportAsync, isTableLoading);

    final noItem =
        selectedItemId == null || selectedItemId!.isEmpty;

    return ReportReloadScope(
      isReloading: isReloading,
      child: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
        data: (report) {
          if (noItem) {
            return const Center(
              child: Text(
                'Select an item to view the report.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          if (report == null) {
            return const Center(
              child: Text(
                'Select an item to view the report.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          final ledgerRows = ledgerRowsForItemDetailReport(report);
          final filteredRows = applyItemDetailColumnFilters(
            ledgerRows,
            columnFilters,
          );
          final meta = report.meta;

          final columns = _ItemDetailTableColumns.build(
            ref: ref,
            rows: ledgerRows,
          );
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _ItemDetailTableRows.buildDataRow(
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
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: const [
                            ReportPageSizeFilter(),
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
                        child: Text(
                          columnFilters.hasActiveFilters
                              ? '${filteredRows.length} shown · ${meta.total} total'
                              : '${meta.total} total',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: _cardBorder),
                      Expanded(
                        child: ReportTableArea(
                          child: filteredRows.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No data for the selected period.',
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
                      ReportPaginationBar(
                        page: meta.page,
                        totalPages: meta.totalPages,
                        onPrevious: meta.page > 1
                            ? () => ref
                                  .read(itemDetailReportProvider.notifier)
                                  .goToPage(meta.page - 1)
                            : null,
                        onNext: meta.page < meta.totalPages
                            ? () => ref
                                  .read(itemDetailReportProvider.notifier)
                                  .goToPage(meta.page + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemDetailTableColumns {
  const _ItemDetailTableColumns._();

  static List<ResizableDataColumn> build({
    required WidgetRef ref,
    required List<ReportItemDetailTableRow> rows,
  }) {
    final filters = ref.watch(itemDetailColumnFiltersProvider);
    final filtersNotifier = ref.read(itemDetailColumnFiltersProvider.notifier);
    final typeOptions = reportUniqueSortedValues(
      rows.map((entry) => entry.row.type),
    );

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
        initialWidth: _typeColWidth,
        minWidth: 80,
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
        initialWidth: _qtyColWidth,
        header: TableColumnFilterTrigger(
          alignment: Alignment.centerRight,
          config: const ColumnFilter(
            id: 'quantity',
            title: 'Qty',
            type: FilterType.number,
          ),
          initialValue: filters.quantityColumnFilter,
          onApply: (result) => filtersNotifier.setQuantityColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _priceColWidth,
        header: TableColumnFilterTrigger(
          alignment: Alignment.centerRight,
          config: const ColumnFilter(
            id: 'price',
            title: 'Price',
            type: FilterType.number,
          ),
          initialValue: filters.priceColumnFilter,
          onApply: (result) => filtersNotifier.setPriceColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _amountColWidth,
        header: TableColumnFilterTrigger(
          alignment: Alignment.centerRight,
          config: const ColumnFilter(
            id: 'amount',
            title: 'Amount',
            type: FilterType.number,
          ),
          initialValue: filters.amountColumnFilter,
          onApply: (result) => filtersNotifier.setAmountColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _closingColWidth,
        header: TableColumnFilterTrigger(
          alignment: Alignment.centerRight,
          config: const ColumnFilter(
            id: 'closingQty',
            title: 'Closing qty',
            type: FilterType.number,
          ),
          initialValue: filters.closingQtyColumnFilter,
          onApply: (result) => filtersNotifier.setClosingQtyColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
    ];
  }
}

class _ItemDetailTableRows {
  const _ItemDetailTableRows._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  static ResizableDataRow buildDataRow({
    required ReportItemDetailTableRow entry,
    required bool isOdd,
  }) {
    final row = entry.row;
    return ResizableDataRow(
      backgroundColor: isOdd ? _zebraRowBg : Colors.transparent,
      cells: [
        _DataCell(child: Text(_dateFormat.format(row.date))),
        _DataCell(child: Text(row.type)),
        _DataCell(
          child: Text(
            row.refNo,
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
            row.quantity.toStringAsFixed(2),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrencyCompact(row.price),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            formatReportCurrencyCompact(row.amount),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            entry.closingQty.toStringAsFixed(2),
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
