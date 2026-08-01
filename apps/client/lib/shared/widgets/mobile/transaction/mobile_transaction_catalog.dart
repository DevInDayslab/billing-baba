import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/purchases/models/purchase_sub_route.dart';
import 'package:billing_baba/features/sales/models/sale_sub_route.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// High-level grouping for mobile transaction list pages.
enum MobileTransactionCategory {
  sales,
  purchase,
  other,
}

/// Static definition for a reusable mobile transaction list scope.
class MobileTransactionScopeDefinition {
  const MobileTransactionScopeDefinition({
    required this.scopeId,
    required this.route,
    required this.title,
    required this.category,
    this.searchHint,
    this.addRoute,
    this.addFabLabel,
    this.filterOptions = MobileTransactionCatalog.defaultStatusFilters,
    this.emptyTitle,
    this.emptyMessage,
    this.leadingIcon,
    this.isP2P = false,
  });

  final String scopeId;
  final String route;
  final String title;
  final MobileTransactionCategory category;
  final String? searchHint;
  final String? addRoute;
  final String? addFabLabel;
  final List<MobileFilterOption> filterOptions;
  final String? emptyTitle;
  final String? emptyMessage;
  final IconData? leadingIcon;

  /// Party-to-party payment lists (Payment-In / Payment-Out).
  final bool isP2P;

  MobileTransactionPageConfig config(
    BuildContext context, {
    String? titleOverride,
  }) {
    final resolvedTitle = titleOverride ?? title;
    return MobileTransactionPageConfig(
      scopeId: scopeId,
      title: resolvedTitle,
      searchHint: searchHint ?? 'Search $resolvedTitle',
      filterOptions: filterOptions,
      emptyState: MobileTransactionEmptyStateConfig(
        title: emptyTitle ?? 'No $resolvedTitle yet',
        message: emptyMessage ?? 'Tap + to create your first entry.',
        icon: leadingIcon ?? Icons.receipt_long_outlined,
        actionLabel: addRoute == null ? null : addFabLabel ?? 'Add',
        onAction: addRoute == null ? null : () => context.push(addRoute!),
      ),
      fabTooltip: addFabLabel ?? 'Add',
      onFabPressed: addRoute == null ? null : () => context.push(addRoute!),
    );
  }
}

/// Registry of mobile transaction list scopes for sales, purchases, and others.
abstract final class MobileTransactionCatalog {
  static const defaultStatusFilters = [
    MobileFilterOption(key: MobileFilterOption.allKey, label: 'All'),
    MobileFilterOption(key: 'paid', label: 'Paid'),
    MobileFilterOption(key: 'unpaid', label: 'Unpaid'),
    MobileFilterOption(key: 'partial', label: 'Partial'),
    MobileFilterOption(key: 'open', label: 'Open'),
  ];

  static final Map<String, MobileTransactionScopeDefinition> _byRoute = {
    for (final def in all) def.route: def,
  };

  static final List<MobileTransactionScopeDefinition> all = [
    ..._salesDefinitions,
    ..._purchaseDefinitions,
    ..._otherDefinitions,
  ];

  static List<MobileTransactionScopeDefinition> get sales =>
      all.where((d) => d.category == MobileTransactionCategory.sales).toList();

  static List<MobileTransactionScopeDefinition> get purchases => all
      .where((d) => d.category == MobileTransactionCategory.purchase)
      .toList();

  static List<MobileTransactionScopeDefinition> get others =>
      all.where((d) => d.category == MobileTransactionCategory.other).toList();

  static MobileTransactionScopeDefinition? definitionForRoute(String route) {
    return _byRoute[route];
  }

  static bool statusFilterMatcher(
    MobileTransactionListItem item,
    String filterKey,
  ) {
    final status = (item.statusLabel ?? '').toLowerCase();
    return switch (filterKey) {
      'paid' => status.contains('paid'),
      'unpaid' => status.contains('unpaid'),
      'partial' => status.contains('partial'),
      'open' => status.contains('open'),
      _ => true,
    };
  }

  static final List<MobileTransactionScopeDefinition> _salesDefinitions = [
    for (final sub in SaleSubRoutes.items)
      MobileTransactionScopeDefinition(
        scopeId: _scopeId(sub.route),
        route: sub.route,
        title: sub.pageTitle ?? sub.label,
        category: MobileTransactionCategory.sales,
        addRoute: _salesAddRoute(sub.route),
        addFabLabel: _salesAddLabel(sub.route),
        leadingIcon: _salesIcon(sub.route),
        isP2P: sub.route == AppRoutes.salePaymentIn,
        emptyMessage: sub.route == AppRoutes.salePaymentIn
            ? 'Record a payment received from a party.'
            : null,
      ),
  ];

