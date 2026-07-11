import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/estimate_quotation_filter_bar.dart';
import 'package:billing_baba/features/sales/presentation/widgets/estimate_quotation_summary_card.dart';
import 'package:billing_baba/features/sales/presentation/widgets/estimate_quotation_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_page_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EstimateQuotationPage extends ConsumerWidget {
  const EstimateQuotationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SalePageTitleBar(
              currentRoute: AppRoutes.saleEstimateQuotation,
              addButtonLabel: 'Add Estimate',
              addButtonColor: AppColors.error,
              onAddTap: () => context.push(AppRoutes.addEstimate),
              onSettingsTap: () => debugPrint('Settings tapped'),
            ),
            const SizedBox(height: AppSpacing.md),
            const EstimateQuotationFilterBar(),
            const SizedBox(height: AppSpacing.md),
            const EstimateQuotationSummaryCard(),
            const SizedBox(height: AppSpacing.md),
            const EstimateQuotationTable(),
          ],
        ),
      ),
    );
  }
}
