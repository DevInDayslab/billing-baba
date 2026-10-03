import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/application/purchase_return_provider.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_return_filter_bar.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_return_table.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_section_async_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _successSnackBarColor = Color(0xFF2E7D32);

class DesktopPurchaseReturnPage extends ConsumerStatefulWidget {
  const DesktopPurchaseReturnPage({super.key});

  @override
  ConsumerState<DesktopPurchaseReturnPage> createState() =>
      _PurchaseReturnPageState();
}

class _PurchaseReturnPageState
    extends ConsumerState<DesktopPurchaseReturnPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPendingSuccessMessage();
    });
  }

  void _showPendingSuccessMessage() {
    final message = ref.read(purchaseReturnSaveSuccessMessageProvider);
    if (message == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successSnackBarColor,
      ),
    );
    ref
        .read(purchaseReturnSaveSuccessMessageProvider.notifier)
        .setMessage(null);
  }

  @override
  Widget build(BuildContext context) {
    final returnsAsync = ref.watch(purchaseReturnsProvider);

    ref.listen<String?>(purchaseReturnSaveSuccessMessageProvider, (
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
              currentRoute: AppRoutes.purchaseReturnDebitNote,
            ),
            const SizedBox(height: AppSpacing.md),
            PurchaseSectionAsyncContent(
              value: returnsAsync,
              onRetry: () =>
                  ref.read(purchaseReturnsProvider.notifier).refresh(),
              builder: (_) => const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PurchaseReturnFilterBar(),
                  SizedBox(height: AppSpacing.md),
                  PurchaseReturnTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
