import 'package:billing_baba/core/router/app_routes.dart';
import 'package:flutter/material.dart';

/// Mobile-only bottom-nav visibility flags.
///
/// Kept separate from desktop shell sidebar visibility so mobile navigation
/// does not depend on desktop shell configuration.
abstract final class MobileNavVisibility {
  static const hideMenu = false;
}

/// Primary bottom-navigation destinations for the mobile shell.
enum MobileNavTab {
  home,
  dashboard,
  pos,
  items,
  menu,
}

/// Route and icon metadata for a [MobileNavTab].
class MobileNavDestination {
  const MobileNavDestination({
    required this.tab,
    required this.label,
    required this.route,
    required this.icon,
    required this.selectedIcon,
    this.isCenterAction = false,
  });

  final MobileNavTab tab;
  final String label;
  final String route;
  final IconData icon;
  final IconData selectedIcon;

  /// Elevated center action (POS) that overlaps the bar.
  final bool isCenterAction;
}

/// Default mobile bottom-nav configuration aligned with [AppRoutes].
abstract final class MobileNavDestinations {
  static const List<MobileNavDestination> all = [
    MobileNavDestination(
      tab: MobileNavTab.home,
      label: 'HOME',
      route: AppRoutes.home,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    MobileNavDestination(
      tab: MobileNavTab.dashboard,
      label: 'DASHBOARD',
      route: AppRoutes.reports,
      icon: Icons.show_chart_outlined,
      selectedIcon: Icons.show_chart_rounded,
    ),
    MobileNavDestination(
      tab: MobileNavTab.pos,
      label: 'POS',
      route: AppRoutes.pos,
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale_rounded,
      isCenterAction: true,
    ),
    MobileNavDestination(
      tab: MobileNavTab.items,
      label: 'ITEMS',
      route: AppRoutes.items,
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
    ),
    MobileNavDestination(
      tab: MobileNavTab.menu,
      label: 'MENU',
      route: AppRoutes.settings,
      icon: Icons.menu_rounded,
      selectedIcon: Icons.menu_open_rounded,
    ),
  ];

  /// Destinations visible in the bottom bar.
  static List<MobileNavDestination> visible() {
    return all.where((destination) {
      return switch (destination.tab) {
        MobileNavTab.menu => !MobileNavVisibility.hideMenu,
        _ => true,
      };
    }).toList();
  }

  static MobileNavDestination? centerAction(
    List<MobileNavDestination> destinations,
  ) {
    for (final destination in destinations) {
      if (destination.isCenterAction) return destination;
    }
    return null;
  }

  static List<MobileNavDestination> sideDestinations(
    List<MobileNavDestination> destinations,
  ) {
    return destinations.where((d) => !d.isCenterAction).toList();
  }

  /// Resolves the active tab from the current GoRouter location.
  static MobileNavTab tabForLocation(String location) {
    if (location.startsWith(AppRoutes.pos)) return MobileNavTab.pos;
    if (location.startsWith(AppRoutes.items)) return MobileNavTab.items;
    if (location.startsWith(AppRoutes.settings)) return MobileNavTab.menu;
    if (location.startsWith(AppRoutes.reports)) return MobileNavTab.dashboard;
    if (location.startsWith(AppRoutes.home)) return MobileNavTab.home;
    return MobileNavTab.home;
  }

  static MobileNavDestination? destinationForTab(MobileNavTab tab) {
    for (final destination in all) {
      if (destination.tab == tab) return destination;
    }
    return null;
  }
}
