import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/loans/application/loan_providers.dart';
import 'package:billing_baba/features/loans/models/loan_models.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoanAccountPicker extends ConsumerWidget {
  const LoanAccountPicker({
    super.key,
    required this.selectedAccountId,
    required this.onChanged,
    this.hint = 'Select loan account',
  });

  final String? selectedAccountId;
  final ValueChanged<String?> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(loanAccountsHydrationProvider);
    final accountsAsync = ref.watch(loanAccountsStreamProvider);
    final hydration = ref.watch(loanAccountsHydrationProvider);

    return accountsAsync.when(
      data: (accounts) => _PickerBody(
        accounts: accounts,
        hint: hint,
        selectedAccountId: selectedAccountId,
        onChanged: onChanged,
        isHydrating: hydration.isLoading,
      ),
      loading: () => _loadingChip(hint),
      error: (_, __) => SaleFilterDropdown(
        label: hint,
        options: const ['Could not load loan accounts'],
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
    required this.hint,
    required this.selectedAccountId,
    required this.onChanged,
    required this.isHydrating,
  });

  final List<LoanAccountDto> accounts;
  final String hint;
  final String? selectedAccountId;
  final ValueChanged<String?> onChanged;
  final bool isHydrating;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return Text(
        isHydrating ? 'Loading loan accounts…' : 'No loan accounts yet',
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      );
    }

    final names = accounts.map((a) => a.name).toList();
    final ids = accounts.map((a) => a.id).toList();
    final selectedIndex =
        selectedAccountId == null ? -1 : ids.indexOf(selectedAccountId!);
    final selectedLabel = selectedIndex >= 0 ? names[selectedIndex] : hint;

    return SaleFilterDropdown(
      label: hint,
      options: names,
      selected: selectedLabel,
      onSelected: (value) {
        final index = names.indexOf(value);
        onChanged(index >= 0 ? ids[index] : null);
      },
    );
  }
}
