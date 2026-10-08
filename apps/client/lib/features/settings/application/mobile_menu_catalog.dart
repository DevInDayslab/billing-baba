import 'dart:async';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/platform/desktop_menu_actions.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/collaboration/application/navigation_permission_registry.dart';
import 'package:billing_baba/features/collaboration/application/permission_service.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/reports/models/expense_report_subsection.dart';
import 'package:billing_baba/features/reports/models/report_nav_group.dart';
import 'package:billing_baba/features/reports/models/report_nav_group_extensions.dart';
import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:billing_baba/features/reports/models/transaction_report_subsection.dart';
import 'package:billing_baba/features/search/application/search_registry_visibility.dart';
import 'package:billing_baba/features/settings/models/mobile_menu_item.dart';
import 'package:billing_baba/features/settings/models/settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Canonical mobile Menu hub structure — single source for navigation tiles.
abstract final class MobileMenuCatalog {
  static List<MobileMenuSection> get sections => MobileMenuSection.values;

  static List<MobileMenuItem> itemsForSection(MobileMenuSection section) {
    return switch (section) {
      MobileMenuSection.business => _businessItems,
      MobileMenuSection.utilities => _utilitiesItems,
      MobileMenuSection.settings => [_settingsAccordion],
      MobileMenuSection.support => [_supportAccordion],
      MobileMenuSection.account => _accountItems,
    };
  }

  static List<MobileMenuItem> visibleItemsForSection(
    MobileMenuSection section,
    PermissionService permissions,
  ) {
    var items = itemsForSection(section);
    if (section == MobileMenuSection.utilities &&
        SearchRegistryVisibility.hideUtilities) {
      items = items
          .where(
            (item) =>
                item.id == 'business-profile' || item.id == 'manage-companies',
          )
          .toList();
    }
    return _filterItems(items, permissions);
  }

  static List<MobileMenuItem> _filterItems(
    List<MobileMenuItem> items,
    PermissionService permissions,
  ) {
    final visible = <MobileMenuItem>[];
    for (final item in items) {
      final filtered = _filterItem(item, permissions);
      if (filtered != null) visible.add(filtered);
    }
    return visible;
  }

  static MobileMenuItem? _filterItem(
    MobileMenuItem item,
    PermissionService permissions,
  ) {
    if (!item.enabled) return null;

    if (item.isAccordion || item.children.isNotEmpty) {
      final children = _filterItems(item.children, permissions);
      if (children.isEmpty) return null;
      return item.copyWith(children: children);
    }

    if (!isItemVisible(item, permissions)) return null;
    return item;
  }

  static bool isItemVisible(
    MobileMenuItem item,
    PermissionService permissions,
  ) {
    if (!permissions.hasSession) return false;

    return switch (item.action) {
      MobileMenuAction.externalUrl ||
      MobileMenuAction.mailto ||
      MobileMenuAction.versionInfo ||
      MobileMenuAction.logout => true,
      MobileMenuAction.openReport =>
        permissions.hasFullAccess ||
            permissions.canView(PermissionModule.reports),
      MobileMenuAction.none => () {
        if (item.reportIntent != null) {
          return permissions.hasFullAccess ||
              permissions.canView(PermissionModule.reports);
        }
        final route = item.route;
        if (route == null) return false;
        return NavigationPermissionRegistry.isVisible(route, permissions);
      }(),
    };
  }

  static final List<MobileMenuItem> _businessItems = [
    MobileMenuItem(
      id: 'sales',
      title: 'Sales',
      subtitle: 'Sale report and transaction summary',
      icon: Icons.point_of_sale_outlined,
      action: MobileMenuAction.openReport,
      reportIntent: ReportsNavIntent.transaction(
        TransactionReportSubSection.sale,
      ),
      section: MobileMenuSection.business,
    ),
    MobileMenuItem(
      id: 'purchases',
      title: 'Purchases',
      subtitle: 'Purchase report and transaction summary',
      icon: LucideIcons.shoppingCart,
      action: MobileMenuAction.openReport,
      reportIntent: ReportsNavIntent.transaction(
        TransactionReportSubSection.purchase,
      ),
      section: MobileMenuSection.business,
    ),
    MobileMenuItem(
      id: 'expenses',
      title: 'Expenses',
      subtitle: 'Expense report and category breakdowns',
      icon: LucideIcons.banknote,
      action: MobileMenuAction.openReport,
      reportIntent: ReportsNavIntent.expense(ExpenseReportSubSection.expense),
      section: MobileMenuSection.business,
    ),
    const MobileMenuItem(
      id: 'reports-hub',
      title: 'Reports',
      subtitle: 'Transaction, party, GST, stock, and more',
      icon: LucideIcons.chartBar,
      route: AppRoutes.reports,
      section: MobileMenuSection.business,
    ),
    _inventoryAccordion,
  ];

