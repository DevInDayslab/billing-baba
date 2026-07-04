import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/sale_purchase_order/sale_purchase_order_report_filters.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalePurchaseOrderItemReportContent extends ConsumerWidget {
  const SalePurchaseOrderItemReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(salePurchaseOrderItemsReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(salePurchaseOrderItemsReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalQty =
            rows.fold<double>(0, (sum, row) => sum + row.quantity);
        final totalAmount =
            rows.fold<double>(0, (sum, row) => sum + row.amount);
        const exportHeaders = ['Item Name', 'Quantity', 'Amount'];
        final exportRows = [
          for (final row in rows)
            [
              row.itemName,
              row.quantity.toStringAsFixed(0),
              formatReportCurrency(row.amount),
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
            child: SalePurchaseOrderReportFilters(
              onExportExcel: () => reportExportTable(
                context: context,
                title: 'Sale / Purchase Order Items',
                filename: 'sale-purchase-order-items',
                headers: exportHeaders,
                rows: exportRows,
              ),
              onPrint: () => reportPrintTable(
                context: context,
                title: 'Sale / Purchase Order Items',
                headers: exportHeaders,
                rows: exportRows,
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
                    Expanded(
                      child: rows.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ReportSyncScrollTable(
                                  headerChildren: const [
                                    Expanded(
                                      child: ReportAlignedHeaderCell(
                                        label: 'ITEM NAME',
                                      ),
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'QUANTITY',
                                      width: 140,
                                      alignment: Alignment.centerRight,
                                    ),
                                    ReportAlignedHeaderCell(
                                      label: 'AMOUNT',
                                      width: 140,
                                      alignment: Alignment.centerRight,
                                    ),
                                  ],
                                  rows: const [],
                                ),
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      'No order items for the selected period.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SingleChildScrollView(
                              child: ReportSyncScrollTable(
                                headerChildren: const [
                                  Expanded(
                                    child: ReportAlignedHeaderCell(
                                      label: 'ITEM NAME',
                                    ),
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'QUANTITY',
                                    width: 140,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'AMOUNT',
                                    width: 140,
                                    alignment: Alignment.centerRight,
                                  ),
                                ],
                                rows: [
                                  for (var i = 0; i < rows.length; i++)
                                    ReportAlignedRowStrip(
                                      index: i,
                                      child: ReportAlignedDataRow(
                                        cells: [
                                          ReportAlignedCell.flex(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(rows[i].itemName),
                                                Text(
                                                  '${rows[i].orderNo} · ${rows[i].partyName}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors
                                                        .textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            140,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              rows[i]
                                                  .quantity
                                                  .toStringAsFixed(0),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            140,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].amount,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: reportCardBorder)),
                      ),
                      child: Row(
                        children: [
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(fontSize: 14),
                              children: [
                                const TextSpan(
                                  text: 'Total Quantity: ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: totalQty.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: reportTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(fontSize: 14),
                              children: [
                                const TextSpan(
                                  text: 'Total Amount: ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: formatReportCurrency(totalAmount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: reportTeal,
                                  ),
                                ),
                              ],
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
                                  salePurchaseOrderItemsReportProvider.notifier,
                                )
                                .goToPage(report.meta.page - 1)
                          : null,
                      onNext: report.meta.page < report.meta.totalPages
                          ? () => ref
                                .read(
                                  salePurchaseOrderItemsReportProvider.notifier,
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
