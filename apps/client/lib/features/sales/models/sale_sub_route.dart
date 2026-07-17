import 'package:billing_baba/core/router/app_routes.dart';

/// A sale sub-section route with display label.
class SaleSubRoute {
  const SaleSubRoute({
    required this.route,
    required this.label,
    this.pageTitle,
  });

  final String route;
  final String label;
  final String? pageTitle;
}

/// Sale sub-pages shown in the sidebar and page title switcher.
abstract final class SaleSubRoutes {
  static const items = [
    SaleSubRoute(route: AppRoutes.saleInvoices, label: 'Sale Invoices'),
    SaleSubRoute(
      route: AppRoutes.saleEstimateQuotation,
      label: 'Estimate/Quotation',
    ),
    SaleSubRoute(
      route: AppRoutes.saleProformaInvoice,
      label: 'Proforma Invoice',
    ),
    SaleSubRoute(route: AppRoutes.salePaymentIn, label: 'Payment-In'),
    SaleSubRoute(route: AppRoutes.saleOrder, label: 'Sale Order'),
    SaleSubRoute(
      route: AppRoutes.saleDeliveryChallan,
      label: 'Delivery Challan',
    ),
    SaleSubRoute(
      route: AppRoutes.saleJobWorkOut,
      label: 'Job Work Out (Challan)',
    ),
    SaleSubRoute(
      route: AppRoutes.saleReturnCreditNote,
      label: 'Sale Return/Credit Note',
      pageTitle: 'Sale Return',
    ),
    SaleSubRoute(route: AppRoutes.saleFa, label: 'Sale FA'),
    SaleSubRoute(route: AppRoutes.crmLeads, label: 'Leads'),
    SaleSubRoute(route: AppRoutes.crmContacts, label: 'Contacts'),
    SaleSubRoute(route: AppRoutes.crmDeals, label: 'Deals'),
  ];

  static String labelForRoute(String route) {
    for (final item in items) {
      if (item.route == route) return item.pageTitle ?? item.label;
    }
    return items.first.pageTitle ?? items.first.label;
  }
}
