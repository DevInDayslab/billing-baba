import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filterable_sync_table.dart';
import 'package:billing_baba/features/reports/utils/report_table_builders.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_export_service.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyReportByItemContent extends ConsumerStatefulWidget {
  const PartyReportByItemContent({super.key});

  @override
  ConsumerState<PartyReportByItemContent> createState() =>
      _PartyReportByItemContentState();
}

class _PartyReportByItemContentState
    extends ConsumerState<PartyReportByItemContent> {
  String _selectedItemName(List<InventoryItem> items, String? itemId) {
    if (itemId == null || itemId.isEmpty) return 'All Items';
    for (final item in items) {
      if (item.id == itemId) return item.name;
    }
    return 'All Items';
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(reportFiltersProvider);
    final items = ref.watch(inventoryItemsProvider).value ?? [];
    final selectedItemId = filters.itemId;
    final selectedItemName = _selectedItemName(items, selectedItemId);
    final itemNames = items.map((item) => item.name).toList();
    final reportAsync = ref.watch(partyReportByItemReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(partyReportByItemReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report?.rows ?? const [];

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Party Report By Item',
            filename: 'party-report-by-item',
            headers: const [
              'Party Name',
              'Sale Quantity',
              'Sale Amount',
              'Purchase Quantity',
              'Purchase Amount',
            ],
            rows: [
              for (final row in rows)
                [
                  row.partyName,
                  row.quantity.toStringAsFixed(0),
                  formatReportCurrency(row.amount),
                  '—',
                  '—',
                ],
            ],
          );
        }

        return ColoredBox(
          color: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReportCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ReportPeriodFilterBar(),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          ReportTextActionButton(
                            label: 'Excel Report',
                            icon: Icons.table_chart_outlined,
                            onTap: exportCsv,
                          ),
                          ReportTextActionButton(
                            label: 'Print',
                            icon: Icons.print_outlined,
                            onTap: () => ReportExportService.showPrintPreview(
                              context: context,
                              title: 'Party Report By Item',
                              content: ReportExportService.toCsv(
                                headers: const [
                                  'Party Name',
                                  'Sale Quantity',
                                  'Sale Amount',
                                ],
                                rows: [
                                  for (final row in rows)
                                    [
                                      row.partyName,
                                      row.quantity.toStringAsFixed(0),
                                      formatReportCurrency(row.amount),
                                    ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          const ReportCategoryFilter(),
                          SaleFilterDropdown(
                            label: selectedItemName,
                            options: ['All Items', ...itemNames],
                            selected: selectedItemName,
                            onSelected: (value) {
                              if (value == 'All Items') {
                                ref
                                    .read(reportFiltersProvider.notifier)
                                    .setItemId(null);
                                return;
                              }
                              final item = items.firstWhere(
                                (entry) => entry.name == value,
                              );
                              ref
                                  .read(reportFiltersProvider.notifier)
                                  .setItemId(item.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ReportSearchField(
                  hintText: 'Search Party...',
                  onChanged: ref
                      .read(reportFiltersProvider.notifier)
                      .setSearchQuery,
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ReportCard(
                    child: ReportTableArea(
                      child: ReportFilterableSyncTable<ReportPartyByItemRow>(
                        reportScope: partyReportByItemScope,
                        minWidth: 700,
                        columns: partyReportByItemColumns(),
                        rows: selectedItemId == null || selectedItemId.isEmpty
                            ? const []
                            : rows,
                        emptyState: SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              selectedItemId == null || selectedItemId.isEmpty
                                  ? 'Select an item to view the report.'
                                  : 'No data available for the selected period.',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
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
                              .read(partyReportByItemReportProvider.notifier)
                              .goToPage(report.meta.page - 1)
                        : null,
                    onNext: report.meta.page < report.meta.totalPages
                        ? () => ref
                              .read(partyReportByItemReportProvider.notifier)
                              .goToPage(report.meta.page + 1)
                        : null,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
