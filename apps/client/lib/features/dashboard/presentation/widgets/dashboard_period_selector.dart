import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:flutter/material.dart';

class DashboardPeriodSelector extends StatefulWidget {
  const DashboardPeriodSelector({
    required this.period,
    required this.onChanged,
    super.key,
  });

  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onChanged;

  @override
  State<DashboardPeriodSelector> createState() =>
      _DashboardPeriodSelectorState();
}

class _DashboardPeriodSelectorState extends State<DashboardPeriodSelector> {
  final _menuController = MenuController();

  static const List<DashboardPeriod> _periods = [
    DashboardPeriod.today,
    DashboardPeriod.thisWeek,
    DashboardPeriod.thisMonth,
    DashboardPeriod.thisYear,
  ];

  void _select(DashboardPeriod period) {
    widget.onChanged(period);
    _menuController.close();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        elevation: WidgetStateProperty.all(8),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        ),
        backgroundColor: WidgetStateProperty.all(AppColors.surface),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        ),
      ),
      menuChildren: [
        for (final period in _periods)
          MenuItemButton(
            onPressed: () => _select(period),
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(
                const Size(160, 40),
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (period == widget.period) {
                  return AppColors.background;
                }
                if (states.contains(WidgetState.hovered)) {
                  return AppColors.background.withValues(alpha: 0.7);
                }
                return null;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (period == widget.period) {
                  return AppColors.textPrimary;
                }
                return AppColors.textSecondary;
              }),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                period.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: period == widget.period
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
      ],
      child: Material(
        color: AppColors.background,
        borderRadius: AppRadius.lgBorder,
        child: InkWell(
          onTap: () {
            if (_menuController.isOpen) {
              _menuController.close();
            } else {
              _menuController.open();
            }
          },
          borderRadius: AppRadius.lgBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.period.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
