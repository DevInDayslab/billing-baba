import 'package:billing_baba/core/router/app_routes.dart';

/// A parties page tab route with display label.
class PartySubRoute {
  const PartySubRoute({
    required this.route,
    required this.label,
  });

  final String route;
  final String label;
}

/// Party-area routes with display labels (sidebar + search).
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
