import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/dashboard/providers/shell_sidebar_provider.dart';
import 'package:billing_baba/features/developer/models/developer_sub_route.dart';
import 'package:billing_baba/features/parties/models/party_sub_route.dart';
import 'package:billing_baba/features/purchases/models/purchase_sub_route.dart';
import 'package:billing_baba/features/sales/models/sale_sub_route.dart';
import 'package:billing_baba/features/search/domain/search_category.dart';
import 'package:billing_baba/features/search/domain/search_item.dart';
import 'package:billing_baba/features/utilities/models/utilities_sub_route.dart';
import 'package:flutter/material.dart';

/// Static registry of all searchable pages and commands.
abstract final class SearchRegistry {
  static List<SearchItem> allItems() => [...pages(), ...commands()];

  static List<SearchItem> pages() => [
    const SearchItem(
      id: 'page_home',
      title: 'Dashboard',
      subtitle: 'Home',
      icon: Icons.home_outlined,
      category: SearchCategory.page,
      route: AppRoutes.home,
      keywords: ['dashboard', 'home', 'dash'],
    ),
    const SearchItem(
      id: 'page_business_profile',
      title: 'Business Profile',
      subtitle: 'Edit company details',
      icon: Icons.business_outlined,
      category: SearchCategory.page,
      route: AppRoutes.editProfile,
      keywords: ['business', 'profile', 'company'],
    ),
    const SearchItem(
      id: 'page_profile',
      title: 'Profile',
      subtitle: 'Edit your profile',
      icon: Icons.person_outline,
      category: SearchCategory.page,
      route: AppRoutes.editProfile,
      keywords: ['profile', 'account', 'user'],
    ),
    const SearchItem(
      id: 'page_business_switcher',
      title: 'Business Switcher',
      subtitle: 'Switch active company',
      icon: Icons.autorenew,
      category: SearchCategory.page,
      route: AppRoutes.businessList,
      keywords: ['business', 'switch', 'company'],
    ),
    ...PartySubRoutes.items.map(_pageFromPartySubRoute),
    const SearchItem(
      id: 'page_items',
      title: 'Items',
      subtitle: 'Inventory',
      icon: Icons.inventory_2_outlined,
      category: SearchCategory.page,
      route: AppRoutes.items,
      keywords: ['items', 'inventory', 'products', 'stock'],
    ),
    ...SaleSubRoutes.items.map(_pageFromSaleSubRoute),
    if (!ShellSidebarVisibility.hidePos)
      const SearchItem(
        id: 'page_pos',
        title: 'POS',
        subtitle: 'Point of Sale',
        icon: Icons.point_of_sale_outlined,
        category: SearchCategory.page,
        route: AppRoutes.pos,
        keywords: ['pos', 'point', 'sale', 'retail'],
      ),
    ...PurchaseSubRoutes.items.map(_pageFromPurchaseSubRoute),
    const SearchItem(
      id: 'page_reports',
      title: 'Reports',
      icon: Icons.bar_chart_outlined,
      category: SearchCategory.page,
      route: AppRoutes.reports,
      keywords: ['reports', 'report', 'analytics'],
    ),
    const SearchItem(
      id: 'page_gst',
      title: 'GST',
      subtitle: 'GST reports',
      icon: Icons.receipt_long_outlined,
      category: SearchCategory.page,
      action: SearchActionKind.openReportsGst,
      keywords: ['gst', 'gstr', 'tax'],
    ),
    if (!ShellSidebarVisibility.hideUtilities) ...[
      ...UtilitiesSubRoutes.items.map(_pageFromUtilitiesSubRoute),
    ],
    if (!ShellSidebarVisibility.hideDeveloper) ...[
      const SearchItem(
        id: 'page_developer',
        title: 'Developer',
        icon: Icons.code_outlined,
        category: SearchCategory.page,
        route: AppRoutes.developerComponents,
        keywords: ['developer', 'dev', 'components'],
      ),
      ...DeveloperSubRoutes.items.map(_pageFromDeveloperSubRoute),
    ],
    if (!ShellSidebarVisibility.hideSettings) ...[
      const SearchItem(
        id: 'page_settings',
        title: 'Settings',
        icon: Icons.settings_outlined,
        category: SearchCategory.page,
        route: AppRoutes.settingsPreferences,
        keywords: ['settings', 'setting', 'preferences', 'config'],
      ),
      const SearchItem(
        id: 'page_settings_print',
        title: 'Print Settings',
        icon: Icons.print_outlined,
        category: SearchCategory.page,
        route: AppRoutes.settingsPrint,
        keywords: ['print', 'printer', 'invoice'],
      ),
      const SearchItem(
        id: 'page_settings_users',
        title: 'Users & Roles',
        icon: Icons.people_outline,
        category: SearchCategory.page,
        route: AppRoutes.settingsUsers,
        keywords: ['users', 'roles', 'permissions'],
      ),
      const SearchItem(
        id: 'page_settings_taxes',
        title: 'Taxes',
        icon: Icons.receipt_long_outlined,
        category: SearchCategory.page,
        route: AppRoutes.settingsTaxes,
        keywords: ['tax', 'taxes', 'gst'],
      ),
      const SearchItem(
        id: 'page_settings_invoice_templates',
        title: 'Invoice Templates',
        icon: Icons.description_outlined,
        category: SearchCategory.page,
        route: AppRoutes.settingsInvoiceTemplates,
        keywords: ['invoice', 'template', 'templates'],
      ),
      const SearchItem(
        id: 'page_settings_backup',
        title: 'Backup & Restore',
        icon: Icons.backup_outlined,
        category: SearchCategory.page,
        route: AppRoutes.settingsBackup,
        keywords: ['backup', 'restore', 'database'],
      ),
    ],
    const SearchItem(
      id: 'page_plans_pricing',
      title: 'Subscriptions',
      subtitle: 'Plans & Pricing',
      icon: Icons.workspace_premium_outlined,
      category: SearchCategory.page,
      route: AppRoutes.plansPricing,
      keywords: ['subscription', 'plans', 'pricing', 'premium'],
    ),
  ];

