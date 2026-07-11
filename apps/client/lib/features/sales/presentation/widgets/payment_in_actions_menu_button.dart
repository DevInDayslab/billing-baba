import 'package:billing_baba/features/print/presentation/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/shared/sales_action_menu_button.dart';
import 'package:billing_baba/features/sales/providers/payment_in_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentInMenuEntry {
  const PaymentInMenuEntry({
    required this.action,
    required this.label,
  });

  final String action;
  final String label;
}

class PaymentInActionsMenuButton extends ConsumerWidget {
  const PaymentInActionsMenuButton({
    required this.record,
    super.key,
  });

  final PaymentInModel record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SalesActionMenuButton(
      items: [
        for (final item in PaymentInTableActions.menuItems)
          SalesActionMenuItem(
            label: item.label,
            onSelected: () => PaymentInTableActions.handleAction(
              context,
              ref,
              record,
              item.action,
            ),
          ),
      ],
    );
  }
}

class PaymentInTableActions {
  const PaymentInTableActions._();

  static const menuItems = [
    PaymentInMenuEntry(action: 'view_edit', label: 'View/Edit'),
    PaymentInMenuEntry(action: 'open_pdf', label: 'Open PDF'),
    PaymentInMenuEntry(action: 'print', label: 'Print'),
    PaymentInMenuEntry(action: 'delete', label: 'Delete'),
    PaymentInMenuEntry(action: 'duplicate', label: 'Duplicate'),
    PaymentInMenuEntry(action: 'view_history', label: 'View History'),
  ];

  static Future<void> handleAction(
    BuildContext context,
    WidgetRef ref,
    PaymentInModel record,
    String action,
  ) async {
    final filename = VoucherPrintActions.filenameFor(record.receiptNo);
    final notifier = ref.read(paymentInRecordsProvider.notifier);

    switch (action) {
      case 'view_edit':
      case 'duplicate':
      case 'view_history':
        _showComingSoon(context, action);
      case 'open_pdf':
        await VoucherPrintActions.previewPaymentIn(
          context,
          ref,
          record.id,
          filename: filename,
        );
      case 'print':
        await VoucherPrintActions.printPaymentIn(
          context,
          ref,
          record.id,
          filename: filename,
        );
      case 'delete':
        await _confirmDelete(context, ref, record, notifier);
    }
  }

  static void _showComingSoon(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_labelForAction(action)} coming soon')),
    );
  }

  static String _labelForAction(String action) => switch (action) {
    'view_edit' => 'View/Edit',
    'duplicate' => 'Duplicate',
    'view_history' => 'View History',
    _ => 'This action',
  };

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PaymentInModel record,
    PaymentInRecords notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete payment?'),
        content: Text('Delete payment ${record.receiptNo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await notifier.deletePayment(record.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment ${record.receiptNo} deleted')),
    );
  }
}
