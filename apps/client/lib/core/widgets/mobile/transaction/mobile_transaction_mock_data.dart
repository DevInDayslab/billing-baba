import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/transaction/mobile_transaction_catalog.dart';
import 'package:billing_baba/core/widgets/mobile/transaction/mobile_transaction_models.dart';
import 'package:flutter/material.dart';

/// Sample transaction rows for mobile list previews and demos.
///
// TODO(mobile): Replace when feature pages supply live transaction data.
abstract final class MobileTransactionMockData {
  static List<MobileTransactionListItem> itemsFor(
    MobileTransactionScopeDefinition definition,
  ) {
    return switch (definition.route) {
      AppRoutes.saleInvoices => sales,
      AppRoutes.saleEstimateQuotation => estimates,
      AppRoutes.saleProformaInvoice => proforma,
      AppRoutes.salePaymentIn => paymentIn,
      AppRoutes.saleOrder => saleOrders,
      AppRoutes.saleDeliveryChallan => deliveryChallans,
      AppRoutes.saleJobWorkOut => jobWorkOut,
      AppRoutes.saleReturnCreditNote => returns,
      AppRoutes.saleFa => saleFa,
      AppRoutes.purchaseBills => purchases,
      AppRoutes.purchasePaymentOut => paymentOut,
      AppRoutes.purchaseExpenses => expenses,
      AppRoutes.purchaseOrder => purchaseOrders,
      AppRoutes.purchaseReturnDebitNote => purchaseReturns,
      AppRoutes.purchaseFa => purchaseFa,
      _ => _genericFor(definition),
    };
  }

  static List<MobileTransactionListItem> _genericFor(
    MobileTransactionScopeDefinition definition,
  ) {
    return [
      MobileTransactionListItem(
        id: 'mock-${definition.scopeId}-1',
        title: '${definition.title} #001',
        subtitle: 'Sample Party',
        dateLabel: '24 Jul 2026',
        amountLabel: '₹5,000.00',
        statusLabel: 'Open',
        statusColor: AppColors.primary,
        leadingIcon: definition.leadingIcon,
        sortAmount: 5000,
        sortDate: DateTime(2026, 7, 24),
        sortTitle: '${definition.title} #001',
      ),
    ];
  }

  static final List<MobileTransactionListItem> sales = [
    MobileTransactionListItem(
      id: 'mock-sale-1',
      title: 'INV-1042',
      subtitle: 'Sharma Traders',
      dateLabel: '24 Jul 2026',
      amountLabel: '₹12,500.00',
      statusLabel: 'Paid',
      statusColor: const Color(0xFF2E7D32),
      leadingIcon: Icons.receipt_long_outlined,
      sortAmount: 12500,
      sortDate: DateTime(2026, 7, 24),
      sortTitle: 'INV-1042',
    ),
    MobileTransactionListItem(
      id: 'mock-sale-2',
      title: 'INV-1041',
      subtitle: 'Patel & Sons',
      dateLabel: '23 Jul 2026',
      amountLabel: '₹8,200.00',
      statusLabel: 'Unpaid',
      statusColor: const Color(0xFFD32F2F),
      leadingIcon: Icons.receipt_long_outlined,
      sortAmount: 8200,
      sortDate: DateTime(2026, 7, 23),
      sortTitle: 'INV-1041',
    ),
  ];

  static final List<MobileTransactionListItem> estimates = [
    MobileTransactionListItem(
      id: 'mock-estimate-1',
      title: 'EST-088',
      subtitle: 'City Mart',
      dateLabel: '21 Jul 2026',
      amountLabel: '₹3,450.00',
      statusLabel: 'Open',
      statusColor: AppColors.primary,
      leadingIcon: Icons.description_outlined,
      sortAmount: 3450,
      sortDate: DateTime(2026, 7, 21),
      sortTitle: 'EST-088',
    ),
  ];

  static final List<MobileTransactionListItem> proforma = [
    MobileTransactionListItem(
      id: 'mock-proforma-1',
      title: 'PI-012',
      subtitle: 'Metro Retail',
      dateLabel: '20 Jul 2026',
      amountLabel: '₹18,000.00',
      statusLabel: 'Open',
      statusColor: AppColors.primary,
      leadingIcon: Icons.article_outlined,
      sortAmount: 18000,
      sortDate: DateTime(2026, 7, 20),
      sortTitle: 'PI-012',
    ),
  ];

  static final List<MobileTransactionListItem> paymentIn = [
    MobileTransactionListItem(
      id: 'mock-payin-1',
      title: 'PIN-220',
      subtitle: 'Sharma Traders',
      dateLabel: '22 Jul 2026',
      amountLabel: '₹4,500.00',
      statusLabel: 'Recorded',
      statusColor: const Color(0xFF2E7D32),
      leadingIcon: Icons.payments_outlined,
      sortAmount: 4500,
      sortDate: DateTime(2026, 7, 22),
      sortTitle: 'PIN-220',
    ),
  ];

  static final List<MobileTransactionListItem> paymentOut = [
    MobileTransactionListItem(
      id: 'mock-payout-1',
      title: 'POUT-118',
      subtitle: 'Gupta Electronics',
      dateLabel: '22 Jul 2026',
      amountLabel: '₹9,000.00',
      statusLabel: 'Recorded',
      statusColor: const Color(0xFF2E7D32),
      leadingIcon: Icons.payments_outlined,
      sortAmount: 9000,
      sortDate: DateTime(2026, 7, 22),
      sortTitle: 'POUT-118',
    ),
  ];

