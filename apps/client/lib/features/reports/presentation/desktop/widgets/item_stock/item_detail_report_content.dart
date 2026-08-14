import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filterable_sync_table.dart';
import 'package:billing_baba/features/reports/utils/report_table_builders.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemDetailReportContent extends ConsumerStatefulWidget {
  const ItemDetailReportContent({super.key});

  @override
  ConsumerState<ItemDetailReportContent> createState() =>
      _ItemDetailReportContentState();
}

class _ItemDetailReportContentState
    extends ConsumerState<ItemDetailReportContent> {
  bool _hideInactiveDates = false;

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(reportFiltersProvider);
    final selectedItemId = filters.itemId;
    final items = ref.watch(inventoryItemListProvider);
    var selectedItemName = 'Select Item';
    if (selectedItemId != null) {
      for (final item in items) {
        if (item.id == selectedItemId) {
          selectedItemName = item.name;
          break;
        }
      }
    }
    final itemNames = items.map((item) => item.name).toList();
    final reportAsync = ref.watch(itemDetailReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(itemDetailReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report?.rows ?? const [];

        double runningClosing(int index) {
          var balance = 0.0;
          for (var i = 0; i <= index; i++) {
            final row = rows[i];
            balance += row.type == 'Sale' ? -row.quantity : row.quantity;
          }
          return balance;
        }

        const exportHeaders = [
          'Date',
          'Sale Quantity',
          'Purchase Quantity',
          'Adjustment Quantity',
          'Closing Quantity',
        ];

        List<List<String>> exportRows() => [
          for (var i = 0; i < rows.length; i++)
            [
              formatReportDate(rows[i].date),
              if (rows[i].type == 'Sale')
                rows[i].quantity.toStringAsFixed(0)
              else
                '-',
              if (rows[i].type != 'Sale')
                rows[i].quantity.toStringAsFixed(0)
              else
                '-',
              '-',
              runningClosing(i).toStringAsFixed(0),
            ],
        ];

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Item Detail Report',
            filename: 'item-detail-report',
            headers: exportHeaders,
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'Item Detail Report',
            headers: exportHeaders,
            rows: exportRows(),
          );
        }

        final tableRows = [
          for (var i = 0; i < rows.length; i++)
            ReportItemDetailTableRow(
              row: rows[i],
              closingQty: runningClosing(i),
            ),
        ];

        return ColoredBox(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: ReportCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const ReportFromToDateFilter(betweenLabel: 'From'),
                      ReportIconActionButton(
                        icon: Icons.table_chart_outlined,
                        tooltip: 'Excel',
                        onTap: exportExcel,
                      ),
                      ReportIconActionButton(
                        icon: Icons.print_outlined,
                        tooltip: 'Print',
                        onTap: printReport,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: ReportCard(
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
                              letterSpacing: 0.5,
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
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Item name',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  SizedBox(
                                    width: 260,
                                    child: SaleFilterDropdown(
                                      label: selectedItemName,
                                      options: ['Select Item', ...itemNames],
                                      selected: selectedItemName,
                                      onSelected: (value) {
                                        if (value == 'Select Item') {
                                          ref
                                              .read(
                                                reportFiltersProvider.notifier,
                                              )
                                              .setItemId(null);
                                          return;
                                        }
                                        final item = items.firstWhere(
                                          (entry) => entry.name == value,
                                        );
                                        ref
                                            .read(
                                              reportFiltersProvider.notifier,
                                            )
                                            .setItemId(item.id);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _hideInactiveDates,
                                    onChanged: (value) => setState(
                                      () => _hideInactiveDates = value ?? false,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const Text(
                                    'Hide inactive dates',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: reportCardBorder),
                        const Divider(height: 1, color: reportCardBorder),
                        Expanded(
                          child: ReportTableArea(
                            child:
                                ReportFilterableSyncTable<
                                  ReportItemDetailTableRow
                                >(
                                  reportScope: itemDetailReportScope,
                                  columns: itemDetailColumns(),
                                  rows:
                                      selectedItemId == null ||
                                          selectedItemId.isEmpty
                                      ? const []
                                      : tableRows,
                                  emptyState: Center(
                                    child: Text(
                                      selectedItemId == null ||
                                              selectedItemId.isEmpty
                                          ? 'Select an item to view the report.'
                                          : 'No data for the selected period.',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                        if (report != null)
                          ReportPaginationBar(
                            page: report.meta.page,
                            totalPages: report.meta.totalPages,
                            onPrevious: report.meta.page > 1
                                ? () => ref
                                      .read(itemDetailReportProvider.notifier)
                                      .goToPage(report.meta.page - 1)
                                : null,
                            onNext: report.meta.page < report.meta.totalPages
                                ? () => ref
                                      .read(itemDetailReportProvider.notifier)
                                      .goToPage(report.meta.page + 1)
                                : null,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
