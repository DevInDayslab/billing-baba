import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';

class SalesOrderSummaryData {
  const SalesOrderSummaryData({
    required this.total,
    required this.pending,
    required this.completed,
    required this.cancelled,
  });

  final int total;
  final int pending;
  final int completed;
  final int cancelled;
}

SalesOrderSummaryData summarizeSaleOrders(List<SaleInvoiceModel> items) {
  var pending = 0;
  var completed = 0;
  var cancelled = 0;

  for (final item in items) {
    switch (item.documentStatus) {
      case SalesDocumentStatus.draft:
        pending += 1;
      case SalesDocumentStatus.finalized:
        completed += 1;
      case SalesDocumentStatus.cancelled:
        cancelled += 1;
      case SalesDocumentStatus.converted:
        completed += 1;
    }
  }

  return SalesOrderSummaryData(
    total: items.length,
    pending: pending,
    completed: completed,
    cancelled: cancelled,
  );
}

class SalesOrderSummaryCards extends StatelessWidget {
  const SalesOrderSummaryCards({required this.summary, super.key});

  final SalesOrderSummaryData summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Total Orders',
            value: '${summary.total}',
            color: const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryCard(
            label: 'Pending',
            value: '${summary.pending}',
            color: const Color(0xFFF57C00),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryCard(
            label: 'Completed',
            value: '${summary.completed}',
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryCard(
            label: 'Cancelled',
            value: '${summary.cancelled}',
            color: const Color(0xFF616161),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
