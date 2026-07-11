import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_bill_filter_bar.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_bill_summary_card.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_bill_table.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_section_async_content.dart';
import 'package:billing_baba/features/purchases/providers/purchase_bills_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _successSnackBarColor = Color(0xFF2E7D32);

class PurchaseBillsPage extends ConsumerStatefulWidget {
  const PurchaseBillsPage({super.key});

  @override
  ConsumerState<PurchaseBillsPage> createState() => _PurchaseBillsPageState();
}

class _PurchaseBillsPageState extends ConsumerState<PurchaseBillsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(purchaseBillsProvider.notifier).refresh();
      _showPendingSuccessMessage();
    });
  }

  void _showPendingSuccessMessage() {
    final message = ref.read(purchaseBillSaveSuccessMessageProvider);
    if (message == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successSnackBarColor,
      ),
    );
    ref.read(purchaseBillSaveSuccessMessageProvider.notifier).setMessage(null);
  }

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(purchaseBillsProvider);

    ref.listen<String?>(purchaseBillSaveSuccessMessageProvider, (
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
              currentRoute: AppRoutes.purchaseBills,
              onSettingsTap: () => debugPrint('Settings tapped'),
            ),
            const SizedBox(height: AppSpacing.md),
            PurchaseSectionAsyncContent(
              value: billsAsync,
              onRetry: () => ref.read(purchaseBillsProvider.notifier).refresh(),
              builder: (_) => const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PurchaseBillFilterBar(),
                  SizedBox(height: AppSpacing.md),
                  PurchaseBillSummaryCard(),
                  SizedBox(height: AppSpacing.md),
                  PurchaseBillTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