  static final List<MobileTransactionScopeDefinition> _purchaseDefinitions = [
    for (final sub in PurchaseSubRoutes.items)
      MobileTransactionScopeDefinition(
        scopeId: _scopeId(sub.route),
        route: sub.route,
        title: sub.pageTitle ?? sub.label,
        category: MobileTransactionCategory.purchase,
        addRoute: _purchaseAddRoute(sub.route),
        addFabLabel: _purchaseAddLabel(sub.route),
        leadingIcon: _purchaseIcon(sub.route),
        isP2P: sub.route == AppRoutes.purchasePaymentOut,
        emptyMessage: sub.route == AppRoutes.purchasePaymentOut
            ? 'Record a payment made to a party.'
            : null,
      ),
  ];

  /// Non sale/purchase list routes (excludes P2P payment lists).
  static final List<MobileTransactionScopeDefinition> _otherDefinitions = [
    // Reserved for future "other" transaction modules (stock transfer, etc.).
  ];

  static String _scopeId(String route) =>
      route.replaceFirst('/', '').replaceAll('/', '-');

  static String? _salesAddRoute(String route) => switch (route) {
    AppRoutes.saleInvoices => AppRoutes.addSale,
    AppRoutes.saleEstimateQuotation => AppRoutes.addEstimate,
    AppRoutes.saleOrder => AppRoutes.addSaleOrder,
    AppRoutes.saleDeliveryChallan => AppRoutes.addDeliveryChallan,
    AppRoutes.saleReturnCreditNote => AppRoutes.addCreditNote,
    AppRoutes.saleFa => AppRoutes.addSaleFa,
      AppRoutes.salePaymentIn => AppRoutes.addPaymentIn,
      AppRoutes.saleProformaInvoice => AppRoutes.addEstimate,
      AppRoutes.saleJobWorkOut => AppRoutes.addJobWork,
    _ => null,
  };

  static String? _salesAddLabel(String route) => switch (route) {
    AppRoutes.saleInvoices => 'Add Sale',
    AppRoutes.saleEstimateQuotation => 'Add Estimate',
    AppRoutes.saleOrder => 'Add Order',
    AppRoutes.saleDeliveryChallan => 'Add Challan',
    AppRoutes.saleReturnCreditNote => 'Add Credit Note',
    AppRoutes.saleFa => 'Add Sale FA',
    _ => 'Add',
  };

  static IconData _salesIcon(String route) => switch (route) {
    AppRoutes.saleInvoices => Icons.receipt_long_outlined,
    AppRoutes.saleEstimateQuotation => Icons.description_outlined,
    AppRoutes.saleProformaInvoice => Icons.article_outlined,
    AppRoutes.salePaymentIn => Icons.payments_outlined,
    AppRoutes.saleOrder => Icons.shopping_bag_outlined,
    AppRoutes.saleDeliveryChallan => Icons.local_shipping_outlined,
    AppRoutes.saleJobWorkOut => Icons.precision_manufacturing_outlined,
    AppRoutes.saleReturnCreditNote => Icons.undo_rounded,
    AppRoutes.saleFa => Icons.account_balance_outlined,
    _ => Icons.receipt_long_outlined,
  };

  static String? _purchaseAddRoute(String route) => switch (route) {
    AppRoutes.purchaseBills => AppRoutes.addPurchase,
    AppRoutes.purchaseExpenses => AppRoutes.addExpense,
    AppRoutes.purchaseOrder => AppRoutes.addPurchaseOrder,
    AppRoutes.purchaseReturnDebitNote => AppRoutes.addDebitNote,
    AppRoutes.purchaseFa => AppRoutes.addPurchaseFa,
    AppRoutes.purchasePaymentOut => AppRoutes.addPaymentOut,
    _ => null,
  };

  static String? _purchaseAddLabel(String route) => switch (route) {
    AppRoutes.purchaseBills => 'Add Purchase',
    AppRoutes.purchaseExpenses => 'Add Expense',
    AppRoutes.purchaseOrder => 'Add Order',
    AppRoutes.purchaseReturnDebitNote => 'Add Debit Note',
    AppRoutes.purchaseFa => 'Add Purchase FA',
    _ => 'Add',
  };

  static IconData _purchaseIcon(String route) => switch (route) {
    AppRoutes.purchaseBills => Icons.shopping_cart_outlined,
    AppRoutes.purchasePaymentOut => Icons.payments_outlined,
    AppRoutes.purchaseExpenses => Icons.money_off_outlined,
    AppRoutes.purchaseOrder => Icons.assignment_outlined,
    AppRoutes.purchaseReturnDebitNote => Icons.undo_rounded,
    AppRoutes.purchaseFa => Icons.account_balance_outlined,
    _ => Icons.shopping_cart_outlined,
  };
}
