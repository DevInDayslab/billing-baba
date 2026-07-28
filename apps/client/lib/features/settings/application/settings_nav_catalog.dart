import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/settings/models/settings_nav_item.dart';
import 'package:flutter/material.dart';

/// Canonical list of global settings destinations for mobile and desktop hubs.
abstract final class SettingsNavCatalog {
  static const items = <SettingsNavItem>[
    SettingsNavItem(
      id: 'print',
      icon: Icons.print_outlined,
      title: 'Print Settings',
      subtitle: 'Printer type, layout, and invoice content',
      route: AppRoutes.settingsPrint,
    ),
    SettingsNavItem(
      id: 'taxes',
      icon: Icons.receipt_long_outlined,
      title: 'Taxes',
      subtitle: 'GST and tax configuration',
      route: AppRoutes.settingsTaxes,
    ),
    SettingsNavItem(
      id: 'invoice-templates',
      icon: Icons.description_outlined,
      title: 'Invoice Templates',
      subtitle: 'Customize invoice layouts',
      route: AppRoutes.settingsInvoiceTemplates,
    ),
    SettingsNavItem(
      id: 'whatsapp',
      icon: Icons.chat_outlined,
      title: 'WhatsApp',
      subtitle: 'Enable messaging and test delivery',
      route: AppRoutes.settingsWhatsapp,
      group: SettingsNavGroup.messaging,
    ),
    SettingsNavItem(
      id: 'transaction-messages',
      icon: Icons.sms_outlined,
      title: 'Transaction Messages',
      subtitle: 'Auto-send templates and message content',
      route: AppRoutes.settingsTransactionMessages,
      group: SettingsNavGroup.messaging,
    ),
    SettingsNavItem(
      id: 'plans-pricing',
      icon: Icons.workspace_premium_outlined,
      title: 'Plans & Pricing',
      subtitle: 'Subscription plans and upgrades',
      route: AppRoutes.plansPricing,
      group: SettingsNavGroup.account,
    ),
    SettingsNavItem(
      id: 'users',
      icon: Icons.people_outline,
      title: 'Users & Roles',
      subtitle: 'Team access and permissions',
      route: AppRoutes.settingsUsers,
      group: SettingsNavGroup.account,
    ),
    SettingsNavItem(
      id: 'backup',
      icon: Icons.backup_outlined,
      title: 'Backup & Restore',
      subtitle: 'Cloud backup and data recovery',
      route: AppRoutes.settingsBackup,
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
