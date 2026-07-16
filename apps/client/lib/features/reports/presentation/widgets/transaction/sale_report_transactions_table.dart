import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/providers/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);

const _dateColWidth = 100.0;
const _invoiceColWidth = 130.0;
const _transactionColWidth = 110.0;
const _paymentColWidth = 110.0;
const _statusColWidth = 100.0;
const _amountColWidth = 100.0;
const _balanceColWidth = 90.0;
const _actionsColWidth = 120.0;
const double _minTableWidth =
    _dateColWidth +
    _invoiceColWidth +
    _transactionColWidth +
    _paymentColWidth +
    _statusColWidth +
    _amountColWidth +
    _balanceColWidth +
    _actionsColWidth +
    140;

class SaleReportTransactionsTable extends ConsumerWidget {
  const SaleReportTransactionsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(saleReportProvider);

    return reportAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (report) {
        final invoices = report.rows;
        final meta = report.meta;

        return Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: _cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Transactions',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text('${meta.total} total'),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: _cardBorder),
                  ReportSyncScrollTable(
                    minWidth: _minTableWidth,
                    emptyState: const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Text(
                          'No transactions to show',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    headerChildren: const [
                      ReportAlignedHeaderCell(
                        label: 'Date',
                        width: _dateColWidth,
                      ),
                      ReportAlignedHeaderCell(
                        label: 'Invoice no',
                        width: _invoiceColWidth,
                      ),
                      Expanded(
                        child: ReportAlignedHeaderCell(label: 'Party Name'),
                      ),
                      ReportAlignedHeaderCell(
                        label: 'Transaction',
                        width: _transactionColWidth,
                      ),
                      ReportAlignedHeaderCell(
                        label: 'Payment Type',
                        width: _paymentColWidth,
                      ),
                      ReportAlignedHeaderCell(
                        label: 'Status',
                        width: _statusColWidth,
                      ),
                      ReportAlignedHeaderCell(
                        label: 'Amount',
                        width: _amountColWidth,
                        alignment: Alignment.centerRight,
                      ),
                      ReportAlignedHeaderCell(
                        label: 'Balance',
                        width: _balanceColWidth,
                        alignment: Alignment.centerRight,
                      ),
                      ReportAlignedHeaderCell(
                        label: 'Actions',
                        width: _actionsColWidth,
                        showFilter: false,
                      ),
                    ],
                    rows: [
                      for (var i = 0; i < invoices.length; i++)
                        ReportAlignedRowStrip(
                          index: i,
                          child: _InvoiceDataRow(invoice: invoices[i]),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            ReportPaginationBar(
              page: meta.page,
              totalPages: meta.totalPages,
              onPrevious: meta.page > 1
                  ? () => ref
                        .read(saleReportProvider.notifier)
                        .goToPage(
                          meta.page - 1,
                        )
                  : null,
              onNext: meta.page < meta.totalPages
                  ? () => ref
                        .read(saleReportProvider.notifier)
                        .goToPage(
                          meta.page + 1,
                        )
                  : null,
            ),
          ],
        );
      },
    );
  }
}

class _InvoiceDataRow extends StatelessWidget {
  const _InvoiceDataRow({required this.invoice});

  final SaleInvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    return ReportAlignedDataRow(
      cells: [
        ReportAlignedCell.fixed(
          _dateColWidth,
          child: Text(formatReportDate(invoice.date)),
        ),
        ReportAlignedCell.fixed(
          _invoiceColWidth,
          child: Text(invoice.invoiceNo),
        ),
        ReportAlignedCell.flex(child: Text(invoice.partyName)),
        ReportAlignedCell.fixed(
          _transactionColWidth,
          child: Text(invoice.transactionType),
        ),
        ReportAlignedCell.fixed(
          _paymentColWidth,
          child: Text(invoice.paymentType),
        ),
        ReportAlignedCell.fixed(
          _statusColWidth,
          child: SaleInvoiceStatusBadge(status: invoice.status),
        ),
        ReportAlignedCell.fixed(
          _amountColWidth,
          alignment: Alignment.centerRight,
          child: Text(formatReportCurrencyCompact(invoice.amount)),
        ),
        ReportAlignedCell.fixed(
          _balanceColWidth,
          alignment: Alignment.centerRight,
          child: Text(formatReportCurrencyCompact(invoice.balance)),
        ),
        const ReportAlignedCell.fixed(_actionsColWidth, child: SizedBox()),
      ],
    );
  }
}
