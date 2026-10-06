import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Single-card segmented control with sliding active highlight and indicator.
class MobileHomeTabBar extends StatelessWidget {
  const MobileHomeTabBar({
    required this.activeView,
    required this.onChanged,
    this.alertsBadgeCount = 0,
    super.key,
  });

  final MobileHomeView activeView;
  final ValueChanged<MobileHomeView> onChanged;
  final int alertsBadgeCount;

  static const List<
    ({
      MobileHomeView view,
      IconData icon,
      String label,
    })
  >
  _segments = [
    (
      view: MobileHomeView.businessOverview,
      icon: LucideIcons.chartColumn,
      label: 'Business\nOverview',
    ),
    (
      view: MobileHomeView.transactionDetails,
      icon: LucideIcons.receipt,
      label: 'Transaction\nDetails',
    ),
    (
      view: MobileHomeView.alerts,
      icon: LucideIcons.listChecks,
      label: 'Todo',
    ),
  ];

  int get _activeIndex =>
      _segments.indexWhere((segment) => segment.view == activeView).clamp(0, 2);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final activeIndex = _activeIndex;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(color: AppColors.chipBorder),
          boxShadow: AppShadows.card,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / _segments.length;
            const indicatorWidth = 48.0;

            return ClipRRect(
              borderRadius: AppRadius.cardBorder,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOutCubic,
                    left: activeIndex * tabWidth,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.tabActiveTint,
                      ),
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        for (var i = 0; i < _segments.length; i++) ...[
                          if (i > 0)
                            Container(
                              width: 1,
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              color: AppColors.divider,
                            ),
                          Expanded(
                            child: _Segment(
                              icon: _segments[i].icon,
                              label: _segments[i].label,
                              isActive: activeIndex == i,
                              activeColor: primary,
                              badgeCount:
                                  _segments[i].view == MobileHomeView.alerts
                                  ? alertsBadgeCount
                                  : 0,
                              onTap: () => onChanged(_segments[i].view),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOutCubic,
                    left:
                        activeIndex * tabWidth +
                        (tabWidth - indicatorWidth) / 2,
                    bottom: 6,
                    width: indicatorWidth,
                    height: 2.5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? activeColor : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      icon,
                      key: ValueKey('$icon-$isActive'),
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -16,
                      top: -8,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 18),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.surface,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          textAlign: TextAlign.center,
                          style: AppTypography.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                style: AppTypography.inter(
                  fontSize: 10.5,
                  color: isActive ? activeColor : AppColors.textPrimary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  height: 1.15,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
