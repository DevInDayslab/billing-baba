import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/application/purchase_orders_provider.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_order_filter_bar.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_order_summary_card.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_order_table.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_section_async_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _successSnackBarColor = Color(0xFF2E7D32);

class DesktopPurchaseOrderPage extends ConsumerStatefulWidget {
  const DesktopPurchaseOrderPage({super.key});

  @override
  ConsumerState<DesktopPurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends ConsumerState<DesktopPurchaseOrderPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(purchaseOrdersProvider.notifier).refresh();
      _showPendingSuccessMessage();
    });
  }

  void _showPendingSuccessMessage() {
    final message = ref.read(purchaseOrderSaveSuccessMessageProvider);
    if (message == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successSnackBarColor,
      ),
    );
    ref.read(purchaseOrderSaveSuccessMessageProvider.notifier).setMessage(null);
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(purchaseOrdersProvider);

    ref.listen<String?>(purchaseOrderSaveSuccessMessageProvider, (
      previous,
      next,
    ) {
      if (next == null) return;
      _showPendingSuccessMessage();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PurchasePageTitleBar(
              currentRoute: AppRoutes.purchaseOrder,
              onSettingsTap: () => debugPrint('Settings tapped'),
            ),
            const SizedBox(height: AppSpacing.md),
            PurchaseSectionAsyncContent(
              value: ordersAsync,
              onRetry: () =>
                  ref.read(purchaseOrdersProvider.notifier).refresh(),
              builder: (_) => const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PurchaseOrderFilterBar(),
                  SizedBox(height: AppSpacing.md),
                  PurchaseOrderSummaryCard(),
                  SizedBox(height: AppSpacing.md),
                  PurchaseOrderTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
