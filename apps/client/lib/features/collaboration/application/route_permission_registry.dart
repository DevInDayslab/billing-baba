import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/collaboration/application/permission_service.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';

/// Maps route prefixes to required view permission.
abstract final class RoutePermissionRegistry {
  static const _routeModules = <String, PermissionModule>{
    AppRoutes.home: PermissionModule.allTransactions,
    AppRoutes.parties: PermissionModule.party,
    AppRoutes.partyDetails: PermissionModule.party,
    AppRoutes.partyGroups: PermissionModule.party,
    AppRoutes.partyHiddenLedger: PermissionModule.party,
    AppRoutes.items: PermissionModule.item,
    AppRoutes.itemsCategories: PermissionModule.item,
    AppRoutes.itemsUnits: PermissionModule.item,
    AppRoutes.itemsGodowns: PermissionModule.item,
    AppRoutes.itemsStockTransfer: PermissionModule.stockTransfer,
    AppRoutes.pos: PermissionModule.sale,
    AppRoutes.sale: PermissionModule.sale,
    AppRoutes.saleInvoices: PermissionModule.sale,
    AppRoutes.saleEstimateQuotation: PermissionModule.estimate,
    AppRoutes.saleProformaInvoice: PermissionModule.proforma,
    AppRoutes.salePaymentIn: PermissionModule.paymentIn,
    AppRoutes.saleOrder: PermissionModule.saleOrder,
    AppRoutes.saleDeliveryChallan: PermissionModule.deliveryChallan,
    AppRoutes.saleJobWorkOut: PermissionModule.sale,
    AppRoutes.saleReturnCreditNote: PermissionModule.creditNote,
    AppRoutes.saleFa: PermissionModule.sale,
    AppRoutes.purchase: PermissionModule.purchase,
    AppRoutes.purchaseBills: PermissionModule.purchase,
    AppRoutes.purchasePaymentOut: PermissionModule.paymentOut,
    AppRoutes.purchaseExpenses: PermissionModule.expense,
    AppRoutes.purchaseOrder: PermissionModule.purchaseOrder,
    AppRoutes.purchaseReturnDebitNote: PermissionModule.debitNote,
    AppRoutes.purchaseFa: PermissionModule.purchase,
    AppRoutes.reports: PermissionModule.reports,
    AppRoutes.collaboration: PermissionModule.syncSettings,
    AppRoutes.collaborationSyncShare: PermissionModule.syncSettings,
    AppRoutes.settings: PermissionModule.settings,
    AppRoutes.settingsUsers: PermissionModule.settings,
    AppRoutes.settingsTaxes: PermissionModule.settings,
    AppRoutes.settingsInvoiceTemplates: PermissionModule.settings,
    AppRoutes.settingsPreferences: PermissionModule.settings,
    AppRoutes.settingsPrint: PermissionModule.settings,
    AppRoutes.settingsWhatsapp: PermissionModule.settings,
    AppRoutes.settingsTransactionMessages: PermissionModule.settings,
    AppRoutes.settingsBackup: PermissionModule.settings,
    AppRoutes.crm: PermissionModule.partySmartConnect,
    AppRoutes.crmLeads: PermissionModule.partySmartConnect,
    AppRoutes.crmContacts: PermissionModule.partySmartConnect,
    AppRoutes.crmDeals: PermissionModule.partySmartConnect,
    AppRoutes.editProfile: PermissionModule.settings,
  };

  static PermissionModule? moduleForRoute(String location) {
    if (location.startsWith(AppRoutes.utilities) ||
        location.startsWith(AppRoutes.developer) ||
        location.startsWith(AppRoutes.plansPricing)) {
      return null;
    }

    String? bestRoute;
    PermissionModule? bestModule;

    for (final entry in _routeModules.entries) {
      final route = entry.key;
      if (location == route || location.startsWith('$route/')) {
        if (bestRoute == null || route.length > bestRoute.length) {
          bestRoute = route;
          bestModule = entry.value;
        }
      }
    }

    return bestModule;
  }

  static bool canAccessRoute(String location, PermissionService service) {
    if (!service.hasSession) return false;
    if (service.hasFullAccess) return true;

    if (location == AppRoutes.partyHiddenLedger) {
      return service.canViewHiddenLedger;
    }

    if (location.startsWith(AppRoutes.utilities) ||
        location.startsWith(AppRoutes.developer) ||
        location.startsWith(AppRoutes.plansPricing)) {
      return false;
    }

    if (location == AppRoutes.home || location == AppRoutes.editProfile) {
      return true;
    }

    final module = moduleForRoute(location);
    if (module == null) return true;
    return service.canView(module);
  }
}

/// Convenience for create/edit/delete checks on routes.
PermissionModule? permissionModuleForRoute(String location) =>
    RoutePermissionRegistry.moduleForRoute(location);

PermissionAction viewAction = PermissionAction.view;
