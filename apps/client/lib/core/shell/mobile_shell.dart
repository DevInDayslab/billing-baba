import 'dart:async';

import 'package:billing_baba/core/platform/mobile_platform_scope.dart';
import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/routing/mobile_document_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_controller.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/shared/image/image_startup_warmup.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_nav_destinations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Authenticated mobile shell with bottom navigation (Home, Items, POS, Parties, Reports).
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

  void _onTabSelected(MobileNavTab tab) {
    final destination = MobileNavDestinations.destinationForTab(tab);
    if (destination == null) return;

    final router = GoRouter.of(context);
    // Prefer router.state — GoRouterState.of(shell) can lag behind pushed pages.
    final location = router.state.uri.path;
    final alreadyAtRoot = location == destination.route;

    // Re-selecting Home always restores the default transactions view.
    if (tab == MobileNavTab.home) {
      ref
          .read(mobileHomeControllerProvider.notifier)
          .setView(MobileHomeView.transactionDetails);
    }

    if (!alreadyAtRoot) {
      // Switching tabs or returning from a nested route under this tab.
      context.go(destination.route);
      return;
    }

    // Path is already the tab root — still clear any leftover push history.
    while (router.canPop()) {
      router.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).state.uri.path;
    final currentTab = MobileNavDestinations.tabForLocation(location);
    final hideBottomNav =
        location == AppRoutes.pos ||
        location == AppRoutes.utilitiesAddItemsBarcode ||
        MobileDocumentRoutes.hidesBottomNavigation(location);

    return MobilePlatformScope(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.lightSystemUi,
        child: Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          body: widget.child,
          bottomNavigationBar: hideBottomNav
              ? null
              : MobileBottomNavigation(
                  currentTab: currentTab,
                  onTabSelected: _onTabSelected,
                ),
        ),
      ),
    );
  }
}
