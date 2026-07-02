import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/dashboard/presentation/models/sidebar_menu.dart';

/// Route matching helpers for sidebar active states.
abstract final class SidebarRouteUtils {
  static bool isItemActive(String location, SidebarMenuItem item) {
    if (item.route != null && matchesRoute(location, item.route!)) {
      return true;
    }
    for (final child in item.children) {
      if (isItemActive(location, child)) return true;
    }
    return false;
  }

  static bool matchesRoute(String location, String route) {
    if (location == route) return true;

    if (route == AppRoutes.saleInvoices) {
      return location == AppRoutes.addSale ||
          location.startsWith('${AppRoutes.editSale}/');
    }

    if (route == AppRoutes.saleReturnCreditNote) {
      return location == AppRoutes.addCreditNote;
    }

    if (route == AppRoutes.items) {
      return location == AppRoutes.items;
    }

    return false;
  }

  /// Returns section ids that should be expanded for [location].
  static Set<String> expandedSectionsFor(String location) {
    final expanded = <String>{};
    for (final item in SidebarMenu.items) {
      if (item.isExpandable && isItemActive(location, item)) {
        expanded.add(item.id);
      }
    }
    return expanded;
  }
}
