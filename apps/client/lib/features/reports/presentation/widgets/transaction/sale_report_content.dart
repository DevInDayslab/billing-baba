import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/sale_report_filter_bar.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/sale_report_summary_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/sale_report_title_bar.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/sale_report_transactions_table.dart';
import 'package:flutter/material.dart';

class SaleReportContent extends StatelessWidget {
  const SaleReportContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SaleReportTitleBar(),
            SizedBox(height: AppSpacing.md),
            SaleReportFilterBar(),
            SizedBox(height: AppSpacing.md),
            SaleReportSummaryCard(),
            SizedBox(height: AppSpacing.md),
            SaleReportTransactionsTable(),
          ],
        ),
      ),
    );
  }
}
