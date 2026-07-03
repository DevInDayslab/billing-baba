import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_summary_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/transaction_report_filter_bar.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_empty_state_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PurchaseReportContent extends StatelessWidget {
  const PurchaseReportContent({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
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
              totalAmount: 0,
              secondaryLabel:
                  'Paid: ${_currencyFormat.format(0)} | '
                  'Balance: ${_currencyFormat.format(0)}',
              trendUp: false,
            ),
            const SizedBox(height: AppSpacing.md),
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
            ),
          ],
        ),
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
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
          color: AppColors.textSecondary,
          tooltip: 'Settings',
        ),
      ],
    );
  }
}