  static List<SearchItem> commands() => [
    const SearchItem(
      id: 'cmd_add_sale',
      title: 'Add Sale',
      icon: Icons.add_shopping_cart_outlined,
      category: SearchCategory.command,
      route: AppRoutes.addSale,
      action: SearchActionKind.routePush,
      trackAsRecentPage: false,
      keywords: ['sale', 'invoice', 'add'],
    ),
    const SearchItem(
      id: 'cmd_add_purchase',
      title: 'Add Purchase',
      icon: Icons.shopping_cart_outlined,
      category: SearchCategory.command,
      route: AppRoutes.addPurchase,
      action: SearchActionKind.routePush,
      trackAsRecentPage: false,
      keywords: ['purchase', 'bill', 'add'],
    ),
    const SearchItem(
      id: 'cmd_add_party',
      title: 'Add Party',
      icon: Icons.person_add_outlined,
      category: SearchCategory.command,
      action: SearchActionKind.showAddPartyDialog,
      trackAsRecentPage: false,
      keywords: ['party', 'customer', 'supplier', 'add'],
    ),
    const SearchItem(
      id: 'cmd_add_item',
      title: 'Add Item',
      icon: Icons.add_box_outlined,
      category: SearchCategory.command,
      action: SearchActionKind.showAddItemDialog,
      trackAsRecentPage: false,
      keywords: ['item', 'product', 'inventory', 'add'],
    ),
    const SearchItem(
      id: 'cmd_add_expense',
      title: 'Add Expense',
      icon: Icons.payments_outlined,
      category: SearchCategory.command,
      route: AppRoutes.addExpense,
      action: SearchActionKind.routePush,
      trackAsRecentPage: false,
      keywords: ['expense', 'add'],
    ),
    const SearchItem(
      id: 'cmd_add_payment_in',
      title: 'Add Payment In',
      icon: Icons.call_received_outlined,
      category: SearchCategory.command,
      action: SearchActionKind.showPaymentInDialog,
      trackAsRecentPage: false,
      keywords: ['payment', 'in', 'receive'],
    ),
    const SearchItem(
      id: 'cmd_add_payment_out',
      title: 'Add Payment Out',
      icon: Icons.call_made_outlined,
      category: SearchCategory.command,
      action: SearchActionKind.showPaymentOutDialog,
      trackAsRecentPage: false,
      keywords: ['payment', 'out', 'pay'],
    ),
    const SearchItem(
      id: 'cmd_new_estimate',
      title: 'New Estimate',
      icon: Icons.request_quote_outlined,
      category: SearchCategory.command,
      route: AppRoutes.addEstimate,
      action: SearchActionKind.routePush,
      trackAsRecentPage: false,
      keywords: ['estimate', 'quotation', 'new'],
    ),
    const SearchItem(
      id: 'cmd_new_sale_order',
      title: 'New Sale Order',
      icon: Icons.assignment_outlined,
      category: SearchCategory.command,
      route: AppRoutes.addSaleOrder,
      action: SearchActionKind.routePush,
      trackAsRecentPage: false,
      keywords: ['sale', 'order', 'new'],
    ),
    const SearchItem(
      id: 'cmd_new_purchase_order',
      title: 'New Purchase Order',
      icon: Icons.assignment_outlined,
      category: SearchCategory.command,
      route: AppRoutes.addPurchaseOrder,
      action: SearchActionKind.routePush,
      trackAsRecentPage: false,
      keywords: ['purchase', 'order', 'new'],
    ),
    const SearchItem(
      id: 'cmd_import_excel',
      title: 'Import Excel',
      icon: Icons.upload_file_outlined,
      category: SearchCategory.command,
      route: AppRoutes.utilitiesImportItems,
      action: SearchActionKind.routeGo,
      trackAsRecentPage: false,
      keywords: ['import', 'excel', 'items', 'bulk'],
    ),
    const SearchItem(
      id: 'cmd_generate_barcode',
      title: 'Generate Barcode',
      icon: Icons.qr_code_2_outlined,
      category: SearchCategory.command,
      route: AppRoutes.utilitiesBarcodeGenerator,
      action: SearchActionKind.routeGo,
      trackAsRecentPage: false,
      keywords: ['barcode', 'generate', 'label'],
    ),
    const SearchItem(
      id: 'cmd_backup_database',
      title: 'Backup Database',
      icon: Icons.backup_outlined,
      category: SearchCategory.command,
      route: AppRoutes.settingsBackup,
      action: SearchActionKind.routeGo,
      trackAsRecentPage: false,
      keywords: ['backup', 'database'],
    ),
    const SearchItem(
      id: 'cmd_restore_backup',
      title: 'Restore Backup',
      icon: Icons.restore_outlined,
      category: SearchCategory.command,
      route: AppRoutes.settingsBackup,
      action: SearchActionKind.routeGo,
      trackAsRecentPage: false,
      keywords: ['restore', 'backup', 'database'],
    ),
    const SearchItem(
      id: 'cmd_open_settings',
      title: 'Open Settings',
      icon: Icons.settings_outlined,
      category: SearchCategory.command,
      route: AppRoutes.settingsPreferences,
      action: SearchActionKind.routeGo,
      trackAsRecentPage: false,
      keywords: ['settings', 'open', 'preferences'],
    ),
    const SearchItem(
      id: 'cmd_open_reports',
      title: 'Open Reports',
      icon: Icons.bar_chart_outlined,
      category: SearchCategory.command,
      route: AppRoutes.reports,
      action: SearchActionKind.routeGo,
      trackAsRecentPage: false,
      keywords: ['reports', 'open'],
    ),
  ];

