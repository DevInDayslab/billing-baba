import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_filter_bar.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_summary_card.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_invoice_table.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_page_title_bar.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _addSaleRed = Color(0xFFE53935);

class SaleInvoicesPage extends ConsumerWidget {
  const SaleInvoicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: GestureDetector(
        onTap: () {
          final selectedId = ref.read(selectedSaleInvoiceIdProvider);
          if (selectedId == null) return;
          ref.read(selectedSaleInvoiceIdProvider.notifier).clear();
        },
        behavior: HitTestBehavior.translucent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 600
                ? AppSpacing.md
                : AppSpacing.lg;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.md,
                horizontalPadding,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SalePageTitleBar(
                    currentRoute: AppRoutes.saleInvoices,
                    addButtonLabel: 'Add Sale',
                    addButtonColor: _addSaleRed,
                    onAddTap: () => context.push(AppRoutes.addSale),
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
            );
          },
        ),
      ),
    );
  }
}