  static const _inventoryAccordion = MobileMenuItem(
    id: 'inventory',
    title: 'Inventory',
    subtitle: 'Items, categories, units, godowns, and stock',
    icon: LucideIcons.package,
    isAccordion: true,
    section: MobileMenuSection.business,
    children: [
      MobileMenuItem(
        id: 'items',
        title: 'Items',
        subtitle: 'Products and inventory',
        route: AppRoutes.items,
      ),
      MobileMenuItem(
        id: 'categories',
        title: 'Categories',
        subtitle: 'Item categories',
        route: AppRoutes.itemsCategories,
      ),
      MobileMenuItem(
        id: 'units',
        title: 'Units',
        subtitle: 'Measurement units',
        route: AppRoutes.itemsUnits,
      ),
      MobileMenuItem(
        id: 'godowns',
        title: 'Godowns',
        subtitle: 'Warehouses and storage locations',
        route: AppRoutes.itemsGodowns,
      ),
      MobileMenuItem(
        id: 'barcode',
        title: 'Barcode',
        subtitle: 'Barcode generator',
        route: AppRoutes.utilitiesBarcodeGenerator,
      ),
      MobileMenuItem(
        id: 'stock',
        title: 'Stock',
        subtitle: 'Stock summary report',
        route: AppRoutes.reportsStockSummary,
      ),
    ],
  );

  static List<MobileMenuItem> get _utilitiesItems => [
    const MobileMenuItem(
      id: 'business-profile',
      title: 'Business Profile',
      subtitle: 'Name, address, GSTIN, and branding',
      icon: LucideIcons.store,
      route: AppRoutes.editProfile,
      section: MobileMenuSection.utilities,
    ),
    const MobileMenuItem(
      id: 'manage-companies',
      title: 'Manage Companies',
      subtitle: 'Switch or manage your businesses',
      icon: LucideIcons.building2,
      route: AppRoutes.businessList,
      section: MobileMenuSection.utilities,
    ),
    const MobileMenuItem(
      id: 'import-items',
      title: 'Import Items',
      subtitle: 'Import items from Excel',
      icon: LucideIcons.upload,
      route: AppRoutes.utilitiesImportItems,
      section: MobileMenuSection.utilities,
    ),
    const MobileMenuItem(
      id: 'backup-restore',
      title: 'Backup & Restore',
      subtitle: 'Export and restore local .biba backups',
      icon: LucideIcons.database,
      route: AppRoutes.settingsBackup,
      section: MobileMenuSection.utilities,
    ),
    if (!SearchRegistryVisibility.hideCollaboration)
      const MobileMenuItem(
        id: 'sync-share',
        title: 'Sync & Share',
        subtitle: 'Multi-device sync and team sharing',
        icon: LucideIcons.refreshCw,
        route: AppRoutes.collaborationSyncShare,
        section: MobileMenuSection.utilities,
      ),
  ];

  static const _settingsAccordion = MobileMenuItem(
    id: 'settings',
    title: 'Settings',
    subtitle: 'Item, print, and message preferences',
    icon: LucideIcons.settings,
    isAccordion: true,
    section: MobileMenuSection.settings,
    children: [
      MobileMenuItem(
        id: 'settings-item-settings',
        title: 'Item Settings',
        subtitle: 'Barcode scan, pricing, categories, and fields',
        icon: LucideIcons.slidersHorizontal,
        route: AppRoutes.itemsSettings,
      ),
      MobileMenuItem(
        id: 'settings-print',
        title: 'Print Settings',
        subtitle: 'Printer type, layout, and invoice content',
        icon: LucideIcons.printer,
        route: AppRoutes.settingsPrint,
      ),
      MobileMenuItem(
        id: 'settings-transaction-messages',
        title: 'Transaction Messages',
        subtitle: 'Auto-send templates and message content',
        icon: LucideIcons.messageSquare,
        route: AppRoutes.settingsTransactionMessages,
      ),
      MobileMenuItem(
        id: 'settings-notifications',
        title: 'Notifications',
        subtitle: 'Reminders, sync, backup, and alert preferences',
        icon: LucideIcons.bell,
        route: AppRoutes.settingsNotifications,
      ),
    ],
  );

