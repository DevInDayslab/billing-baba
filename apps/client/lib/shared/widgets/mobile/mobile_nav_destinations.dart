import 'package:billing_baba/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Primary bottom-navigation destinations for the mobile shell.
enum MobileNavTab {
  home,
  items,
  pos,
  parties,
  reports,
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
///
/// Layout: Home | Items | [POS] | Parties | Reports
abstract final class MobileNavDestinations {
  static const List<MobileNavDestination> all = [
    MobileNavDestination(
      tab: MobileNavTab.home,
      label: 'Home',
      route: AppRoutes.home,
      icon: LucideIcons.house,
      selectedIcon: LucideIcons.house,
    ),
    MobileNavDestination(
      tab: MobileNavTab.items,
      label: 'Items',
      route: AppRoutes.items,
      icon: LucideIcons.package,
      selectedIcon: LucideIcons.package,
    ),
    MobileNavDestination(
      tab: MobileNavTab.pos,
      label: 'POS',
      route: AppRoutes.saleScreen,
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale_rounded,
      isCenterAction: true,
    ),
    MobileNavDestination(
      tab: MobileNavTab.parties,
      label: 'Parties',
      route: AppRoutes.parties,
      icon: LucideIcons.users,
      selectedIcon: LucideIcons.users,
    ),
    MobileNavDestination(
      tab: MobileNavTab.reports,
      label: 'Reports',
      route: AppRoutes.reports,
      icon: LucideIcons.chartColumn,
      selectedIcon: LucideIcons.chartColumn,
    ),
  ];

  /// Destinations visible in the bottom bar.
  static List<MobileNavDestination> visible() => all;

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
    if (location.startsWith(AppRoutes.pos) ||
        location.startsWith(AppRoutes.saleScreen)) {
      return MobileNavTab.pos;
    }
    if (location.startsWith(AppRoutes.parties)) return MobileNavTab.parties;
    if (location.startsWith(AppRoutes.reports)) return MobileNavTab.reports;
    if (location.startsWith(AppRoutes.items)) return MobileNavTab.items;
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
