import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/bank_accounts/application/bank_account_providers.dart';
import 'package:billing_baba/features/bank_accounts/models/bank_account_models.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BankAccountPicker extends ConsumerWidget {
  const BankAccountPicker({
    super.key,
    required this.selectedAccountId,
    required this.onChanged,
    this.includeCash = true,
    this.hint = 'Select bank account',
  });

  final String? selectedAccountId;
  final ValueChanged<String?> onChanged;
  final bool includeCash;
  final String hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(bankAccountsHydrationProvider);
    final accountsAsync = ref.watch(bankAccountsStreamProvider);
    final hydration = ref.watch(bankAccountsHydrationProvider);

    return accountsAsync.when(
      data: (accounts) => _PickerBody(
        accounts: accounts,
        includeCash: includeCash,
        hint: hint,
        selectedAccountId: selectedAccountId,
        onChanged: onChanged,
        isHydrating: hydration.isLoading,
      ),
      loading: () => _loadingChip(hint),
      error: (_, __) => SaleFilterDropdown(
        label: hint,
        options: const ['Could not load accounts'],
        selected: hint,
        onSelected: (_) {},
      ),
    );
  }

  static Widget _loadingChip(String hint) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(hint, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: AppSpacing.sm),
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}

class _PickerBody extends StatelessWidget {
  const _PickerBody({
    required this.accounts,
    required this.includeCash,
    required this.hint,
    required this.selectedAccountId,
    required this.onChanged,
    required this.isHydrating,
  });

  final List<BankAccountDto> accounts;
  final bool includeCash;
  final String hint;
  final String? selectedAccountId;
  final ValueChanged<String?> onChanged;
  final bool isHydrating;

  @override
  Widget build(BuildContext context) {
    final filtered = includeCash
        ? accounts
        : accounts.where((a) => a.type == 'bank').toList();

    if (filtered.isEmpty) {
      if (isHydrating) {
        return BankAccountPicker._loadingChip(hint);
      }
      return SaleFilterDropdown(
        label: hint,
        options: const [
          'No bank accounts — add one under Sale → Cash & Bank',
        ],
        selected: hint,
        onSelected: (_) {},
      );
    }

    final labels = filtered.map((a) => a.label).toList();
    final ids = filtered.map((a) => a.id).toList();
    final selectedIndex =
        selectedAccountId == null ? -1 : ids.indexOf(selectedAccountId!);
    final selectedLabel =
        selectedIndex >= 0 ? labels[selectedIndex] : hint;

    return SaleFilterDropdown(
      label: hint,
      options: labels,
      selected: selectedLabel,
      onSelected: (label) {
        final index = labels.indexOf(label);
        onChanged(index >= 0 ? ids[index] : null);
      },
    );
  }
}
