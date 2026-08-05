import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:flutter/material.dart';

/// Segmented transaction-type tabs for the transaction details tab.
class MobileHomeTransactionTypeTabs extends StatelessWidget {
  const MobileHomeTransactionTypeTabs({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Set<MobileHomeTransactionFilterType> selected;
  final ValueChanged<Set<MobileHomeTransactionFilterType>> onChanged;

  static const _tabs =
      <({String label, MobileHomeTransactionFilterType? type})>[
        (label: 'All', type: null),
        (label: 'Sale', type: MobileHomeTransactionFilterType.sale),
        (label: 'Purchase', type: MobileHomeTransactionFilterType.purchase),
        (label: 'Payment In', type: MobileHomeTransactionFilterType.paymentIn),
        (
          label: 'Payment Out',
          type: MobileHomeTransactionFilterType.paymentOut,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++)
            Expanded(
              child: _TypeTab(
                label: _tabs[i].label,
                isSelected: _tabs[i].type == null
                    ? selected.isEmpty
                    : selected.length == 1 &&
                          selected.contains(_tabs[i].type),
                activeColor: primary,
                onTap: () {
                  if (_tabs[i].type == null) {
                    onChanged({});
                  } else {
                    onChanged({_tabs[i].type!});
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 8,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.inter(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 2.5,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
