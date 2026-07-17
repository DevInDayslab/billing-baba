import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/collaboration/models/collaboration_sub_route.dart';
import 'package:billing_baba/features/parties/models/party_sub_route.dart';
import 'package:billing_baba/features/purchases/models/purchase_sub_route.dart';
import 'package:billing_baba/features/sales/models/sale_sub_route.dart';
import 'package:billing_baba/features/search/application/search_registry_reports.dart';
import 'package:billing_baba/features/search/application/search_registry_visibility.dart';
import 'package:billing_baba/features/search/domain/search_category.dart';
import 'package:billing_baba/features/search/domain/search_item.dart';
import 'package:billing_baba/features/utilities/models/utilities_sub_route.dart';
import 'package:flutter/material.dart';

/// Pure static registry of production ERP pages and navigation commands.
abstract final class SearchRegistry {
  static final List<SearchItem> pages = _buildPages();
  static final List<SearchItem> commands = _buildCommands();
  static final List<SearchItem> allItems = [...pages, ...commands];

  static final Map<String, SearchItem> _itemsById = {
    for (final item in allItems) item.id: item,
  };

  static SearchItem? byId(String id) => _itemsById[id];

  static SearchItem? pageForRoute(String path) {
    SearchItem? best;
    var bestLength = -1;

    for (final item in pages) {
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

  static List<SearchItem> _buildPages() => [
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
      subtitle: 'Company details',
      icon: Icons.business_outlined,
      category: SearchCategory.page,
      route: AppRoutes.editProfile,
      keywords: ['business', 'profile', 'company'],
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
    const SearchItem(
      id: 'page_sales',
      title: 'Sales',
      subtitle: 'Sale documents',
      icon: Icons.receipt_outlined,
      category: SearchCategory.page,
      route: AppRoutes.saleInvoices,
      keywords: ['sales', 'sale'],
    ),
    ...SaleSubRoutes.items.map(_pageFromSaleSubRoute),
    if (!SearchRegistryVisibility.hidePos)
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
    ...SearchRegistryReports.items(),
    if (!SearchRegistryVisibility.hideCollaboration) ...[
      ...CollaborationSubRoutes.items.map(_pageFromCollaborationSubRoute),
    ],
    if (!SearchRegistryVisibility.hideUtilities) ...[
      ...UtilitiesSubRoutes.items.map(_pageFromUtilitiesSubRoute),
    ],
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
      keywords: ['print', 'printer', 'invoice', 'settings'],
    ),
    const SearchItem(
      id: 'page_settings_backup',
      title: 'Backup & Restore',
      icon: Icons.backup_outlined,
      category: SearchCategory.page,
      route: AppRoutes.settingsBackup,
      keywords: ['backup', 'restore', 'database', 'settings'],
    ),
    const SearchItem(
      id: 'page_plans_pricing',
      title: 'Plans & Pricing',
      subtitle: 'Subscriptions',
      icon: Icons.workspace_premium_outlined,
      category: SearchCategory.page,
      route: AppRoutes.plansPricing,
      keywords: ['subscription', 'plans', 'pricing', 'premium'],
    ),
  ];

  static List<SearchItem> _buildCommands() => [
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
      id: 'cmd_add_sale_fa',
      title: 'Add Sale FA',
      icon: Icons.add_shopping_cart_outlined,
      category: SearchCategory.command,
      route: AppRoutes.addSaleFa,
      action: SearchActionKind.routePush,
      trackAsRecentPage: false,
      keywords: ['sale', 'fa', 'add'],
    ),
    const SearchItem(
      id: 'cmd_add_sale_order',
      title: 'Add Sale Order',
      icon: Icons.assignment_outlined,
      category: SearchCategory.command,
      route: AppRoutes.addSaleOrder,
      action: SearchActionKind.routePush,
      trackAsRecentPage: false,
      keywords: ['sale', 'order', 'add'],
    ),
    const SearchItem(
      id: 'cmd_add_sale_return',
      title: 'Add Sale Return / Credit Note',
      icon: Icons.undo_outlined,
      category: SearchCategory.command,
      route: AppRoutes.addCreditNote,
      action: SearchActionKind.routePush,
      trackAsRecentPage: false,
      keywords: ['sale', 'return', 'credit', 'note', 'add'],
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
      id: 'cmd_add_purchase_fa',
      title: 'Add Purchase FA',
      icon: Icons.shopping_cart_outlined,
      category: SearchCategory.command,
      route: AppRoutes.addPurchaseFa,
      action: SearchActionKind.routePush,
      trackAsRecentPage: false,
      keywords: ['purchase', 'fa', 'add'],
    ),
    const SearchItem(
      id: 'cmd_add_purchase_order',
      title: 'Add Purchase Order',
      icon: Icons.assignment_outlined,
      category: SearchCategory.command,
      route: AppRoutes.addPurchaseOrder,
      action: SearchActionKind.routePush,
      trackAsRecentPage: false,
      keywords: ['purchase', 'order', 'add'],
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
      keywords: ['item', 'product', 'inventory', 'add', 'stock'],
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
      keywords: ['estimate', 'quotation', 'new', 'sale'],
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
  ];

  static SearchItem _pageFromPartySubRoute(PartySubRoute route) {
    return SearchItem(
      id: 'page_${route.route.replaceAll('/', '_')}',
      title: route.label,
      icon: Icons.people_outlined,
      category: SearchCategory.page,
      route: route.route,
      keywords: _keywordsForLabel(
        route.label,
        extra: const ['party', 'parties'],
      ),
    );
  }

  static SearchItem _pageFromSaleSubRoute(SaleSubRoute route) {
    final title = route.pageTitle ?? route.label;
    return SearchItem(
      id: 'page_${route.route.replaceAll('/', '_')}',
      title: title,
      subtitle: route.label != title ? route.label : null,
      icon: Icons.receipt_outlined,
      category: SearchCategory.page,
      route: route.route,
      keywords: [
        ..._keywordsForLabel(title),
        if (route.route == AppRoutes.saleInvoices) ...const [
          'invoice',
          'bill',
          'sales',
          'sale',
        ],
        if (route.route == AppRoutes.saleReturnCreditNote) ...const [
          'sale',
          'return',
          'credit',
          'note',
        ],
        if (route.route == AppRoutes.saleFa) ...const ['sale', 'fa'],
        if (route.route == AppRoutes.saleOrder) ...const ['sale', 'order'],
      ],
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
      keywords: [
        ..._keywordsForLabel(title),
        ...const ['purchase', 'expense'],
        if (route.route == AppRoutes.purchaseBills) ...const ['bill', 'bills'],
        if (route.route == AppRoutes.purchasePaymentOut) ...const [
          'payment',
          'out',
        ],
        if (route.route == AppRoutes.purchaseExpenses) ...const ['expense'],
      ],
    );
  }

  static SearchItem _pageFromUtilitiesSubRoute(UtilitiesSubRoute route) {
    return SearchItem(
      id: 'page_${route.route.replaceAll('/', '_')}',
      title: route.label,
      icon: Icons.build_outlined,
      category: SearchCategory.page,
      route: route.route,
      keywords: [
        ..._keywordsForLabel(route.label),
        if (route.route == AppRoutes.utilitiesBarcodeGenerator) ...const [
          'barcode',
          'generator',
          'label',
        ],
        if (route.route == AppRoutes.utilitiesImportItems) ...const [
          'import',
          'excel',
          'items',
        ],
      ],
    );
  }

  static SearchItem _pageFromCollaborationSubRoute(
    CollaborationSubRoute route,
  ) {
    return SearchItem(
      id: 'page_${route.route.replaceAll('/', '_')}',
      title: route.label,
      icon: Icons.sync_outlined,
      category: SearchCategory.page,
      route: route.route,
      keywords: [
        ..._keywordsForLabel(route.label),
        'sync',
        'share',
        'collaboration',
        'team',
        'members',
        'invite',
      ],
    );
  }

  static List<String> _keywordsForLabel(
    String label, {
    List<String> extra = const [],
  }) {
    return {
      label.toLowerCase(),
      ...label.toLowerCase().split(RegExp(r'[\s/]+')),
      ...extra,
    }.toList(growable: false);
  }
}
