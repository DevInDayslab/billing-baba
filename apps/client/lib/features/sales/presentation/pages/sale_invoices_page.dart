import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_filter_bar.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_summary_card.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_page_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaleInvoicesPage extends ConsumerWidget {
  const SaleInvoicesPage({super.key});

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
              currentRoute: AppRoutes.saleInvoices,
              onSettingsTap: () => debugPrint('Settings tapped'),
            ),
            const SizedBox(height: AppSpacing.md),
            const SaleInvoiceFilterBar(),
            const SizedBox(height: AppSpacing.md),
            const SaleInvoiceSummaryCard(),
            const SizedBox(height: AppSpacing.md),
            const SaleInvoiceTable(),
          ],
        ),
      ),
    );
  }
}
