import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Mobile receive-payment flow in a rounded bottom sheet (not a full-screen dialog).
Future<void> showMobileReceivePaymentSheet({
  required BuildContext context,
  required PartyModel party,
}) {
  return showMobilePaymentSheet<void>(
    context: context,
    title: 'Receive Payment',
    subtitle: party.name,
    footer: mobilePaymentSheetFooter(
      onCancel: () => Navigator.of(context).pop(),
      onSave: () {
        // TODO(mobile): Wire to paymentInFormProvider when mobile form is ready.
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receive payment — coming soon')),
        );
      },
    ),
    builder: (sheetContext) => const _MobilePaymentFields(
      amountLabel: 'Amount Received',
      helperText: 'Record payment received from this party.',
    ),
  );
}

/// Mobile record-payment flow in a rounded bottom sheet (not a full-screen dialog).
Future<void> showMobileRecordPaymentSheet({
  required BuildContext context,
  required PartyModel party,
}) {
  return showMobilePaymentSheet<void>(
    context: context,
    title: 'Record Payment',
    subtitle: party.name,
    footer: mobilePaymentSheetFooter(
      onCancel: () => Navigator.of(context).pop(),
      onSave: () {
        // TODO(mobile): Wire to paymentOutFormProvider when mobile form is ready.
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record payment — coming soon')),
        );
      },
    ),
    builder: (sheetContext) => const _MobilePaymentFields(
      amountLabel: 'Amount Paid',
      helperText: 'Record payment made to this party.',
    ),
  );
}

class _MobilePaymentFields extends StatelessWidget {
  const _MobilePaymentFields({
    required this.amountLabel,
    required this.helperText,
  });

  final String amountLabel;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('d MMM, y').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          helperText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          decoration: InputDecoration(
            labelText: amountLabel,
            prefixText: '₹ ',
            border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          decoration: InputDecoration(
            labelText: 'Date',
            hintText: today,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
          ),
          readOnly: true,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          decoration: InputDecoration(
            labelText: 'Notes (optional)',
            border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}
