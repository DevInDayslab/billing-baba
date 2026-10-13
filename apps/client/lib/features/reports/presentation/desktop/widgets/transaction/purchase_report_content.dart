import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/transaction/purchase_report_summary_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/transaction/purchase_report_title_bar.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/transaction/purchase_report_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/transaction/sale_report_filter_bar.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseReportContent extends ConsumerWidget {
  const PurchaseReportContent({super.key});

  static const _exportHeaders = [
    'Date',
    'Invoice No',
    'Party',
    'Payment Type',
    'Status',
    'Amount',
    'Balance',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(purchaseReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(purchaseReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;

        List<List<String>> exportRows() => [
          for (final purchase in rows)
            [
              formatReportDate(purchase.date),
              purchase.invoiceNo,
              purchase.partyName,
              purchase.paymentType,
              _saleInvoiceStatusLabel(purchase.status),
              formatReportCurrency(purchase.amount),
              formatReportCurrency(purchase.balance),
            ],
        ];

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Purchase Bills Report',
            filename: 'purchase-report',
            headers: _exportHeaders,
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'Purchase Bills Report',
            headers: _exportHeaders,
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
                const PurchaseReportTitleBar(),
                const SizedBox(height: AppSpacing.md),
                const SaleReportFilterBar(),
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
                const SizedBox(height: AppSpacing.md),
                const PurchaseReportSummaryCard(),
                const SizedBox(height: AppSpacing.md),
                const Expanded(child: PurchaseReportTransactionsTable()),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _saleInvoiceStatusLabel(SaleInvoiceStatus status) => switch (status) {
  SaleInvoiceStatus.paid => 'Paid',
  SaleInvoiceStatus.unpaid => 'Unpaid',
  SaleInvoiceStatus.partiallyPaid => 'Partial',
  SaleInvoiceStatus.overdue => 'Overdue',
  SaleInvoiceStatus.cancelled => 'Cancelled',
};
