import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/collaboration/application/permission_service.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';

/// Sidebar and search visibility rules.
abstract final class NavigationPermissionRegistry {
  static bool isVisible(String route, PermissionService service) {
    // Cold start: company session may not be seeded yet. Show standard nav
    // (owner-like) so the desktop sidebar is never empty; route guards still
    // enforce real permissions once the session exists.
    if (!service.hasSession) {
      return !_isOwnerOnlyRoute(route);
    }
    if (service.hasFullAccess) return true;

    if (route == AppRoutes.home || route.startsWith('${AppRoutes.home}/')) {
      return true;
    }

    if (route == AppRoutes.partyHiddenLedger) {
      return service.canViewHiddenLedger;
    }

    if (_isOwnerOnlyRoute(route)) return false;

    final module = _moduleForNavRoute(route);
    if (module == null) return true;
    return service.canView(module);
  }

  static bool isPurchaseNavVisible(PermissionService service) {
    if (!service.hasSession || service.hasFullAccess) return true;
    return service.canView(PermissionModule.purchase) ||
        service.canView(PermissionModule.expense) ||
        service.canView(PermissionModule.paymentOut) ||
        service.canView(PermissionModule.purchaseOrder) ||
        service.canView(PermissionModule.debitNote);
  }

  static bool _isOwnerOnlyRoute(String route) {
    return route.startsWith(AppRoutes.utilities) ||
        route.startsWith(AppRoutes.developer) ||
        route.startsWith(AppRoutes.plansPricing);
  }

  static PermissionModule? _moduleForNavRoute(String route) {
    if (route.startsWith(AppRoutes.parties)) return PermissionModule.party;
    if (route.startsWith(AppRoutes.items)) {
      if (route.startsWith(AppRoutes.itemsStockTransfer)) {
        return PermissionModule.stockTransfer;
      }
      return PermissionModule.item;
    }
    if (route.startsWith(AppRoutes.pos)) return PermissionModule.sale;
    if (route.startsWith(AppRoutes.sale)) {
      if (route.contains('payment-in')) return PermissionModule.paymentIn;
      if (route.contains('estimate')) return PermissionModule.estimate;
      if (route.contains('proforma')) return PermissionModule.proforma;
      if (route.contains('order')) return PermissionModule.saleOrder;
      if (route.contains('delivery-challan')) {
        return PermissionModule.deliveryChallan;
      }
      if (route.contains('credit-note')) return PermissionModule.creditNote;
      return PermissionModule.sale;
    }
    if (route.startsWith(AppRoutes.purchase)) {
      if (route.contains('payment-out')) return PermissionModule.paymentOut;
      if (route.contains('expense')) return PermissionModule.expense;
      if (route.contains('order')) return PermissionModule.purchaseOrder;
      if (route.contains('debit-note')) return PermissionModule.debitNote;
      return PermissionModule.purchase;
    }
    if (route.startsWith(AppRoutes.reports)) return PermissionModule.reports;
    if (route.startsWith(AppRoutes.collaboration)) {
      return PermissionModule.syncSettings;
    }
    if (route.startsWith(AppRoutes.settings)) return PermissionModule.settings;
    if (route.startsWith(AppRoutes.crm)) {
      return PermissionModule.partySmartConnect;
    }
    return null;
  }
}