  static final _supportAccordion = MobileMenuItem(
    id: 'support',
    title: 'Support',
    subtitle: 'Help, about, and privacy',
    icon: LucideIcons.circleHelp,
    isAccordion: true,
    section: MobileMenuSection.support,
    children: [
      MobileMenuItem(
        id: 'help-support',
        title: 'Help & Support',
        subtitle: 'Contact our support team',
        action: MobileMenuAction.externalUrl,
        externalUrl: AppConfig.contactSupportUrl,
      ),
      MobileMenuItem(
        id: 'about',
        title: 'About Billing Baba',
        subtitle: 'App version and information',
        route: AppRoutes.settingsTab(SettingsTab.about.id),
      ),
      MobileMenuItem(
        id: 'terms-of-service',
        title: 'Terms of Service',
        subtitle: 'Usage terms for Billing Baba',
        action: MobileMenuAction.externalUrl,
        externalUrl: AppConfig.termsOfServiceUrl,
      ),
      MobileMenuItem(
        id: 'privacy-policy',
        title: 'Privacy Policy',
        subtitle: 'Read our privacy policy',
        action: MobileMenuAction.externalUrl,
        externalUrl: AppConfig.privacyPolicyUrl,
      ),
      const MobileMenuItem(
        id: 'app-version',
        title: 'App Version',
        subtitle: 'Installed build information',
        action: MobileMenuAction.versionInfo,
      ),
    ],
  );

  static const _accountItems = [
    MobileMenuItem(
      id: 'plans-pricing',
      title: 'Plans & Pricing',
      subtitle: 'Subscription plans and upgrades',
      icon: LucideIcons.award,
      route: AppRoutes.plansPricing,
      section: MobileMenuSection.account,
    ),
    MobileMenuItem(
      id: 'sale-screen',
      title: 'Sale Screen',
      subtitle: 'Search products and bill customers quickly',
      icon: LucideIcons.layoutGrid,
      route: AppRoutes.saleScreen,
      section: MobileMenuSection.account,
    ),
    MobileMenuItem(
      id: 'logout',
      title: 'Logout',
      subtitle: 'Sign out of this device',
      icon: LucideIcons.logOut,
      action: MobileMenuAction.logout,
      section: MobileMenuSection.account,
    ),
  ];
}

/// Handles Menu item taps — routes, reports, and external actions.
abstract final class MobileMenuNavigation {
  static Future<void> onItemTap(
    BuildContext context,
    WidgetRef ref,
    MobileMenuItem item,
  ) async {
    switch (item.action) {
      case MobileMenuAction.externalUrl:
        final url = item.externalUrl;
        if (url != null) {
          await DesktopMenuActions.openExternalUrl(url);
        }
      case MobileMenuAction.mailto:
        await DesktopMenuActions.reportIssue();
      case MobileMenuAction.openReport:
        final intent = item.reportIntent;
        if (intent == null) return;
        if (context.mounted) {
          await context.push(_routeForReportIntent(intent));
        }
      case MobileMenuAction.versionInfo:
        return;
      case MobileMenuAction.logout:
        await confirmLogout(context, ref);
      case MobileMenuAction.none:
        final route = item.route;
        if (route == null) return;
        if (context.mounted) {
          await context.push(route);
        }
    }
  }

  static Future<void> confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go(AppRoutes.login);
  }

  static String _routeForReportIntent(ReportsNavIntent intent) {
    final subsection = switch (intent.group) {
      ReportNavGroup.transaction => intent.transactionSub?.name,
      ReportNavGroup.party => intent.partySub?.name,
      ReportNavGroup.gst => intent.gstSub?.name,
      ReportNavGroup.itemStock => intent.itemStockSub?.name,
      ReportNavGroup.businessStatus => intent.businessStatusSub?.name,
      ReportNavGroup.taxes => intent.taxesSub?.name,
      ReportNavGroup.expenseReport => intent.expenseSub?.name,
      ReportNavGroup.salePurchaseOrderReport =>
        intent.salePurchaseOrderSub?.name,
      ReportNavGroup.otherIncomeReport => intent.otherIncomeSub?.name,
      ReportNavGroup.loanAccounts => intent.loanAccountsSub?.name,
    };

    if (subsection == null) return AppRoutes.settingsReports;

    return AppRoutes.settingsReportSubsection(intent.group.id, subsection);
  }
}
