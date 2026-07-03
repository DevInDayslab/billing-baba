import 'package:billing_baba/core/router/app_routes.dart';

/// A purchase sub-section route with display label.
class PurchaseSubRoute {
  const PurchaseSubRoute({
    required this.route,
    required this.label,
    this.pageTitle,
  });

  final String route;
  final String label;
  final String? pageTitle;
}

/// Purchase sub-pages shown in the sidebar and page title switcher.
abstract final class PurchaseSubRoutes {
  static const items = [
    PurchaseSubRoute(route: AppRoutes.purchaseBills, label: 'Purchase Bills'),
    PurchaseSubRoute(
      route: AppRoutes.purchasePaymentOut,
      label: 'Payment-Out',
    ),
    PurchaseSubRoute(route: AppRoutes.purchaseExpenses, label: 'Expenses'),
    PurchaseSubRoute(
      route: AppRoutes.purchaseOrder,
      label: 'Purchase Order',
      pageTitle: 'Orders',
    ),
    PurchaseSubRoute(
      route: AppRoutes.purchaseReturnDebitNote,
      label: 'Purchase Return/ Dr. Note',
      pageTitle: 'Purchase Return',
    ),
    PurchaseSubRoute(route: AppRoutes.purchaseFa, label: 'Purchase FA'),
  ];

  static String labelForRoute(String route) {
    for (final item in items) {
      if (item.route == route) return item.pageTitle ?? item.label;
    }
    return items.first.pageTitle ?? items.first.label;
  }
}
