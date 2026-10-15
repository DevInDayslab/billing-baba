import 'package:billing_baba/features/bank_accounts/application/bank_account_providers.dart';
import 'package:billing_baba/shared/widgets/bank_account_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows bank account picker for non-cash payment modes.
class PaymentAccountField extends ConsumerWidget {
  const PaymentAccountField({
    super.key,
    required this.paymentMode,
    required this.selectedAccountId,
    required this.onChanged,
  });

  final String? paymentMode;
  final String? selectedAccountId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = (paymentMode ?? 'cash').toLowerCase();
    if (mode == 'cash') {
      return const SizedBox.shrink();
    }

    final defaultAccount = ref.watch(defaultBankAccountProvider);
    final effectiveId = selectedAccountId ?? defaultAccount?.id;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: BankAccountPicker(
        selectedAccountId: effectiveId,
        includeCash: false,
        hint: 'Bank account',
        onChanged: onChanged,
      ),
    );
  }
}
