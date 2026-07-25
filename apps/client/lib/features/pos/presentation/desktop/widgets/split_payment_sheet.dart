import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplitPaymentSheet extends ConsumerStatefulWidget {
  const SplitPaymentSheet({required this.payments, super.key});

  final List<PaymentEntry> payments;

  @override
  ConsumerState<SplitPaymentSheet> createState() => _SplitPaymentSheetState();
}

class _SplitPaymentSheetState extends ConsumerState<SplitPaymentSheet> {
  final _controllers = <PaymentMode, TextEditingController>{};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(PaymentMode mode, double amount) {
    return _controllers.putIfAbsent(
      mode,
      () => TextEditingController(
        text: amount > 0 ? amount.toStringAsFixed(2) : '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(posCartProvider.notifier);

    final activeModes = widget.payments.map((p) => p.mode).toSet();
    final staleModes = _controllers.keys
        .where((m) => !activeModes.contains(m))
        .toList();
    for (final mode in staleModes) {
      _controllers.remove(mode)?.dispose();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, color: posCardBorder),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            'Split',
            style: PosStyles.listHeaderStyle.copyWith(fontSize: 11),
          ),
        ),
        ...widget.payments.map((entry) {
          final (icon, label) = _modeDisplay(entry.mode);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 60,
                  child: Text(
                    label,
                    style: PosStyles.metadataStyle.copyWith(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controllerFor(entry.mode, entry.amount),
                    style: saleFieldTextStyle,
                    decoration: buildPosFieldDecoration().copyWith(
                      prefixText: '₹ ',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0;
                      notifier.updatePaymentAmount(entry.mode, amount);
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  (IconData, String) _modeDisplay(PaymentMode mode) {
    return switch (mode) {
      PaymentMode.cash => (Icons.payments_outlined, 'Cash'),
      PaymentMode.upi => (Icons.qr_code_2_outlined, 'UPI'),
      PaymentMode.card => (Icons.credit_card_outlined, 'Card'),
      PaymentMode.bank => (Icons.account_balance_outlined, 'Bank'),
    };
  }
}
