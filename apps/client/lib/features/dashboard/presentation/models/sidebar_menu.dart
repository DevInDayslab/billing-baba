import 'package:billing_baba/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Declarative sidebar navigation tree.
class SidebarMenuItem {
  const SidebarMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    this.route,
    this.children = const [],
    this.permission,
    this.badge,
  });

  final String id;
  final String title;
  final IconData icon;
  final String? route;
  final List<SidebarMenuItem> children;
  final String? permission;
  final String? badge;

  bool get isExpandable => children.isNotEmpty;
}

abstract final class SidebarMenu {
  static const List<SidebarMenuItem> items = [
    SidebarMenuItem(
      id: 'home',
      title: 'Home',
      icon: LucideIcons.house,
      route: AppRoutes.home,
    ),
    SidebarMenuItem(
      id: 'parties',
      title: 'Parties',
      icon: LucideIcons.users,
      children: [
        SidebarMenuItem(
          id: 'parties-customers',
          title: 'Customers',
          icon: LucideIcons.user,
          route: AppRoutes.partiesCustomers,
        ),
        SidebarMenuItem(
          id: 'parties-suppliers',
          title: 'Suppliers',
          icon: LucideIcons.truck,
          route: AppRoutes.partiesSuppliers,
        ),
      ],
    ),
    SidebarMenuItem(
      id: 'items',
      title: 'Items',
      icon: LucideIcons.package,
      children: [
        SidebarMenuItem(
          id: 'items-products',
          title: 'Products',
          icon: LucideIcons.box,
          route: AppRoutes.items,
        ),
        SidebarMenuItem(
          id: 'items-categories',
          title: 'Categories',
          icon: LucideIcons.layers,
          route: AppRoutes.itemsCategories,
        ),
        SidebarMenuItem(
          id: 'items-units',
          title: 'Units',
          icon: LucideIcons.ruler,
          route: AppRoutes.itemsUnits,
        ),
        SidebarMenuItem(
          id: 'items-godowns',
          title: 'Godowns',
          icon: LucideIcons.warehouse,
          route: AppRoutes.itemsGodowns,
        ),
        SidebarMenuItem(
          id: 'items-stock-transfer',
          title: 'Stock Transfer',
          icon: LucideIcons.arrowLeftRight,
          route: AppRoutes.itemsStockTransfer,
        ),
      ],
    ),
    SidebarMenuItem(
      id: 'sale',
      title: 'Sale',
      icon: LucideIcons.receipt,
      children: [
        SidebarMenuItem(
          id: 'sale-invoices',
          title: 'Sales Invoice',
          icon: LucideIcons.fileText,
          route: AppRoutes.saleInvoices,
        ),
        SidebarMenuItem(
          id: 'sale-estimate',
          title: 'Estimate / Quotation',
          icon: LucideIcons.filePen,
          route: AppRoutes.saleEstimateQuotation,
        ),
        SidebarMenuItem(
          id: 'sale-delivery-challan',
          title: 'Delivery Challan',
          icon: LucideIcons.clipboardList,
          route: AppRoutes.saleDeliveryChallan,
        ),
        SidebarMenuItem(
          id: 'sale-return',
          title: 'Sales Return',
          icon: LucideIcons.undo2,
          route: AppRoutes.saleReturnCreditNote,
        ),
        SidebarMenuItem(
          id: 'sale-credit-note',
          title: 'Credit Note',
          icon: LucideIcons.fileMinus,
          route: AppRoutes.addCreditNote,
        ),
      ],
    ),
    SidebarMenuItem(
      id: 'purchase-expense',
      title: 'Purchase & Expense',
      icon: LucideIcons.shoppingCart,
      children: [
        SidebarMenuItem(
          id: 'purchase',
          title: 'Purchase',
          icon: LucideIcons.shoppingBag,
          route: AppRoutes.purchase,
        ),
        SidebarMenuItem(
          id: 'purchase-return',
          title: 'Purchase Return',
          icon: LucideIcons.rotateCcw,
          route: AppRoutes.purchaseReturn,
        ),
        SidebarMenuItem(
          id: 'expenses',
          title: 'Expenses',
          icon: LucideIcons.wallet,
          route: AppRoutes.expenses,
        ),
        SidebarMenuItem(
          id: 'debit-note',
          title: 'Debit Note',
          icon: LucideIcons.filePlus,
          route: AppRoutes.debitNote,
        ),
      ],
    ),
    SidebarMenuItem(
      id: 'reports',
      title: 'Reports',
      icon: LucideIcons.chartBar,
      children: [
        SidebarMenuItem(
          id: 'reports-dashboard',
          title: 'Dashboard',
          icon: LucideIcons.layoutDashboard,
          route: AppRoutes.reportsDashboard,
        ),
        SidebarMenuItem(
          id: 'reports-sales',
          title: 'Sales Reports',
          icon: LucideIcons.trendingUp,
          route: AppRoutes.reportsSales,
        ),
        SidebarMenuItem(
          id: 'reports-purchase',
          title: 'Purchase Reports',
          icon: LucideIcons.trendingDown,
          route: AppRoutes.reportsPurchase,
        ),
        SidebarMenuItem(
          id: 'reports-stock',
          title: 'Stock Reports',
          icon: LucideIcons.packageSearch,
          route: AppRoutes.reportsStock,
        ),
        SidebarMenuItem(
          id: 'reports-party',
          title: 'Party Reports',
          icon: LucideIcons.usersRound,
          route: AppRoutes.reportsParty,
        ),
        SidebarMenuItem(
          id: 'reports-gst',
          title: 'GST Reports',
          icon: LucideIcons.percent,
          route: AppRoutes.reportsGst,
        ),
      ],
    ),
    SidebarMenuItem(
      id: 'settings',
      title: 'Settings',
      icon: LucideIcons.settings,
      children: [
        SidebarMenuItem(
          id: 'settings-profile',
          title: 'Business Profile',
          icon: LucideIcons.building2,
          route: AppRoutes.editProfile,
        ),
        SidebarMenuItem(
          id: 'settings-users',
          title: 'Users & Roles',
          icon: LucideIcons.userCog,
          route: AppRoutes.settingsUsers,
        ),
        SidebarMenuItem(
          id: 'settings-taxes',
          title: 'Taxes',
          icon: LucideIcons.calculator,
          route: AppRoutes.settingsTaxes,
        ),
        SidebarMenuItem(
          id: 'settings-invoice-templates',
          title: 'Invoice Templates',
          icon: LucideIcons.fileStack,
          route: AppRoutes.settingsInvoiceTemplates,
        ),
        SidebarMenuItem(
          id: 'settings-preferences',
          title: 'Preferences',
          icon: LucideIcons.slidersHorizontal,
          route: AppRoutes.settingsPreferences,
        ),
        SidebarMenuItem(
          id: 'settings-backup',
          title: 'Backup & Restore',
          icon: LucideIcons.cloudUpload,
          route: AppRoutes.settingsBackup,
        ),
      ],
    ),
    SidebarMenuItem(
      id: 'plans-pricing',
      title: 'Plans & Pricing',
      icon: LucideIcons.badgeDollarSign,
      route: AppRoutes.plansPricing,
    ),
  ];
}
