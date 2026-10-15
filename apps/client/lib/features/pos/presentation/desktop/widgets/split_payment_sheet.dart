import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:billing_baba/shared/widgets/payment_account_field.dart';
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
  final _focusNodes = <PaymentMode, FocusNode>{};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(PaymentMode mode) {
    return _controllers.putIfAbsent(mode, TextEditingController.new);
  }

  FocusNode _focusNodeFor(PaymentMode mode) {
    return _focusNodes.putIfAbsent(mode, FocusNode.new);
  }

  String _formatAmount(double amount) {
    if (amount <= 0) return '';
    return amount.toStringAsFixed(2);
  }

  void _syncController(PaymentEntry entry) {
    final focusNode = _focusNodeFor(entry.mode);
    if (focusNode.hasFocus) return;

    final controller = _controllerFor(entry.mode);
    final nextText = _formatAmount(entry.amount);
    if (controller.text != nextText) {
      controller.text = nextText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(posCartProvider().notifier);

    final activeModes = widget.payments.map((payment) => payment.mode).toSet();
    final staleModes = _controllers.keys
        .where((mode) => !activeModes.contains(mode))
        .toList();
    for (final mode in staleModes) {
      _controllers.remove(mode)?.dispose();
      _focusNodes.remove(mode)?.dispose();
    }

    for (final entry in widget.payments) {
      _syncController(entry);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
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
                        controller: _controllerFor(entry.mode),
                        focusNode: _focusNodeFor(entry.mode),
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
                PaymentAccountField(
                  paymentMode: entry.mode.name,
                  selectedAccountId: entry.bankAccountId,
                  onChanged: (id) =>
                      notifier.updatePaymentBankAccount(entry.mode, id),
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
