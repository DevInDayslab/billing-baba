import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/payment_in_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/payment_in_filter_bar.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/payment_in_summary_card.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/payment_in_table.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_page_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _addPaymentInRed = Color(0xFFE53935);

class DesktopPaymentInPage extends ConsumerWidget {
  const DesktopPaymentInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: LayoutBuilder(
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
                  currentRoute: AppRoutes.salePaymentIn,
                  addButtonLabel: 'Add Payment-In',
                  addButtonColor: _addPaymentInRed,
                  onAddTap: () => showPaymentInDialog(context),
                ),
                const SizedBox(height: AppSpacing.md),
                const PaymentInFilterBar(),
                const SizedBox(height: AppSpacing.md),
                const PaymentInSummaryCard(),
                const SizedBox(height: AppSpacing.md),
                const PaymentInTable(),
              ],
            ),
          );
        },
      ),
    );
  }
}
