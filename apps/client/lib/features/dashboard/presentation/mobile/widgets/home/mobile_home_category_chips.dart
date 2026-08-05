import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:flutter/material.dart';

/// Horizontally scrollable transaction category filter chips.
class MobileHomeCategoryChips extends StatelessWidget {
  const MobileHomeCategoryChips({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Set<MobileHomeTransactionFilterType> selected;
  final ValueChanged<Set<MobileHomeTransactionFilterType>> onChanged;

  static const _chips =
      <({String label, MobileHomeTransactionFilterType? type})>[
        (label: 'All', type: null),
        (label: 'Sale', type: MobileHomeTransactionFilterType.sale),
        (label: 'Purchase', type: MobileHomeTransactionFilterType.purchase),
        (label: 'Payment In', type: MobileHomeTransactionFilterType.paymentIn),
        (
          label: 'Payment Out',
          type: MobileHomeTransactionFilterType.paymentOut,
        ),
        (label: 'Expense', type: MobileHomeTransactionFilterType.expense),
      ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final chip = _chips[index];
          final isAll = chip.type == null;
          final isSelected = isAll
              ? selected.isEmpty
              : selected.length == 1 && selected.contains(chip.type);

          return _CategoryChip(
            label: chip.label,
            isSelected: isSelected,
            primary: primary,
            onTap: () {
              if (isAll) {
                onChanged({});
              } else {
                onChanged({chip.type!});
              }
            },
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? primary : AppColors.chipInactive,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppTypography.inter(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
