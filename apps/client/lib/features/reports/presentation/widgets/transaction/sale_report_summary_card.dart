import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/providers/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);

class SaleReportSummaryCard extends ConsumerWidget {
  const SaleReportSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(saleReportProvider).value;
    final summary = report;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Sales Amount',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              formatReportCurrency(summary?.totalSalesAmount ?? 0),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: _cardBorder),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Received: ${formatReportCurrency(summary?.receivedAmount ?? 0)} | '
              'Balance: ${formatReportCurrency(summary?.balanceAmount ?? 0)}',
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
