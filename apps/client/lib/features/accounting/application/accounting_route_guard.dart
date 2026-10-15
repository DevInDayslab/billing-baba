import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/features/settings/models/accounting_settings.dart';

abstract final class AccountingRouteGuard {
  static String? redirect(String location, AccountingSettings settings) {
    if (location == AppRoutes.accountant ||
        location.startsWith('${AppRoutes.accountant}/')) {
      if (!settings.enableAccountingModule) {
        return AppRoutes.home;
      }
      if (location == AppRoutes.journalEntries ||
          location.startsWith('${AppRoutes.journalEntries}/')) {
        if (!settings.allowJournalEntries) {
          return AppRoutes.accountant;
        }
      }
    }
    return null;
  }
}
