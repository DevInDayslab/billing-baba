import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/list_panel_header.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_cart_state.dart';
import 'package:billing_baba/features/pos/models/held_bill.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

final _timeFormat = DateFormat('dd MMM yyyy, hh:mm a');

class HoldBillsPanel extends ConsumerWidget {
  const HoldBillsPanel({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const HoldBillsPanel(),
    );
  }

  Future<void> _resumeBill(
    BuildContext context,
    WidgetRef ref,
    HeldBill bill,
  ) async {
    final cart = ref.read(posCartProvider);
    if (cart.items.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Resume held bill?'),
          content: const Text('Current bill will be cleared. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }

    ref.read(posCartProvider.notifier).resumeBill(bill);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _discardBill(
    BuildContext context,
    WidgetRef ref,
    String billId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard held bill?'),
        content: const Text('This held bill will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(posCartProvider.notifier).discardHeldBill(billId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldBills = ref.watch(posCartProvider).heldBills;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
        side: const BorderSide(color: posCardBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Held Bills (${heldBills.length})',
                    style: PosStyles.panelTitleStyle,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (heldBills.isEmpty)
                const Expanded(
                  child: ListPanelEmptyState(message: 'No bills on hold'),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: heldBills.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: posCardBorder),
                    itemBuilder: (context, index) {
                      final bill = heldBills[index];
                      return _HeldBillRow(
                        bill: bill,
                        onResume: () => _resumeBill(context, ref, bill),
                        onDiscard: () => _discardBill(context, ref, bill.id),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeldBillRow extends StatelessWidget {
  const _HeldBillRow({
    required this.bill,
    required this.onResume,
    required this.onDiscard,
  });

  final HeldBill bill;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final total = heldBillTotal(bill.items);
    final itemCount = bill.items.fold(0, (sum, i) => sum + i.quantity);
    final customerLabel = bill.customerName?.trim().isNotEmpty == true
        ? bill.customerName!
        : 'Walk-in';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _timeFormat.format(bill.heldAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$itemCount items · ${_currencyFormat.format(total)}',
                  style: PosStyles.metadataStyle,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.error,
            tooltip: 'Discard',
            onPressed: onDiscard,
          ),
          const SizedBox(width: AppSpacing.xs),
          FilledButton(
            onPressed: onResume,
            style: PosButtonStyles.primaryFilled,
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }
}
