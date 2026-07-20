import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/sale_report_filter_bar.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/sale_report_summary_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/sale_report_title_bar.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/sale_report_transactions_table.dart';
import 'package:billing_baba/features/reports/providers/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaleReportContent extends ConsumerWidget {
  const SaleReportContent({super.key});

  static const _exportHeaders = [
    'Date',
    'Invoice No',
    'Party Name',
    'Transaction',
    'Payment Type',
    'Status',
    'Amount',
    'Balance',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(saleReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(saleReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;

        List<List<String>> exportRows() => [
          for (final invoice in rows)
            [
              formatReportDate(invoice.date),
              invoice.invoiceNo,
              invoice.partyName,
              invoice.transactionType,
              invoice.paymentType,
              _saleInvoiceStatusLabel(invoice.status),
              formatReportCurrency(invoice.amount),
              formatReportCurrency(invoice.balance),
            ],
        ];

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Sale Report',
            filename: 'sale-report',
            headers: _exportHeaders,
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'Sale Report',
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
                const SaleReportTitleBar(),
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
                const SaleReportSummaryCard(),
                const SizedBox(height: AppSpacing.md),
                const Expanded(child: SaleReportTransactionsTable()),
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
