import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/item_stock/item_wise_discount_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/utils/item_wise_discount_export.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemWiseDiscountReportContent extends ConsumerWidget {
  const ItemWiseDiscountReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(itemWiseDiscountReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(itemWiseDiscountReportProvider.notifier).refresh(),
      data: (report) {
        List<List<String>> exportRows() => [
          for (final row in report.rows) itemWiseDiscountExportRow(row),
        ];

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Item Wise Discount',
            filename: 'item-wise-discount',
            headers: itemWiseDiscountExportHeaders,
            rows: exportRows(),
          );
        }

        void exportPrint() {
          reportPrintTable(
            context: context,
            title: 'Item Wise Discount',
            headers: itemWiseDiscountExportHeaders,
            rows: exportRows(),
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
                        label: 'Excel Report',
                        icon: Icons.table_chart_outlined,
                        onTap: exportExcel,
                      ),
                      ReportTextActionButton(
                        label: 'Print',
                        icon: Icons.print_outlined,
                        onTap: exportPrint,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ItemWiseDiscountTransactionsTable(
                    totalSaleAmount: report.resolvedTotalSaleAmount,
                    totalDiscountAmount: report.resolvedTotalDiscountAmount,
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
