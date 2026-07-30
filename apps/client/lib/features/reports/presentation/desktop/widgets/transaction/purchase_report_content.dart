import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_summary_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/transaction_report_filter_bar.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_empty_state_card.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_invoice_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
                _PurchaseTitleBar(
                  onAdd: () => context.push(AppRoutes.purchase),
                ),
                const SizedBox(height: AppSpacing.md),
                ReportCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TransactionReportFilterBar(),
                      const SizedBox(height: AppSpacing.sm),
                      const ReportSearchField(
                        hintText: 'Search purchases...',
                      ),
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
                const SizedBox(height: AppSpacing.md),
                ReportSummaryCard(
                  amountLabel: 'Total Purchase Amount',
                  totalAmount: report.totalAmount,
                  secondaryLabel:
                      'Paid: ${formatReportCurrency(report.paidAmount)} | '
                      'Balance: ${formatReportCurrency(report.balanceAmount)}',
                  trendUp: false,
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: report.rows.isEmpty
                      ? SaleEmptyStateCard(
                          illustration: const SaleGeometricIllustration(
                            circleColor: Color(0xFFE8F5E9),
                            shapeColor: Color(0xFF81C784),
                            shapeIcon: Icons.shopping_basket_outlined,
                          ),
                          title: 'No Transactions to show',
                          description: "You haven't added any purchases yet.",
                          buttonLabel: 'Add Purchase',
                          buttonColor: reportAddRed,
                          buttonIcon: Icons.add,
                          onPressed: () => context.push(AppRoutes.purchase),
                        )
                      : ReportTableArea(
                          child: ReportCard(
                            child: ReportSyncScrollTable(
                              minWidth: 840,
                              headerChildren: const [
                                ReportAlignedHeaderCell(label: 'DATE', width: 100),
                                ReportAlignedHeaderCell(
                                  label: 'INVOICE NO',
                                  width: 120,
                                ),
                                Expanded(
                                  child: ReportAlignedHeaderCell(label: 'PARTY'),
                                ),
                                ReportAlignedHeaderCell(
                                  label: 'PAYMENT TYPE',
                                  width: 120,
                                ),
                                ReportAlignedHeaderCell(label: 'STATUS', width: 100),
                                ReportAlignedHeaderCell(
                                  label: 'AMOUNT',
                                  width: 100,
                                  alignment: Alignment.centerRight,
                                ),
                                ReportAlignedHeaderCell(
                                  label: 'BALANCE',
                                  width: 100,
                                  alignment: Alignment.centerRight,
                                ),
                              ],
                              rows: [
                                for (var i = 0; i < report.rows.length; i++)
                                  _PurchaseRow(
                                    purchase: report.rows[i],
                                    index: i,
                                  ),
                              ],
                            ),
                          ),
                        ),
                ),
                ReportPaginationBar(
                  page: report.meta.page,
                  totalPages: report.meta.totalPages,
                  onPrevious: report.meta.page > 1
                      ? () => ref
                            .read(purchaseReportProvider.notifier)
                            .goToPage(report.meta.page - 1)
                      : null,
                  onNext: report.meta.page < report.meta.totalPages
                      ? () => ref
                            .read(purchaseReportProvider.notifier)
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

String _saleInvoiceStatusLabel(SaleInvoiceStatus status) => switch (status) {
  SaleInvoiceStatus.paid => 'Paid',
  SaleInvoiceStatus.unpaid => 'Unpaid',
  SaleInvoiceStatus.partiallyPaid => 'Partial',
  SaleInvoiceStatus.overdue => 'Overdue',
  SaleInvoiceStatus.cancelled => 'Cancelled',
};

class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({required this.purchase, required this.index});

  final ReportPurchaseRow purchase;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ReportAlignedRowStrip(
      index: index,
      child: ReportAlignedDataRow(
        cells: [
          ReportAlignedCell.fixed(
            100,
            child: Text(formatReportDate(purchase.date)),
          ),
          ReportAlignedCell.fixed(120, child: Text(purchase.invoiceNo)),
          ReportAlignedCell.flex(child: Text(purchase.partyName)),
          ReportAlignedCell.fixed(120, child: Text(purchase.paymentType)),
          ReportAlignedCell.fixed(
            100,
            child: SaleInvoiceStatusBadge(status: purchase.status),
          ),
          ReportAlignedCell.fixed(
            100,
            alignment: Alignment.centerRight,
            child: Text(
              formatReportCurrencyCompact(purchase.amount),
              style: const TextStyle(
                color: Color(0xFFC62828),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ReportAlignedCell.fixed(
            100,
            alignment: Alignment.centerRight,
            child: Text(
              formatReportCurrencyCompact(purchase.balance),
              style: TextStyle(
                color: purchase.balance > 0 ? const Color(0xFFC62828) : null,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseTitleBar extends StatelessWidget {
  const _PurchaseTitleBar({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Purchase Bills Report',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            backgroundColor: reportAddRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Add Purchase Bill',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
