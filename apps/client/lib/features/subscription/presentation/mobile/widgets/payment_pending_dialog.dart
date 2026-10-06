import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_support.dart';
import 'package:billing_baba/features/subscription/application/payment_state_provider.dart';
import 'package:billing_baba/features/subscription/presentation/mobile/utils/subscription_price_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<void> showPaymentPendingDialog(
  BuildContext context, {
  required WidgetRef ref,
  required VoidCallback onRetryStatus,
  required VoidCallback onHome,
}) {
  final result = ref.read(paymentStateProvider).result;
  if (result == null) return Future.value();

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Material(
          color: AppColors.surface,
          borderRadius: AppRadius.lgBorder,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF8E1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.clock,
                    color: Colors.amber.shade800,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Payment Pending',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Your payment is being processed. This may take a few minutes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoRow(
                  label: 'Transaction ID',
                  value: result.transactionId,
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(
                  label: 'Amount',
                  value: formatSubscriptionPrice(result.amount),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _InfoRow(
                  label: 'Help',
                  value: SubscriptionCheckoutSupport.supportPhoneNumber,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onRetryStatus();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm + 4,
                      ),
                    ),
                    child: const Text('Retry Status'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onHome();
                    },
                    child: const Text('Go to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
