import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/payment_in_filter_bar.dart';
import 'package:billing_baba/features/sales/presentation/widgets/payment_in_summary_card.dart';
import 'package:billing_baba/features/sales/presentation/widgets/payment_in_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_page_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentInPage extends ConsumerWidget {
  const PaymentInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SalePageTitleBar(
              currentRoute: AppRoutes.salePaymentIn,
              onSettingsTap: () => debugPrint('Settings tapped'),
            ),
            const SizedBox(height: AppSpacing.md),
            const PaymentInFilterBar(),
            const SizedBox(height: AppSpacing.md),
            const PaymentInSummaryCard(),
            const SizedBox(height: AppSpacing.md),
            const PaymentInTable(),
          ],
        ),
      ),
    );
  }
}
