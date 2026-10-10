import 'package:billing_baba/core/router/app_routes.dart';

/// A utilities sub-section route with display label.
class UtilitiesSubRoute {
  const UtilitiesSubRoute({
    required this.route,
    required this.label,
  });

  final String route;
  final String label;
}

/// Utilities sub-pages shown in the sidebar.
abstract final class UtilitiesSubRoutes {
  static const items = [
    UtilitiesSubRoute(
      route: AppRoutes.utilitiesImportItems,
      label: 'Import Items',
    ),
    UtilitiesSubRoute(
      route: AppRoutes.utilitiesExportItems,
      label: 'Export Items',
    ),
    UtilitiesSubRoute(
      route: AppRoutes.utilitiesImportParties,
      label: 'Import Parties',
    ),
    UtilitiesSubRoute(
      route: AppRoutes.utilitiesBulkUpdateItems,
      label: 'Bulk Update Items',
    ),
    UtilitiesSubRoute(
      route: AppRoutes.utilitiesBarcodeGenerator,
      label: 'Barcode Generator',
    ),
  ];

  static String labelForRoute(String route) {
    for (final item in items) {
      if (item.route == route) return item.label;
    }
    return items.first.label;
  }
}
