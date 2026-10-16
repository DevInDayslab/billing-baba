import 'package:billing_baba/core/router/app_routes.dart';

/// A module launched from the Other Products hub.
class OtherProductSubRoute {
  const OtherProductSubRoute({
    required this.route,
    required this.label,
  });

  final String route;
  final String label;
}

/// Modules reachable from Other Products (not Sale / Purchase sidebars).
abstract final class OtherProductSubRoutes {
  static const items = [
    OtherProductSubRoute(
      route: AppRoutes.otherIncome,
      label: 'Accounts',
    ),
  ];

  static String labelForRoute(String route) {
    for (final item in items) {
      if (item.route == route) return item.label;
    }
    return items.first.label;
  }

  /// Whether [location] is the hub or a nested Other Products screen.
  static bool matchesLocation(String location) {
    if (location == AppRoutes.otherProducts) return true;
    if (location.startsWith(AppRoutes.crm)) return true;
    if (location.startsWith(AppRoutes.otherProductsAccounts)) return true;
    return false;
  }
}
