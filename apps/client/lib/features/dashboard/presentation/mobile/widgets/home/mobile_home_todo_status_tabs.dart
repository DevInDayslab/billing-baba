import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_todo_filters.dart';
import 'package:flutter/material.dart';

/// Status filter tabs for the mobile home todo tab.
class MobileHomeTodoStatusTabs extends StatelessWidget {
  const MobileHomeTodoStatusTabs({
    required this.selected,
    required this.overdueCount,
    required this.onChanged,
    super.key,
  });

  final DashboardTodoStatusChip selected;
  final int overdueCount;
  final ValueChanged<DashboardTodoStatusChip> onChanged;

  static const _tabs = <({String label, DashboardTodoStatusChip chip})>[
    (label: 'All', chip: DashboardTodoStatusChip.all),
    (label: 'Today', chip: DashboardTodoStatusChip.today),
    (label: 'Overdue', chip: DashboardTodoStatusChip.overdue),
    (label: 'Pending', chip: DashboardTodoStatusChip.pending),
    (label: 'Completed', chip: DashboardTodoStatusChip.completed),
  ];

  int get _selectedIndex {
    final index = _tabs.indexWhere((tab) => tab.chip == selected);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final selectedIndex = _selectedIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: RepaintBoundary(
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.chipInactive.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.chipBorder),
          ),
          padding: const EdgeInsets.all(3),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / _tabs.length;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOutCubic,
                    left: selectedIndex * tabWidth,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: AppColors.chipBorder.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < _tabs.length; i++)
                        Expanded(
                          child: _TodoTabLabel(
                            label: _tabs[i].label,
                            isSelected: selectedIndex == i,
                            activeColor: primary,
                            badgeCount:
                                _tabs[i].chip ==
                                    DashboardTodoStatusChip.overdue
                                ? overdueCount
                                : 0,
                            onTap: () => onChanged(_tabs[i].chip),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TodoTabLabel extends StatelessWidget {
  const _TodoTabLabel({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        splashColor: activeColor.withValues(alpha: 0.08),
        highlightColor: activeColor.withValues(alpha: 0.04),
        child: SizedBox(
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                style: AppTypography.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : AppColors.textSecondary,
                  height: 1.1,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: AppTypography.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
