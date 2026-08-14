import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_controller.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date range + quick period filters for the transaction details tab.
class MobileHomeTransactionDateFilters extends StatelessWidget {
  const MobileHomeTransactionDateFilters({
    required this.dateRange,
    required this.quickPeriod,
    required this.onDateRangeChanged,
    required this.onQuickPeriodChanged,
    super.key,
  });

  final DateTimeRange dateRange;
  final MobileHomeTransactionQuickPeriod quickPeriod;
  final ValueChanged<DateTimeRange> onDateRangeChanged;
  final ValueChanged<MobileHomeTransactionQuickPeriod> onQuickPeriodChanged;

  static final _dateFormat = DateFormat('d MMM yyyy');

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    onDateRangeChanged(picked);
    onQuickPeriodChanged(MobileHomeTransactionQuickPeriod.custom);
  }

  Future<void> _pickQuickPeriod(BuildContext context) async {
    final selected =
        await showMobileOptionSheet<MobileHomeTransactionQuickPeriod>(
          context: context,
          title: 'Quick filter',
          selected: quickPeriod,
          options: [
            for (final period in MobileHomeTransactionQuickPeriod.values)
              MobileOption(value: period, label: period.label),
          ],
        );
    if (selected == null) return;
    onQuickPeriodChanged(selected);
    if (selected != MobileHomeTransactionQuickPeriod.custom) {
      onDateRangeChanged(dateRangeForHomeQuickPeriod(selected));
    }
  }

  String _rangeLabel() {
    final start = _dateFormat.format(dateRange.start);
    final end = _dateFormat.format(dateRange.end);
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _FilterButton(
              icon: Icons.calendar_today_outlined,
              label: _rangeLabel(),
              trailing: Icons.keyboard_arrow_down_rounded,
              onTap: () => unawaited(_pickDateRange(context)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: _FilterButton(
              label: quickPeriod.label,
              trailing: Icons.keyboard_arrow_down_rounded,
              onTap: () => unawaited(_pickQuickPeriod(context)),
              accent: primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.trailing,
    this.accent,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final IconData? trailing;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.buttonBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.buttonBorder,
        child: Ink(
          height: 42,
          decoration: BoxDecoration(
            borderRadius: AppRadius.buttonBorder,
            border: Border.all(color: AppColors.chipBorder),
            boxShadow: AppShadows.subtle,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: accent ?? AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null)
                Icon(
                  trailing,
                  size: 18,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
