import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_fa_filter_bar.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_fa_summary_card.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_fa_table.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_section_async_content.dart';
import 'package:billing_baba/features/purchases/providers/purchase_fa_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _successSnackBarColor = Color(0xFF2E7D32);

class PurchaseFaPage extends ConsumerStatefulWidget {
  const PurchaseFaPage({super.key});

  @override
  ConsumerState<PurchaseFaPage> createState() => _PurchaseFaPageState();
}

class _PurchaseFaPageState extends ConsumerState<PurchaseFaPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(purchaseFaProvider.notifier).refresh();
      _showPendingSuccessMessage();
    });
  }

  void _showPendingSuccessMessage() {
    final message = ref.read(purchaseFaSaveSuccessMessageProvider);
    if (message == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successSnackBarColor,
      ),
    );
    ref.read(purchaseFaSaveSuccessMessageProvider.notifier).setMessage(null);
  }

  @override
  Widget build(BuildContext context) {
    final faAsync = ref.watch(purchaseFaProvider);

    ref.listen<String?>(purchaseFaSaveSuccessMessageProvider, (
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
              currentRoute: AppRoutes.purchaseFa,
              onSettingsTap: () => debugPrint('Settings tapped'),
            ),
            const SizedBox(height: AppSpacing.md),
            PurchaseSectionAsyncContent(
              value: faAsync,
              onRetry: () => ref.read(purchaseFaProvider.notifier).refresh(),
              builder: (_) => const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PurchaseFaFilterBar(),
                  SizedBox(height: AppSpacing.md),
                  PurchaseFaSummaryCard(),
                  SizedBox(height: AppSpacing.md),
                  PurchaseFaTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
