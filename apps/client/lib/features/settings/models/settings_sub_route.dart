import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/settings/models/settings_tab.dart';

/// Settings sub-pages shown in the desktop sidebar.
class SettingsSubRoute {
  const SettingsSubRoute({
    required this.route,
    required this.label,
    this.showProBadge = false,
  });

  final String route;
  final String label;
  final bool showProBadge;
}

abstract final class SettingsSubRoutes {
  static const items = <SettingsSubRoute>[
    SettingsSubRoute(
      route: AppRoutes.settingsGeneral,
      label: 'GENERAL',
    ),
    SettingsSubRoute(
      route: AppRoutes.settingsTransaction,
      label: 'TRANSACTION',
    ),
    SettingsSubRoute(
      route: AppRoutes.settingsPrint,
      label: 'PRINT',
    ),
    SettingsSubRoute(
      route: AppRoutes.settingsTaxes,
      label: 'TAXES & GST',
    ),
    SettingsSubRoute(
      route: AppRoutes.settingsTransactionMessages,
      label: 'TRANSACTION MESSAGE',
    ),
    SettingsSubRoute(
      route: AppRoutes.settingsParty,
      label: 'PARTY',
    ),
    SettingsSubRoute(
      route: AppRoutes.itemsSettings,
      label: 'ITEM',
    ),
    SettingsSubRoute(
      route: AppRoutes.settingsServiceReminders,
      label: 'SERVICE REMINDERS',
    ),
    SettingsSubRoute(
      route: AppRoutes.settingsAccounting,
      label: 'ACCOUNTING',
    ),
    SettingsSubRoute(
      route: AppRoutes.settingsMultiCurrency,
      label: 'MULTI CURRENCY',
      showProBadge: true,
    ),
  ];

  /// Deep link for the legacy preferences hub (business profile tab).
  static String generalPreferencesRoute() =>
      AppRoutes.settingsTab(SettingsTab.profile.id);
}
