import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/hidden_ledger/models/short_payment_handling.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Prompts the seller when paid amount is less than the invoice / due total.
Future<ShortPaymentHandling?> showShortPaymentHandlingDialog(
  BuildContext context, {
  required double paidAmount,
  required double targetAmount,
  bool allowHiddenLedger = true,
}) async {
  final shortfall = (targetAmount - paidAmount).clamp(0, double.infinity);
  if (shortfall <= 0) return ShortPaymentHandling.officialDue;

  final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  return showDialog<ShortPaymentHandling>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Short Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Received ${currency.format(paidAmount)} against '
            '${currency.format(targetAmount)}.',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Shortfall: ${currency.format(shortfall)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('How should the remaining amount be recorded?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(ShortPaymentHandling.officialDue),
          child: const Text('Add to Official Due'),
        ),
        if (allowHiddenLedger)
          FilledButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(ShortPaymentHandling.hiddenLedger),
            child: const Text('Add to Hidden Ledger'),
          ),
      ],
    ),
  );
}
