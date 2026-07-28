import 'dart:math' as math;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_nav_destinations.dart';
import 'package:flutter/material.dart';

/// Reusable mobile bottom navigation with a raised center POS action.
///
/// Layout: HOME | DASHBOARD | [POS] | ITEMS | MENU
class MobileBottomNavigation extends StatelessWidget {
  const MobileBottomNavigation({
    required this.currentTab,
    required this.onTabSelected,
    super.key,
    this.destinations,
  });

  final MobileNavTab currentTab;
  final ValueChanged<MobileNavTab> onTabSelected;
  final List<MobileNavDestination>? destinations;

  static const activeColor = Color(0xFF5D5FEF);
  static const inactiveColor = Color(0xFF9E9E9E);
  static const barHeight = 60.0;
  static const centerButtonSize = 56.0;
  static const centerButtonProtrusion = 28.0;
  static const centerButtonLowerOffset = 14.0;

  /// Bottom inset for floating actions so they sit above the raised POS button.
  static double get fabBottomInset =>
      barHeight + centerButtonProtrusion + centerButtonLowerOffset + AppSpacing.lg;

  @override
  Widget build(BuildContext context) {
    final items = destinations ?? MobileNavDestinations.visible();
    final center = MobileNavDestinations.centerAction(items);
    final sides = MobileNavDestinations.sideDestinations(items);
    final leftItems = sides.take(2).toList();
    final rightItems = sides.length > 2
        ? sides.sublist(2)
        : <MobileNavDestination>[];

    return SafeArea(
      top: false,
      child: SizedBox(
        height: barHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: barHeight,
                  child: Row(
                    children: [
                      for (final destination in leftItems)
                        Expanded(
                          child: _SideNavItem(
                            destination: destination,
                            isSelected: destination.tab == currentTab,
                            onTap: () => onTabSelected(destination.tab),
                          ),
                        ),
                      const Expanded(child: SizedBox.shrink()),
                      for (final destination in rightItems)
                        Expanded(
                          child: _SideNavItem(
                            destination: destination,
                            isSelected: destination.tab == currentTab,
                            onTap: () => onTabSelected(destination.tab),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (center != null)
              Positioned(
                top: -(centerButtonProtrusion - centerButtonLowerOffset),
                left: 0,
                right: 0,
                child: Center(
                  child: _CenterPosButton(
                    destination: center,
                    isSelected: center.tab == currentTab,
                    onTap: () => onTabSelected(center.tab),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final MobileNavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? MobileBottomNavigation.activeColor
        : MobileBottomNavigation.inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? destination.selectedIcon : destination.icon,
                color: color,
                size: AppIconSize.lg,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                destination.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterPosButton extends StatelessWidget {
  const _CenterPosButton({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final MobileNavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const color = MobileBottomNavigation.activeColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: MobileBottomNavigation.centerButtonSize + 8,
          height: MobileBottomNavigation.centerButtonSize + 20,
          child: Column(
            children: [
              Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: MobileBottomNavigation.centerButtonSize,
                  height: MobileBottomNavigation.centerButtonSize,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle: -math.pi / 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          destination.selectedIcon,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          destination.label,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                                letterSpacing: 0.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
