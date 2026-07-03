import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_fa_table.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/providers/purchase_fa_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_empty_state_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _addCtaOrange = Color(0xFFFF9800);

class PurchaseFaPage extends ConsumerWidget {
  const PurchaseFaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(purchaseFaRecordsProvider);
    final isEmpty = records.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PurchasePageTitleBar(
              currentRoute: AppRoutes.purchaseFa,
              addButtonLabel: isEmpty ? null : 'Add Purchase FA',
              onAddTap: isEmpty
                  ? null
                  : () => context.push(AppRoutes.addPurchaseFa),
              onSettingsTap: () => debugPrint('Settings tapped'),
            ),
            const SizedBox(height: AppSpacing.md),
            if (isEmpty)
              SaleEmptyStateCard(
                illustration: const SaleGeometricIllustration(
                  circleColor: Color(0xFFE3F2FD),
                  shapeColor: Color(0xFF64B5F6),
                  shapeIcon: Icons.shopping_cart_outlined,
                ),
                description:
                    'You can manage purchase of all your fixed assets here.',
                buttonLabel: 'Add Your First Purchase Of A Fixed Asset Here',
                buttonColor: _addCtaOrange,
                onPressed: () => context.push(AppRoutes.addPurchaseFa),
              )
            else
              const PurchaseFaTable(),
          ],
        ),
      ),
    );
  }
}
