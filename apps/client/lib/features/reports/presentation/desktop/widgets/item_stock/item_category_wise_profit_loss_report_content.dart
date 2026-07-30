import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
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

class ItemCategoryWiseProfitLossReportContent extends ConsumerStatefulWidget {
  const ItemCategoryWiseProfitLossReportContent({super.key});

  @override
  ConsumerState<ItemCategoryWiseProfitLossReportContent> createState() =>
      _ItemCategoryWiseProfitLossReportContentState();
}

class _ItemCategoryWiseProfitLossReportContentState
    extends ConsumerState<ItemCategoryWiseProfitLossReportContent> {
  String _firm = 'ALL FIRMS';
  bool _showInactiveCategories = false;
  bool _categoriesHavingSale = false;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(itemCategoryWiseProfitLossReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(itemCategoryWiseProfitLossReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final tableRows = _categoriesHavingSale
            ? rows.where((row) => row.saleAmount > 0).toList()
            : rows;
        final totalSale = tableRows.fold<double>(
          0,
          (sum, row) => sum + row.saleAmount,
        );
        final totalProfit = tableRows.fold<double>(
          0,
          (sum, row) => sum + (row.saleAmount - row.purchaseAmount),
        );
        const exportHeaders = [
          'Item Category',
          'Sale',
          'CR. Note / Sale Return',
          'Purchase',
          'DR. Note / Purchase Return',
          'Opening Stock',
          'Closing Stock',
          'Net Profit (+) / Loss (-)',
        ];
        final exportRows = [
          for (final row in rows)
            [
              row.category,
              formatReportCurrency(row.saleAmount),
              '-',
              formatReportCurrency(row.purchaseAmount),
              '-',
              '-',
              '-',
              formatReportCurrency(row.saleAmount - row.purchaseAmount),
            ],
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
                      SaleFilterDropdown(
                        label: _firm,
                        options: const ['ALL FIRMS', 'Firm A', 'Firm B'],
                        selected: _firm,
                        onSelected: (value) => setState(() => _firm = value),
                      ),
                      const ReportFromToDateFilter(betweenLabel: 'From'),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showInactiveCategories,
                            onChanged: (value) => setState(
                              () => _showInactiveCategories = value ?? false,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          const Text(
                            'Show Inactive Categories',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
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
                      ReportTextActionButton(
                        label: 'Excel',
                        icon: Icons.table_chart_outlined,
                        onTap: () => reportExportTable(
                          context: context,
                          title: 'Item Category Wise Profit / Loss',
                          filename: 'item-category-wise-profit-loss',
                          headers: exportHeaders,
                          rows: exportRows,
                        ),
                      ),
                      ReportTextActionButton(
                        label: 'Print',
                        icon: Icons.print_outlined,
                        onTap: () => reportPrintTable(
                          context: context,
                          title: 'Item Category Wise Profit / Loss',
                          headers: exportHeaders,
                          rows: exportRows,
                        ),
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
                        const Divider(height: 1, color: reportCardBorder),
                        Expanded(
                          child: ReportTableArea(
                            child: ReportFilterableSyncTable<ReportCategoryAmountRow>(
                              reportScope: itemCategoryWiseProfitLossReportScope,
                              minWidth: 1180,
                              columns: itemCategoryWiseProfitLossColumns(),
                              rows: tableRows,
                              emptyState: const Center(
                                child: Text(
                                  'No profit or loss data for the selected period.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
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
                            border: Border(
                              top: BorderSide(color: reportCardBorder),
                            ),
                          ),
                          child: Wrap(
                            spacing: AppSpacing.lg,
                            runSpacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Total Sale: ${formatReportCurrency(totalSale)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Total Profit (+) / Loss (-): ${formatReportCurrency(totalProfit)}',
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
              ),
            ],
          ),
        );
      },
    );
  }
}
