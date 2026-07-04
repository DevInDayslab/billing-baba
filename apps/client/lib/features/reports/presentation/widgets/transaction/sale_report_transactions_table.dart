import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
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
const _minTableWidth =
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
    final invoices = ref.watch(reportSaleInvoicesProvider).take(20).toList();

    return DecoratedBox(
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
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Search',
                ),
                _XlsChip(onTap: () {}),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.print_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Print',
                ),
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
              ReportAlignedHeaderCell(label: 'Date', width: _dateColWidth),
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
        ReportAlignedCell.fixed(
          _actionsColWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.print_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _XlsChip extends StatelessWidget {
  const _XlsChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'xls',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      ),
    );
  }
}
