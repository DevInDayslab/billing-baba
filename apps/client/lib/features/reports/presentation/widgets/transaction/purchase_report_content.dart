import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_summary_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/transaction_report_filter_bar.dart';
import 'package:billing_baba/features/reports/providers/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_empty_state_card.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PurchaseReportContent extends ConsumerWidget {
  const PurchaseReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(purchaseReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(purchaseReportProvider.notifier).refresh(),
      data: (report) => ColoredBox(
        color: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PurchaseTitleBar(onAdd: () => context.push(AppRoutes.purchase)),
              const SizedBox(height: AppSpacing.md),
              const TransactionReportFilterBar(),
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
              if (report.rows.isEmpty)
                SaleEmptyStateCard(
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
              else
                ReportCard(
                  child: ReportSyncScrollTable(
                    minWidth: 840,
                    headerChildren: const [
                      ReportAlignedHeaderCell(label: 'DATE', width: 100),
                      ReportAlignedHeaderCell(label: 'INVOICE NO', width: 120),
                      Expanded(child: ReportAlignedHeaderCell(label: 'PARTY')),
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
                        _PurchaseRow(purchase: report.rows[i], index: i),
                    ],
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
      ),
    );
  }
}

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
            child: Text(formatReportCurrencyCompact(purchase.amount)),
          ),
          ReportAlignedCell.fixed(
            100,
            alignment: Alignment.centerRight,
            child: Text(formatReportCurrencyCompact(purchase.balance)),
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
