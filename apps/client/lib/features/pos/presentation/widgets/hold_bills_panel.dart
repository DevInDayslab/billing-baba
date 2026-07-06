import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/list_panel_header.dart';
import 'package:billing_baba/features/pos/models/held_bill.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_styles.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_state.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldBills = ref.watch(posCartProvider).heldBills;
    final notifier = ref.read(posCartProvider.notifier);

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
                        onResume: () {
                          notifier.resumeBill(bill.id);
                          Navigator.of(context).pop();
                        },
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
  const _HeldBillRow({required this.bill, required this.onResume});

  final HeldBill bill;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final total = heldBillTotal(bill.items);
    final itemCount = bill.items.fold(0, (sum, i) => sum + i.quantity);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _timeFormat.format(bill.heldAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
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
