import 'package:billing_baba/core/router/app_routes.dart';

/// A collaboration sub-section route with display label.
class CollaborationSubRoute {
  const CollaborationSubRoute({
    required this.route,
    required this.label,
  });

  final String route;
  final String label;
}

/// Collaboration sub-pages shown in the sidebar.
abstract final class CollaborationSubRoutes {
  static const items = [
    CollaborationSubRoute(
      route: AppRoutes.collaborationSyncShare,
      label: 'Sync & Share',
    ),
  ];

  static String labelForRoute(String route) {
    for (final item in items) {
      if (item.route == route) return item.label;
    }
    return items.first.label;
  }
}
