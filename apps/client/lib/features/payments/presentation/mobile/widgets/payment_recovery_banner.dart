import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/payments/application/payment_recovery_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentRecoveryBanner extends ConsumerWidget {
  const PaymentRecoveryBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(paymentRecoveryPendingProvider);
    if (!pending) return const SizedBox.shrink();

    return MaterialBanner(
      backgroundColor: AppColors.warningSoft,
      content: const Text(
        'Payment verification pending… Retrying automatically.',
      ),
      actions: [
        TextButton(
          onPressed: () => ref
              .read(paymentRecoveryServiceProvider)
              .recoverPending(),
          child: const Text('Retry now'),
        ),
      ],
    );
  }
}
