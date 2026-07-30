import 'package:billing_baba/core/router/app_routes.dart';

/// A CRM sub-section route with display label.
class CrmSubRoute {
  const CrmSubRoute({required this.route, required this.label});

  final String route;
  final String label;
}

/// CRM sub-pages shown under the sidebar CRM group.
abstract final class CrmSubRoutes {
  static const items = [
    CrmSubRoute(route: AppRoutes.crmLeads, label: 'Leads'),
    CrmSubRoute(route: AppRoutes.crmContacts, label: 'Contacts'),
    CrmSubRoute(route: AppRoutes.crmDeals, label: 'Deals'),
  ];
}