  static final List<MobileTransactionListItem> saleOrders = [
    MobileTransactionListItem(
      id: 'mock-so-1',
      title: 'SO-045',
      subtitle: 'Reliance Mart',
      dateLabel: '19 Jul 2026',
      amountLabel: '₹25,000.00',
      statusLabel: 'Open',
      statusColor: AppColors.primary,
      leadingIcon: Icons.shopping_bag_outlined,
      sortAmount: 25000,
      sortDate: DateTime(2026, 7, 19),
      sortTitle: 'SO-045',
    ),
  ];

  static final List<MobileTransactionListItem> deliveryChallans = [
    MobileTransactionListItem(
      id: 'mock-dc-1',
      title: 'DC-031',
      subtitle: 'Wholesale Hub',
      dateLabel: '18 Jul 2026',
      amountLabel: '₹6,800.00',
      statusLabel: 'Open',
      statusColor: AppColors.primary,
      leadingIcon: Icons.local_shipping_outlined,
      sortAmount: 6800,
      sortDate: DateTime(2026, 7, 18),
      sortTitle: 'DC-031',
    ),
  ];

  static final List<MobileTransactionListItem> jobWorkOut = [
    MobileTransactionListItem(
      id: 'mock-jwo-1',
      title: 'JWO-007',
      subtitle: 'Precision Works',
      dateLabel: '17 Jul 2026',
      amountLabel: '₹2,400.00',
      statusLabel: 'Open',
      statusColor: AppColors.primary,
      leadingIcon: Icons.precision_manufacturing_outlined,
      sortAmount: 2400,
      sortDate: DateTime(2026, 7, 17),
      sortTitle: 'JWO-007',
    ),
  ];

  static final List<MobileTransactionListItem> returns = [
    MobileTransactionListItem(
      id: 'mock-return-1',
      title: 'CN-014',
      subtitle: 'Sharma Traders',
      dateLabel: '20 Jul 2026',
      amountLabel: '₹1,200.00',
      statusLabel: 'Approved',
      statusColor: const Color(0xFF2E7D32),
      leadingIcon: Icons.undo_rounded,
      sortAmount: 1200,
      sortDate: DateTime(2026, 7, 20),
      sortTitle: 'CN-014',
    ),
  ];

  static final List<MobileTransactionListItem> saleFa = [
    MobileTransactionListItem(
      id: 'mock-sale-fa-1',
      title: 'SFA-003',
      subtitle: 'Asset Buyer',
      dateLabel: '16 Jul 2026',
      amountLabel: '₹75,000.00',
      statusLabel: 'Paid',
      statusColor: const Color(0xFF2E7D32),
      leadingIcon: Icons.account_balance_outlined,
      sortAmount: 75000,
      sortDate: DateTime(2026, 7, 16),
      sortTitle: 'SFA-003',
    ),
  ];

  static final List<MobileTransactionListItem> purchases = [
    MobileTransactionListItem(
      id: 'mock-purchase-1',
      title: 'PB-220',
      subtitle: 'Gupta Electronics',
      dateLabel: '22 Jul 2026',
      amountLabel: '₹45,000.00',
      statusLabel: 'Partial',
      statusColor: const Color(0xFFFF9800),
      leadingIcon: Icons.shopping_cart_outlined,
      sortAmount: 45000,
      sortDate: DateTime(2026, 7, 22),
      sortTitle: 'PB-220',
    ),
  ];

  static final List<MobileTransactionListItem> expenses = [
    MobileTransactionListItem(
      id: 'mock-expense-1',
      title: 'Office Rent',
      subtitle: 'July 2026',
      dateLabel: '01 Jul 2026',
      amountLabel: '₹15,000.00',
      statusLabel: 'Recorded',
      statusColor: AppColors.textSecondary,
      leadingIcon: Icons.money_off_outlined,
      sortAmount: 15000,
      sortDate: DateTime(2026, 7),
      sortTitle: 'Office Rent',
    ),
  ];

  static final List<MobileTransactionListItem> purchaseOrders = [
    MobileTransactionListItem(
      id: 'mock-po-1',
      title: 'PO-089',
      subtitle: 'National Distributors',
      dateLabel: '15 Jul 2026',
      amountLabel: '₹32,000.00',
      statusLabel: 'Open',
      statusColor: AppColors.primary,
      leadingIcon: Icons.assignment_outlined,
      sortAmount: 32000,
      sortDate: DateTime(2026, 7, 15),
      sortTitle: 'PO-089',
    ),
  ];

  static final List<MobileTransactionListItem> purchaseReturns = [
    MobileTransactionListItem(
      id: 'mock-pr-1',
      title: 'DN-006',
      subtitle: 'Gupta Electronics',
      dateLabel: '14 Jul 2026',
      amountLabel: '₹2,800.00',
      statusLabel: 'Approved',
      statusColor: const Color(0xFF2E7D32),
      leadingIcon: Icons.undo_rounded,
      sortAmount: 2800,
      sortDate: DateTime(2026, 7, 14),
      sortTitle: 'DN-006',
    ),
  ];

  static final List<MobileTransactionListItem> purchaseFa = [
    MobileTransactionListItem(
      id: 'mock-pfa-1',
      title: 'PFA-002',
      subtitle: 'Asset Vendor',
      dateLabel: '13 Jul 2026',
      amountLabel: '₹1,20,000.00',
      statusLabel: 'Paid',
      statusColor: const Color(0xFF2E7D32),
      leadingIcon: Icons.account_balance_outlined,
      sortAmount: 120000,
      sortDate: DateTime(2026, 7, 13),
      sortTitle: 'PFA-002',
    ),
  ];
}
