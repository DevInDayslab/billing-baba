import 'dart:math';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shows the payment-pending confirmation dialog after a mock checkout.
Future<void> showPaymentPendingDialog(
  BuildContext context, {
  required double amount,
}) {
  final transactionId = (Random().nextInt(9000000) + 1000000).toString();
  final formattedAmount =
      '₹${NumberFormat('#,##0.##', 'en_IN').format(amount)}';

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: PaymentPendingDialog(
        transactionId: transactionId,
        amount: formattedAmount,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    ),
  );
}

class PaymentPendingDialog extends StatelessWidget {
  const PaymentPendingDialog({
    required this.transactionId,
    required this.amount,
    required this.onDismiss,
    super.key,
  });

  final String transactionId;
  final String amount;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
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
                  Icons.schedule,
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
              _InfoRow(label: 'Transaction ID', value: transactionId),
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(label: 'Amount', value: amount),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onDismiss,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 4,
                    ),
                  ),
                  child: const Text('Okay, Got it!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
