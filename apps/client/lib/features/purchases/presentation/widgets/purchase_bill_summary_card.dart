import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/providers/purchase_bills_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PurchaseBillSummaryCard extends ConsumerWidget {
  const PurchaseBillSummaryCard({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(purchaseBillSummaryProvider);

    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Paid',
            amount: summary.paidAmount,
            backgroundColor: const Color(0xFFE8F5E9),
            labelColor: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryTile(
            label: 'Unpaid',
            amount: summary.unpaidAmount,
            backgroundColor: const Color(0xFFE3F2FD),
            labelColor: const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryTile(
            label: 'Overdue',
            amount: summary.overdueAmount,
            backgroundColor: const Color(0xFFFFF3E0),
            labelColor: const Color(0xFFE65100),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Text(
          '=',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryTile(
            label: 'Total',
            amount: summary.totalAmount,
            backgroundColor: const Color(0xFFFFF8E1),
            labelColor: const Color(0xFFF57C00),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        IconButton(
          onPressed: () => debugPrint('Export xls tapped'),
          icon: const Icon(Icons.table_chart_outlined, size: 20),
          color: AppColors.textSecondary,
          tooltip: 'Excel Report',
        ),
        IconButton(
          onPressed: () => debugPrint('Print tapped'),
          icon: const Icon(Icons.print_outlined, size: 20),
          color: AppColors.textSecondary,
          tooltip: 'Print',
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.backgroundColor,
    required this.labelColor,
  });

  final String label;
  final double amount;
  final Color backgroundColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            PurchaseBillSummaryCard._currencyFormat.format(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
