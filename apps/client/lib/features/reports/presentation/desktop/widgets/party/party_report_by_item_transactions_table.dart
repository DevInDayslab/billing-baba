import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/reports/application/party_report_by_item_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_load_helper.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/party_report_by_item_row_filter.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:billing_baba/shared/widgets/resizable_data_table.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _zebraRowBg = Color(0xFFFAFAFA);
const double _cellHorizontalPadding = AppSpacing.sm;

const _partyColWidth = 200.0;
const _saleQtyColWidth = 100.0;
const _saleAmtColWidth = 120.0;
const _purchaseQtyColWidth = 110.0;
const _purchaseAmtColWidth = 130.0;

class PartyReportByItemTransactionsTable extends ConsumerWidget {
  const PartyReportByItemTransactionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final selectedItemId = filters.itemId;
    final items = ref.watch(inventoryItemListProvider);
    final reportAsync = ref.watch(partyReportByItemReportProvider);
    final columnFilters = ref.watch(partyReportByItemColumnFiltersProvider);
    final isTableLoading = ref.watch(
      reportFiltersProvider.select((state) => state.isTableLoading),
    );
    final isReloading = reportIsTableReloading(reportAsync, isTableLoading);

    final filteredItems = _itemsForCategory(items, filters.categoryId);
    final selectedItemName = _selectedItemName(filteredItems, selectedItemId);
    final itemNames = filteredItems.map((item) => item.name).toList();

    if (selectedItemId == null || selectedItemId.isEmpty) {
      return _emptyShell(
        ref: ref,
        selectedItemName: selectedItemName,
        itemNames: itemNames,
        filteredItems: filteredItems,
        message: 'Select an item to view the report.',
      );
    }

    return ReportReloadScope(
      isReloading: isReloading,
      child: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
        data: (report) {
          if (report == null) {
            return _emptyShell(
              ref: ref,
              selectedItemName: selectedItemName,
              itemNames: itemNames,
              filteredItems: filteredItems,
              message: 'Select an item to view the report.',
            );
          }

          final filteredRows = applyPartyReportByItemColumnFilters(
            report.rows,
            columnFilters,
          );
          final meta = report.meta;

          var totalSaleQty = 0.0;
          var totalSaleAmt = 0.0;
          var totalPurchaseQty = 0.0;
          var totalPurchaseAmt = 0.0;
          for (final row in filteredRows) {
            totalSaleQty += row.saleQuantity;
            totalSaleAmt += row.saleAmount;
            totalPurchaseQty += row.purchaseQuantity;
            totalPurchaseAmt += row.purchaseAmount;
          }

          final columns = _PartyReportByItemTableColumns.build(ref: ref);
          final tableRows = [
            for (var i = 0; i < filteredRows.length; i++)
              _PartyReportByItemTableRows.buildDataRow(
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
                          'PARTY REPORT BY ITEM',
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
                            const Text(
                              'FILTERS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const ReportCategoryFilter(),
                            SaleFilterDropdown(
                              label: selectedItemName,
                              options: ['Select Item', ...itemNames],
                              selected: selectedItemName,
                              onSelected: (value) {
                                if (value == 'Select Item') {
                                  ref
                                      .read(reportFiltersProvider.notifier)
                                      .setItemId(null);
                                  return;
                                }
                                final item = filteredItems.firstWhere(
                                  (entry) => entry.name == value,
                                );
                                ref
                                    .read(reportFiltersProvider.notifier)
                                    .setItemId(item.id);
                              },
                            ),
                            const ReportPartyTypeFilter(),
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
                                hintText: 'Search Party...',
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
                                        'No data available for the selected period.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'Try another item, date range, or filters.',
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
                            Wrap(
                              spacing: AppSpacing.xl,
                              runSpacing: AppSpacing.sm,
                              children: [
                                Text(
                                  'Total Sale Qty: ${totalSaleQty.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Total Sale: '
                                  '${formatReportCurrency(totalSaleAmt)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Total Purchase Qty: '
                                  '${totalPurchaseQty.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Total Purchase: '
                                  '${formatReportCurrency(totalPurchaseAmt)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: reportTeal,
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
                          .read(partyReportByItemReportProvider.notifier)
                          .goToPage(meta.page - 1)
                    : null,
                onNext: meta.page < meta.totalPages
                    ? () => ref
                          .read(partyReportByItemReportProvider.notifier)
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

  static Widget _emptyShell({
    required WidgetRef ref,
    required String selectedItemName,
    required List<String> itemNames,
    required List<InventoryItem> filteredItems,
    required String message,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _cardBorder),
      ),
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const ReportCategoryFilter(),
                    SaleFilterDropdown(
                      label: selectedItemName,
                      options: ['Select Item', ...itemNames],
                      selected: selectedItemName,
                      onSelected: (value) {
                        if (value == 'Select Item') {
                          ref
                              .read(reportFiltersProvider.notifier)
                              .setItemId(null);
                          return;
                        }
                        final item = filteredItems.firstWhere(
                          (entry) => entry.name == value,
                        );
                        ref
                            .read(reportFiltersProvider.notifier)
                            .setItemId(item.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<InventoryItem> _itemsForCategory(
    List<InventoryItem> items,
    String? categoryId,
  ) {
    if (categoryId == null || categoryId.isEmpty) return items;
    return items.where((item) => item.categoryId == categoryId).toList();
  }

  static String _selectedItemName(
    List<InventoryItem> items,
    String? itemId,
  ) {
    if (itemId == null || itemId.isEmpty) return 'Select Item';
    for (final item in items) {
      if (item.id == itemId) return item.name;
    }
    return 'Select Item';
  }
}

class _PartyReportByItemTableColumns {
  const _PartyReportByItemTableColumns._();

  static List<ResizableDataColumn> build({required WidgetRef ref}) {
    final filters = ref.watch(partyReportByItemColumnFiltersProvider);
    final filtersNotifier = ref.read(
      partyReportByItemColumnFiltersProvider.notifier,
    );

    return [
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
        initialWidth: _saleQtyColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'saleQuantity',
            title: 'Sale quantity',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.saleQuantityColumnFilter,
          onApply: (result) => filtersNotifier.setSaleQuantityColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _saleAmtColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'saleAmount',
            title: 'Sale amount',
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
        initialWidth: _purchaseQtyColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'purchaseQuantity',
            title: 'Purchase quantity',
            type: FilterType.number,
          ),
          alignment: Alignment.centerRight,
          initialValue: filters.purchaseQuantityColumnFilter,
          onApply: (result) => filtersNotifier.setPurchaseQuantityColumnFilter(
            FilterUtils.fromResult(result) as AmountColumnFilter?,
          ),
        ),
      ),
      ResizableDataColumn(
        initialWidth: _purchaseAmtColWidth,
        header: TableColumnFilterTrigger(
          config: const ColumnFilter(
            id: 'purchaseAmount',
            title: 'Purchase amount',
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

class _PartyReportByItemTableRows {
  const _PartyReportByItemTableRows._();

  static ResizableDataRow buildDataRow({
    required ReportPartyByItemRow row,
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
        _DataCell(
          alignment: Alignment.centerRight,
          child: Text(
            row.saleQuantity.toStringAsFixed(2),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
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
            row.purchaseQuantity.toStringAsFixed(2),
            style: const TextStyle(
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
  const _DataCell({required this.child, this.alignment = Alignment.centerLeft});

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _cellHorizontalPadding),
      child: Align(alignment: alignment, child: child),
    );
  }
}
