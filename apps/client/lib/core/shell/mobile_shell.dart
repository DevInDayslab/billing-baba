import 'package:billing_baba/core/platform/mobile_platform_scope.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_nav_destinations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Authenticated mobile shell with bottom navigation (Home, Dashboard, POS, Items, Menu).
class MobileShell extends StatelessWidget {
  const MobileShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentTab = MobileNavDestinations.tabForLocation(location);

    return MobilePlatformScope(
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: child,
        bottomNavigationBar: MobileBottomNavigation(
          currentTab: currentTab,
          onTabSelected: (tab) {
            final destination = MobileNavDestinations.destinationForTab(tab);
            if (destination == null) return;
            if (destination.route == location) return;
            context.go(destination.route);
          },
        ),
      ),
    );
  }
}
