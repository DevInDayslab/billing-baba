import 'dart:async';

import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/payments/application/payment_checkout_busy_provider.dart';
import 'package:billing_baba/features/payments/application/payment_providers.dart';
import 'package:billing_baba/features/payments/application/payment_service.dart';
import 'package:billing_baba/features/payments/domain/models/payment_models.dart';
import 'package:billing_baba/features/payments/presentation/mobile/payment_failure_screen.dart';
import 'package:billing_baba/features/payments/presentation/mobile/payment_processing_screen.dart';
import 'package:billing_baba/features/payments/presentation/mobile/payment_success_screen.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/voucher_print_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart' show Ref;
import 'package:share_plus/share_plus.dart';

/// Entry point for gateway payments from Payment In, POS, etc.
abstract final class PaymentFlowLauncher {
  static Future<PaymentResult?> start(
    BuildContext context,
    WidgetRef ref, {
    required PaymentIntent intent,
  }) async {
    ref.read(paymentCheckoutBusyProvider.notifier).begin();
    try {
      final repository = await ref.read(paymentRepositoryProvider.future);
      final service = PaymentService(repository: repository);

      if (!context.mounted) return null;

      unawaited(
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => const PaymentProcessingScreen(),
          ),
        ),
      );

      final result = await service.pay(intent);

      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) return result;

      if (result.cancelled) {
        return result;
      }

      if (!result.isSuccess) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => PaymentFailureScreen(
              message: result.failureReason ?? 'Payment failed',
              onRetry: () => unawaited(start(context, ref, intent: intent)),
            ),
          ),
        );
        return result;
      }

      refreshAfterPaymentIn(
        ref as Ref,
        context: (partyId: intent.partyId, itemIds: const []),
      );

      if (!context.mounted) return result;

      final paymentId = result.accountingPaymentId;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PaymentSuccessScreen(
            amountPaise: result.amountPaise ?? 0,
            paymentId: paymentId,
            onPrint: paymentId == null
                ? null
                : () => VoucherPrintActions.previewPaymentIn(
                    context,
                    ref,
                    paymentId,
                  ),
            onShare: paymentId == null
                ? null
                : () => SharePlus.instance.share(
                    ShareParams(text: 'Payment received — ref $paymentId'),
                  ),
          ),
        ),
      );

      return result;
    } finally {
      ref.read(paymentCheckoutBusyProvider.notifier).end();
    }
  }
}
