import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/item_stock/item_detail_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/utils/item_detail_export.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemDetailReportContent extends ConsumerWidget {
  const ItemDetailReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        List<List<String>> exportRows(ItemDetailReportData? data) {
          if (data == null) return const [];
          final ledger = ledgerRowsForItemDetailReport(data);
          return [for (final entry in ledger) itemDetailExportRow(entry)];
        }

        void exportExcel() {
          if (selectedItemId == null || selectedItemId.isEmpty) return;
          reportExportTable(
            context: context,
            title: 'Item Detail Report',
            filename: 'item-detail-report',
            headers: itemDetailExportHeaders,
            rows: exportRows(report),
          );
        }

        void printReport() {
          if (selectedItemId == null || selectedItemId.isEmpty) return;
          reportPrintTable(
            context: context,
            title: 'Item Detail Report',
            headers: itemDetailExportHeaders,
            rows: exportRows(report),
          );
        }

        return ColoredBox(
          color: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReportPeriodFilterBar(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReportTextActionButton(
                        label: 'Excel',
                        icon: Icons.table_chart_outlined,
                        onTap: selectedItemId == null || selectedItemId.isEmpty
                            ? null
                            : exportExcel,
                      ),
                      ReportTextActionButton(
                        label: 'Print',
                        icon: Icons.print_outlined,
                        onTap: selectedItemId == null || selectedItemId.isEmpty
                            ? null
                            : printReport,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ReportCard(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'DETAILS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ItemDetailTransactionsTable(
                    selectedItemId: selectedItemId,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
