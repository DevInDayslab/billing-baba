import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum HiddenLedgerRecoveryChoice {
  recoverFull,
  recoverPartial,
  ignore,
}

/// Seller-only prompt when a sale markup can recover hidden ledger balance.
Future<({HiddenLedgerRecoveryChoice choice, double? amount})?>
showHiddenLedgerRecoveryDialog(
  BuildContext context, {
  required double hiddenBalance,
  required double markupAmount,
}) async {
  final maxRecoverable = hiddenBalance < markupAmount
      ? hiddenBalance
      : markupAmount;
  if (maxRecoverable <= 0) {
    return (choice: HiddenLedgerRecoveryChoice.ignore, amount: null);
  }

  final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  final choice = await showDialog<HiddenLedgerRecoveryChoice>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Recover Hidden Ledger'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hidden balance: ${currency.format(hiddenBalance)}',
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Markup from price increase: ${currency.format(markupAmount)}',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Recover up to ${currency.format(maxRecoverable)} from hidden ledger?',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(
            dialogContext,
          ).pop(HiddenLedgerRecoveryChoice.ignore),
          child: const Text('Ignore'),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            dialogContext,
          ).pop(HiddenLedgerRecoveryChoice.recoverPartial),
          child: const Text('Recover Partial'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(
            dialogContext,
          ).pop(HiddenLedgerRecoveryChoice.recoverFull),
          child: const Text('Recover Full'),
        ),
      ],
    ),
  );

  if (choice == null) return null;
  if (choice == HiddenLedgerRecoveryChoice.ignore) {
    return (choice: choice, amount: null);
  }
  if (choice == HiddenLedgerRecoveryChoice.recoverFull) {
    return (choice: choice, amount: maxRecoverable);
  }

  if (!context.mounted) return null;
  final partialAmount = await _showPartialRecoveryDialog(
    dialogContext: context,
    maxRecoverable: maxRecoverable,
  );
  if (partialAmount == null) return null;

  return (
    choice: HiddenLedgerRecoveryChoice.recoverPartial,
    amount: partialAmount,
  );
}

Future<double?> _showPartialRecoveryDialog({
  required BuildContext dialogContext,
  required double maxRecoverable,
}) async {
  final controller = TextEditingController();
  final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final formKey = GlobalKey<FormState>();

  return showDialog<double>(
    context: dialogContext,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Partial Recovery'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}')),
          ],
          decoration: InputDecoration(
            labelText: 'Recovery amount',
            helperText: 'Max ${currency.format(maxRecoverable)}',
          ),
          validator: (value) {
            final amount = double.tryParse(value?.trim() ?? '');
            if (amount == null || amount <= 0) {
              return 'Enter a valid amount';
            }
            if (amount > maxRecoverable + 0.0001) {
              return 'Amount exceeds maximum recoverable';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState?.validate() != true) return;
            final amount = double.parse(controller.text.trim());
            Navigator.of(dialogContext).pop(amount);
          },
          child: const Text('Recover'),
        ),
      ],
    ),
  );
}
