import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/export/presentation/desktop/widgets/module_export_actions.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/module_print_actions.dart';
import 'package:billing_baba/features/purchases/application/purchase_orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PurchaseOrderSummaryCard extends ConsumerWidget {
  const PurchaseOrderSummaryCard({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(purchaseOrderSummaryProvider);

    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Open',
            amount: summary.openAmount,
            backgroundColor: const Color(0xFFE3F2FD),
            labelColor: const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryTile(
            label: 'Partially Received',
            amount: summary.partiallyReceivedAmount,
            backgroundColor: const Color(0xFFFFF3E0),
            labelColor: const Color(0xFFE65100),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryTile(
            label: 'Completed',
            amount: summary.completedAmount,
            backgroundColor: const Color(0xFFE8F5E9),
            labelColor: const Color(0xFF2E7D32),
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
          onPressed: () =>
              ModuleExportActions.exportPurchaseOrders(context, ref),
          icon: const Icon(Icons.table_chart_outlined, size: 20),
          color: AppColors.textSecondary,
          tooltip: 'Excel Report',
        ),
        IconButton(
          onPressed: () => ModulePrintActions.printPurchaseOrders(context, ref),
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
            PurchaseOrderSummaryCard._currencyFormat.format(amount),
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
