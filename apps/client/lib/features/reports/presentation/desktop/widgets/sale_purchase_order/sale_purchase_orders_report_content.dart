import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/application/sale_purchase_orders_column_filters_provider.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/sale_purchase_order/sale_purchase_order_report_filters.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/sale_purchase_order/sale_purchase_orders_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_order_filter_utils.dart';
import 'package:billing_baba/features/reports/utils/sale_purchase_orders_export.dart';
import 'package:billing_baba/features/reports/utils/sale_purchase_orders_row_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalePurchaseOrdersReportContent extends ConsumerWidget {
  const SalePurchaseOrdersReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(salePurchaseOrdersReportProvider);
    final filters = ref.watch(reportFiltersProvider);
    final columnFilters = ref.watch(salePurchaseOrdersColumnFiltersProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(salePurchaseOrdersReportProvider.notifier).refresh(),
      data: (report) {
        final toolbarFiltered = filterSalePurchaseOrderRows(
          report.rows,
          filters,
        );
        final exportRows = applySalePurchaseOrdersColumnFilters(
          toolbarFiltered,
          columnFilters,
        );

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
                    title: 'Sale / Purchase Orders',
                    filename: 'sale-purchase-orders',
                    headers: salePurchaseOrdersExportHeaders,
                    rows: [
                      for (final row in exportRows)
                        salePurchaseOrdersExportRow(row),
                    ],
                  ),
                  onPrint: () => reportPrintTable(
                    context: context,
                    title: 'Sale / Purchase Orders',
                    headers: salePurchaseOrdersExportHeaders,
                    rows: [
                      for (final row in exportRows)
                        salePurchaseOrdersExportRow(row),
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
                    child: const SalePurchaseOrdersTransactionsTable(),
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
