import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);

class SaleInvoiceSummaryCard extends ConsumerWidget {
  const SaleInvoiceSummaryCard({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 0,
  );

  static final _pointsFormat = NumberFormat('#,##0.##', 'en_IN');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(saleInvoiceSummaryProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertically = constraints.maxWidth < 640;

        final salesPanel = _SummaryPanel(
          title: 'Total Sales Amount',
          primaryValue: _currencyFormat.format(summary.totalSalesAmount),
          secondaryLine:
              'Received: ${_currencyFormat.format(summary.receivedAmount)} | '
              'Balance: ${_currencyFormat.format(summary.balanceAmount)}',
        );

        final loyaltyPanel = _SummaryPanel(
          title: 'Total Loyalty Points Rewarded',
          primaryValue: _pointsFormat.format(summary.loyaltyPointsRewarded),
          secondaryLine:
              'Total Discount Redeemed: '
              '${_currencyFormat.format(summary.totalDiscountRedeemed)}',
        );

        if (stackVertically) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              salesPanel,
              const SizedBox(height: AppSpacing.md),
              loyaltyPanel,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: salesPanel),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: loyaltyPanel),
          ],
        );
      },
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.title,
    required this.primaryValue,
    required this.secondaryLine,
  });

  final String title;
  final String primaryValue;
  final String secondaryLine;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              primaryValue,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              secondaryLine,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
