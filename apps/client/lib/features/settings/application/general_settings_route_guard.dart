import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/settings/models/general_settings.dart';

/// Redirects when a More Transactions setting hides a route.
abstract final class GeneralSettingsRouteGuard {
  static String? redirect(String location, GeneralSettings settings) {
    if (!settings.isTransactionPathEnabled(location)) {
      if (location.startsWith('${AppRoutes.sale}/') ||
          location.startsWith('${AppRoutes.addSale}') ||
          location.startsWith('${AppRoutes.editSale}/') ||
          location.startsWith('${AppRoutes.viewSale}/') ||
          location.startsWith('${AppRoutes.duplicateSale}/')) {
        return AppRoutes.saleInvoices;
      }
      if (location.startsWith('${AppRoutes.purchase}/') ||
          location.startsWith('${AppRoutes.addPurchase}')) {
        return AppRoutes.purchaseBills;
      }
    }
    return null;
  }
}