  static SearchItem? byId(String id) {
    for (final item in allItems()) {
      if (item.id == id) return item;
    }
    return null;
  }

  static SearchItem? pageForRoute(String path) {
    SearchItem? best;
    var bestLength = -1;

    for (final item in pages()) {
      final route = item.route;
      if (route == null) continue;
      if (path == route || path.startsWith('$route/')) {
        if (route.length > bestLength) {
          best = item;
          bestLength = route.length;
        }
      }
    }

    return best;
  }

  static SearchItem _pageFromPartySubRoute(PartySubRoute route) {
    return SearchItem(
      id: 'page_${route.route.replaceAll('/', '_')}',
      title: route.label,
      icon: Icons.people_outlined,
      category: SearchCategory.page,
      route: route.route,
      keywords: _keywordsForLabel(route.label, extra: ['party', 'parties']),
    );
  }

  static SearchItem _pageFromSaleSubRoute(SaleSubRoute route) {
    final title = route.pageTitle ?? route.label;
    final keywords = _keywordsForLabel(title);
    if (route.route == AppRoutes.saleInvoices) {
      keywords.addAll(['invoice', 'bill', 'sales']);
    }
    return SearchItem(
      id: 'page_${route.route.replaceAll('/', '_')}',
      title: title,
      subtitle: route.label != title ? route.label : null,
      icon: Icons.receipt_outlined,
      category: SearchCategory.page,
      route: route.route,
      keywords: keywords,
    );
  }

  static SearchItem _pageFromPurchaseSubRoute(PurchaseSubRoute route) {
    final title = route.pageTitle ?? route.label;
    return SearchItem(
      id: 'page_${route.route.replaceAll('/', '_')}',
      title: title,
      subtitle: route.label != title ? route.label : null,
      icon: Icons.shopping_cart_outlined,
      category: SearchCategory.page,
      route: route.route,
      keywords: _keywordsForLabel(title, extra: ['purchase', 'expense']),
    );
  }

  static SearchItem _pageFromUtilitiesSubRoute(UtilitiesSubRoute route) {
    final keywords = _keywordsForLabel(route.label);
    if (route.route == AppRoutes.utilitiesBarcodeGenerator) {
      keywords.addAll(['barcode', 'generator', 'label']);
    }
    if (route.route == AppRoutes.utilitiesImportItems) {
      keywords.addAll(['import', 'excel', 'items']);
    }
    return SearchItem(
      id: 'page_${route.route.replaceAll('/', '_')}',
      title: route.label,
      icon: Icons.build_outlined,
      category: SearchCategory.page,
      route: route.route,
      keywords: keywords,
    );
  }

  static SearchItem _pageFromDeveloperSubRoute(DeveloperSubRoute route) {
    return SearchItem(
      id: 'page_${route.route.replaceAll('/', '_')}',
      title: route.label,
      subtitle: route.description,
      icon: route.icon,
      category: SearchCategory.page,
      route: route.route,
      keywords: _keywordsForLabel(route.label, extra: ['developer']),
    );
  }

  static List<String> _keywordsForLabel(String label, {List<String>? extra}) {
    final keywords = <String>[
      label.toLowerCase(),
      ...label.toLowerCase().split(RegExp(r'[\s/]+')),
      if (extra != null) ...extra,
    ];
    return keywords.toSet().toList(growable: false);
  }
}
