import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/payment_out_filter_bar.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/payment_out_summary_card.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/payment_out_table.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/presentation/widgets/purchase_section_async_content.dart';
import 'package:billing_baba/features/purchases/providers/payment_out_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _successSnackBarColor = Color(0xFF2E7D32);

class PaymentOutPage extends ConsumerStatefulWidget {
  const PaymentOutPage({super.key});

  @override
  ConsumerState<PaymentOutPage> createState() => _PaymentOutPageState();
}

class _PaymentOutPageState extends ConsumerState<PaymentOutPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentOutRecordsProvider.notifier).refresh();
      _showPendingSuccessMessage();
    });
  }

  void _showPendingSuccessMessage() {
    final message = ref.read(paymentOutSaveSuccessMessageProvider);
    if (message == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successSnackBarColor,
      ),
    );
    ref.read(paymentOutSaveSuccessMessageProvider.notifier).setMessage(null);
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(paymentOutRecordsProvider);

    ref.listen<String?>(paymentOutSaveSuccessMessageProvider, (
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
              currentRoute: AppRoutes.purchasePaymentOut,
              onSettingsTap: () => debugPrint('Settings tapped'),
            ),
            const SizedBox(height: AppSpacing.md),
            PurchaseSectionAsyncContent(
              value: recordsAsync,
              onRetry: () =>
                  ref.read(paymentOutRecordsProvider.notifier).refresh(),
              builder: (_) => const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaymentOutFilterBar(),
                  SizedBox(height: AppSpacing.md),
                  PaymentOutSummaryCard(),
                  SizedBox(height: AppSpacing.md),
                  PaymentOutTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
