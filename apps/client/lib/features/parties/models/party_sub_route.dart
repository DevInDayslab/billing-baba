import 'package:billing_baba/core/router/app_routes.dart';

/// A parties sub-section route with display label.
class PartySubRoute {
  const PartySubRoute({
    required this.route,
    required this.label,
  });

  final String route;
  final String label;
}

/// Parties sub-pages shown in the page title switcher.
abstract final class PartySubRoutes {
  static const items = [
    PartySubRoute(route: AppRoutes.partyDetails, label: 'Parties'),
    PartySubRoute(route: AppRoutes.partyGroups, label: 'Groups'),
    PartySubRoute(route: AppRoutes.partyHiddenLedger, label: 'Hidden Ledger'),
  ];

  static String labelForRoute(String route) {
    for (final item in items) {
      if (item.route == route) return item.label;
    }
    return items.first.label;
  }
}
