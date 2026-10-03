import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_nav_destinations.dart';
import 'package:flutter/material.dart';

/// Reusable mobile bottom navigation with a raised center POS action.
///
/// Layout: Home | Items | [POS] | Parties | Reports
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

  static Color activeColor(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static const Color inactiveColor = AppColors.navInactive;
  static const barHeight = 58.0;
  static const centerButtonSize = 52.0;
  static const centerButtonProtrusion = 24.0;
  static const centerButtonLowerOffset = 12.0;

  /// Bottom inset for floating actions so they sit above the raised POS button.
  static double get fabBottomInset =>
      barHeight +
      centerButtonProtrusion +
      centerButtonLowerOffset +
      AppSpacing.lg;

  /// Bottom offset for floating actions sitting above the shell nav bar.
  static double floatingActionBottomOffset(BuildContext context) {
    return barHeight + MediaQuery.paddingOf(context).bottom + AppSpacing.sm;
  }

  /// Bottom scroll padding so the last list item clears the floating nav bar
  /// (shell uses [Scaffold.extendBody]).
  static double contentBottomPadding(BuildContext context) {
    return barHeight + MediaQuery.paddingOf(context).bottom + AppSpacing.xl;
  }

  /// Extra scroll padding so list content clears a bottom floating action.
  static double scrollBottomPadding(
    BuildContext context, {
    double floatingActionHeight = 40,
  }) {
    return floatingActionBottomOffset(context) +
        floatingActionHeight +
        AppSpacing.lg;
  }

  /// Scroll padding for screens that float a FAB above the raised POS button.
  static double fabScrollPadding({double floatingActionHeight = 52}) {
    return fabBottomInset + floatingActionHeight + AppSpacing.lg;
  }

  @override
  Widget build(BuildContext context) {
    final items = destinations ?? MobileNavDestinations.visible();
    final center = MobileNavDestinations.centerAction(items);
    final sides = MobileNavDestinations.sideDestinations(items);
    final leftItems = sides.take(2).toList();
    final rightItems = sides.length > 2
        ? sides.sublist(2)
        : <MobileNavDestination>[];
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // Paint the solid bar through the home-indicator inset; keep icons in the
    // safe content band so they are not obscured by the system gesture area.
    return ColoredBox(
      color: AppColors.surface,
      child: SizedBox(
        height: barHeight + bottomInset,
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
                  border: const Border(
                    top: BorderSide(color: AppColors.divider),
                  ),
                  boxShadow: AppShadows.navBar,
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
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
        ? MobileBottomNavigation.activeColor(context)
        : MobileBottomNavigation.inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? destination.selectedIcon : destination.icon,
                color: color,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.inter(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isSelected ? 18 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
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
    final color = MobileBottomNavigation.activeColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: MobileBottomNavigation.centerButtonSize + 8,
          height: MobileBottomNavigation.centerButtonSize + 18,
          child: Column(
            children: [
              Container(
                width: MobileBottomNavigation.centerButtonSize,
                height: MobileBottomNavigation.centerButtonSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  destination.selectedIcon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                style: AppTypography.inter(
                  color: isSelected ? color : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
