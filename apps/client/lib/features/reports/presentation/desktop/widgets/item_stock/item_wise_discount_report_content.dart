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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemWiseDiscountReportContent extends ConsumerStatefulWidget {
  const ItemWiseDiscountReportContent({super.key});

  @override
  ConsumerState<ItemWiseDiscountReportContent> createState() =>
      _ItemWiseDiscountReportContentState();
}

class _ItemWiseDiscountReportContentState
    extends ConsumerState<ItemWiseDiscountReportContent> {
  final _itemNameController = TextEditingController();

  @override
  void dispose() {
    _itemNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(itemWiseDiscountReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(itemWiseDiscountReportProvider.notifier).refresh(),
      data: (report) {
        final allRows = report.rows;
        final query = _itemNameController.text.trim().toLowerCase();
        final rows = query.isEmpty
            ? allRows
            : allRows
                  .where((r) => r.itemName.toLowerCase().contains(query))
                  .toList();
        final totalSaleAmount = rows.fold<double>(
          0,
          (sum, row) => sum + row.saleQty * 200,
        );
        final totalDiscount = rows.fold<double>(
          0,
          (sum, row) => sum + row.discountAmount,
        );

        const exportHeaders = [
          '#',
          'Item Name',
          'Total Qty Sold',
          'Total Sale Amount',
          'Total Disc. Amount',
          'Avg. Disc. (%)',
        ];

        List<List<String>> exportRows() => [
          for (var i = 0; i < rows.length; i++)
            [
              '${i + 1}',
              rows[i].itemName,
              rows[i].saleQty.toStringAsFixed(0),
              formatReportCurrency(rows[i].saleQty * 200),
              formatReportCurrency(rows[i].discountAmount),
              '${rows[i].discountPercent.toStringAsFixed(1)}%',
            ],
        ];

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Item Wise Discount',
            filename: 'item-wise-discount',
            headers: exportHeaders,
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'Item Wise Discount',
            headers: exportHeaders,
            rows: exportRows(),
          );
        }

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
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ReportPeriodFilterBar(),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ReportTextActionButton(
                            label: 'Excel Report',
                            icon: Icons.table_chart_outlined,
                            onTap: exportExcel,
                          ),
                          ReportTextActionButton(
                            label: 'Print',
                            icon: Icons.print_outlined,
                            onTap: printReport,
                          ),
                        ],
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
                            'Item Wise Discount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
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
                              const Text(
                                'ITEM NAME',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              SizedBox(
                                width: 280,
                                child: TextField(
                                  controller: _itemNameController,
                                  onChanged: (_) => setState(() {}),
                                  style: const TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Search item...',
                                    hintStyle: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                      borderSide: const BorderSide(
                                        color: reportCardBorder,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                      borderSide: const BorderSide(
                                        color: reportCardBorder,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                      borderSide: const BorderSide(
                                        color: reportTeal,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.surface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: reportCardBorder),
                        Expanded(
                          child: ReportTableArea(
                            child: ReportFilterableSyncTable<ReportItemDiscountRow>(
                              reportScope: itemWiseDiscountReportScope,
                              columns: itemWiseDiscountColumns(),
                              rows: rows,
                              emptyState: const Center(
                                child: Text(
                                  'No Items',
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
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: reportCardBorder),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Summary',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Total Sale Amount: ${formatReportCurrency(totalSaleAmount)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total Discount amount: ${formatReportCurrency(totalDiscount)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
                                      itemWiseDiscountReportProvider.notifier,
                                    )
                                    .goToPage(report.meta.page - 1)
                              : null,
                          onNext: report.meta.page < report.meta.totalPages
                              ? () => ref
                                    .read(
                                      itemWiseDiscountReportProvider.notifier,
                                    )
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
