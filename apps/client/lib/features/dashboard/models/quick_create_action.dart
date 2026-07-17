import 'package:billing_baba/core/router/app_routes.dart';
import 'package:flutter/services.dart';

/// Column grouping for the quick-create popover.
enum QuickCreateCategory {
  sale,
  purchase,
  others,
}

/// How a quick-create item is launched.
enum QuickCreateActionType {
  routePush,
  routeGo,
  paymentInDialog,
  paymentOutDialog,
  proformaForm,
}

/// One entry in the quick-create menu.
final class QuickCreateAction {
  const QuickCreateAction({
    required this.id,
    required this.label,
    required this.category,
    required this.type,
    this.subtitle,
    this.route,
    this.shortcutKey,
  });

  final String id;
  final String label;
  final String? subtitle;
  final QuickCreateCategory category;
  final QuickCreateActionType type;
  final String? route;
  final LogicalKeyboardKey? shortcutKey;

  String get categoryLabel => switch (category) {
    QuickCreateCategory.sale => 'SALE',
    QuickCreateCategory.purchase => 'PURCHASE',
    QuickCreateCategory.others => 'OTHERS',
  };
}

/// Registry of implemented quick-create actions.
abstract final class QuickCreateActions {
  static const _all = <QuickCreateAction>[
    QuickCreateAction(
      id: 'sale_invoice',
      label: 'Sale Invoice',
      category: QuickCreateCategory.sale,
      type: QuickCreateActionType.routePush,
      route: AppRoutes.addSale,
      shortcutKey: LogicalKeyboardKey.keyS,
    ),
    QuickCreateAction(
      id: 'payment_in',
      label: 'Payment-In',
      category: QuickCreateCategory.sale,
      type: QuickCreateActionType.paymentInDialog,
      shortcutKey: LogicalKeyboardKey.keyI,
    ),
    QuickCreateAction(
      id: 'sale_return',
      label: 'Sale Return',
      subtitle: 'Cr Note',
      category: QuickCreateCategory.sale,
      type: QuickCreateActionType.routePush,
      route: AppRoutes.addCreditNote,
      shortcutKey: LogicalKeyboardKey.keyR,
    ),
    QuickCreateAction(
      id: 'sale_order',
      label: 'Sale Order',
      category: QuickCreateCategory.sale,
      type: QuickCreateActionType.routePush,
      route: AppRoutes.addSaleOrder,
      shortcutKey: LogicalKeyboardKey.keyF,
    ),
    QuickCreateAction(
      id: 'estimate_quotation',
      label: 'Estimate/Quotation',
      category: QuickCreateCategory.sale,
      type: QuickCreateActionType.routePush,
      route: AppRoutes.addEstimate,
      shortcutKey: LogicalKeyboardKey.keyM,
    ),
    QuickCreateAction(
      id: 'proforma_invoice',
      label: 'Proforma Invoice',
      category: QuickCreateCategory.sale,
      type: QuickCreateActionType.proformaForm,
      shortcutKey: LogicalKeyboardKey.keyK,
    ),
    QuickCreateAction(
      id: 'delivery_challan',
      label: 'Delivery Challan',
      category: QuickCreateCategory.sale,
      type: QuickCreateActionType.routePush,
      route: AppRoutes.addDeliveryChallan,
      shortcutKey: LogicalKeyboardKey.keyD,
    ),
    QuickCreateAction(
      id: 'sale_assets',
      label: 'Sale Assets',
      category: QuickCreateCategory.sale,
      type: QuickCreateActionType.routePush,
      route: AppRoutes.addSaleFa,
    ),
    QuickCreateAction(
      id: 'purchase_bill',
      label: 'Purchase Bill',
      category: QuickCreateCategory.purchase,
      type: QuickCreateActionType.routePush,
      route: AppRoutes.addPurchase,
      shortcutKey: LogicalKeyboardKey.keyP,
    ),
    QuickCreateAction(
      id: 'payment_out',
      label: 'Payment-Out',
      category: QuickCreateCategory.purchase,
      type: QuickCreateActionType.paymentOutDialog,
      shortcutKey: LogicalKeyboardKey.keyO,
    ),
    QuickCreateAction(
      id: 'purchase_return',
      label: 'Purchase Return',
      subtitle: 'Dr Note',
      category: QuickCreateCategory.purchase,
      type: QuickCreateActionType.routePush,
      route: AppRoutes.addDebitNote,
      shortcutKey: LogicalKeyboardKey.keyL,
    ),
    QuickCreateAction(
      id: 'purchase_order',
      label: 'Purchase Order',
      category: QuickCreateCategory.purchase,
      type: QuickCreateActionType.routePush,
      route: AppRoutes.addPurchaseOrder,
      shortcutKey: LogicalKeyboardKey.keyG,
    ),
    QuickCreateAction(
      id: 'purchase_assets',
      label: 'Purchase Assets',
      category: QuickCreateCategory.purchase,
      type: QuickCreateActionType.routePush,
      route: AppRoutes.addPurchaseFa,
    ),
    QuickCreateAction(
      id: 'expenses',
      label: 'Expenses',
      category: QuickCreateCategory.others,
      type: QuickCreateActionType.routePush,
      route: AppRoutes.addExpense,
      shortcutKey: LogicalKeyboardKey.keyE,
    ),
  ];

  static List<QuickCreateAction> get available => _all;

  static QuickCreateAction? byId(String id) {
    for (final action in _all) {
      if (action.id == id) return action;
    }
    return null;
  }

  static List<QuickCreateAction> forCategory(QuickCreateCategory category) {
    return _all.where((action) => action.category == category).toList();
  }

  static QuickCreateAction? byShortcut(LogicalKeyboardKey key) {
    for (final action in _all) {
      if (action.shortcutKey == key) return action;
    }
    return null;
  }
}
