import 'dart:async';

import 'package:billing_baba/core/platform/mobile_platform_scope.dart';
import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/shared/image/image_startup_warmup.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_nav_destinations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Authenticated mobile shell with bottom navigation (Home, Dashboard, POS, Items, Menu).
class MobileShell extends ConsumerStatefulWidget {
  const MobileShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends ConsumerState<MobileShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final businessId = ref.read(sidebarBusinessProvider).id;
      if (businessId != null && businessId.isNotEmpty) {
        unawaited(
          ref.read(imageStartupWarmupProvider).run(businessId: businessId),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentTab = MobileNavDestinations.tabForLocation(location);
    final hideBottomNav = location == AppRoutes.pos;

    return MobilePlatformScope(
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: widget.child,
        bottomNavigationBar: hideBottomNav
            ? null
            : MobileBottomNavigation(
                currentTab: currentTab,
                onTabSelected: (tab) {
                  final destination = MobileNavDestinations.destinationForTab(
                    tab,
                  );
                  if (destination == null) return;
                  if (destination.route == location) return;
                  context.go(destination.route);
                },
              ),
      ),
    );
  }
}
