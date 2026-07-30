import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/settings/models/settings_nav_item.dart';
import 'package:billing_baba/features/settings/models/settings_tab.dart';
import 'package:flutter/material.dart';

/// Canonical list of global settings destinations for mobile hubs / search.
abstract final class SettingsNavCatalog {
  static String preferencesTab(SettingsTab tab) =>
      AppRoutes.settingsTab(tab.id);

  static final items = <SettingsNavItem>[
    SettingsNavItem(
      id: SettingsTab.profile.id,
      icon: Icons.storefront_outlined,
      title: 'Business Profile',
      subtitle: 'Name, address, GSTIN, and branding',
      route: preferencesTab(SettingsTab.profile),
    ),
    SettingsNavItem(
      id: 'item-settings',
      icon: Icons.tune_outlined,
      title: 'Item Settings',
      subtitle: 'Barcode scan, pricing, categories, and fields',
      route: AppRoutes.itemsSettings,
    ),
    SettingsNavItem(
      id: SettingsTab.print.id,
      icon: Icons.print_outlined,
      title: 'Print',
      subtitle: 'Printer type, layout, and invoice content',
      route: AppRoutes.settingsPrint,
    ),
    SettingsNavItem(
      id: SettingsTab.transactionMessages.id,
      icon: Icons.sms_outlined,
      title: 'Transaction Messages',
      subtitle: 'Auto-send templates and message content',
      route: AppRoutes.settingsTransactionMessages,
      group: SettingsNavGroup.messaging,
    ),
    SettingsNavItem(
      id: SettingsTab.backup.id,
      icon: Icons.backup_outlined,
      title: 'Backup & Restore',
      subtitle: 'Local .biba backup and restore',
      route: AppRoutes.settingsBackup,
      group: SettingsNavGroup.account,
    ),
    SettingsNavItem(
      id: SettingsTab.about.id,
      icon: Icons.info_outline,
      title: 'About',
      subtitle: 'Version and app information',
      route: preferencesTab(SettingsTab.about),
      group: SettingsNavGroup.account,
    ),
  ];

  static Map<SettingsNavGroup, List<SettingsNavItem>> grouped() {
    final map = <SettingsNavGroup, List<SettingsNavItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.group, () => []).add(item);
    }
    return map;
  }
}
