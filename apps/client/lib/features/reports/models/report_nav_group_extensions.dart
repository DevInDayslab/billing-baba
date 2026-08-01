import 'package:billing_baba/features/reports/models/report_nav_group.dart';
import 'package:flutter/material.dart';

extension ReportNavGroupExtensions on ReportNavGroup {
  String get id => switch (this) {
    ReportNavGroup.transaction => 'transaction',
    ReportNavGroup.party => 'party',
    ReportNavGroup.gst => 'gst',
    ReportNavGroup.itemStock => 'item-stock',
    ReportNavGroup.businessStatus => 'business-status',
    ReportNavGroup.taxes => 'taxes',
    ReportNavGroup.expenseReport => 'expense',
    ReportNavGroup.salePurchaseOrderReport => 'sale-purchase-order',
    ReportNavGroup.otherIncomeReport => 'other-income',
    ReportNavGroup.loanAccounts => 'loan-accounts',
  };

  String get label => switch (this) {
    ReportNavGroup.transaction => 'Transaction report',
    ReportNavGroup.party => 'Party report',
    ReportNavGroup.gst => 'GST reports',
    ReportNavGroup.itemStock => 'Item/Stock report',
    ReportNavGroup.businessStatus => 'Business Status',
    ReportNavGroup.taxes => 'Taxes',
    ReportNavGroup.expenseReport => 'Expense report',
    ReportNavGroup.salePurchaseOrderReport => 'Sale/Purchase Order Report',
    ReportNavGroup.otherIncomeReport => 'Other Income Report',
    ReportNavGroup.loanAccounts => 'Loan Accounts',
  };

  String get subtitle => switch (this) {
    ReportNavGroup.transaction => 'Sales, purchases, P&L, and cash flow',
    ReportNavGroup.party => 'Party statements and party-wise analysis',
    ReportNavGroup.gst => 'GSTR returns and HSN summaries',
    ReportNavGroup.itemStock => 'Stock, item detail, and inventory reports',
    ReportNavGroup.businessStatus => 'Bank and business status reports',
    ReportNavGroup.taxes => 'GST, TDS, and TCS tax reports',
    ReportNavGroup.expenseReport => 'Expense and category breakdowns',
    ReportNavGroup.salePurchaseOrderReport => 'Order and order-item reports',
    ReportNavGroup.otherIncomeReport => 'Other income and category reports',
    ReportNavGroup.loanAccounts => 'Loan account statements',
  };

  IconData get icon => switch (this) {
    ReportNavGroup.transaction => Icons.receipt_long_outlined,
    ReportNavGroup.party => Icons.people_outline,
    ReportNavGroup.gst => Icons.account_balance_outlined,
    ReportNavGroup.itemStock => Icons.inventory_2_outlined,
    ReportNavGroup.businessStatus => Icons.business_outlined,
    ReportNavGroup.taxes => Icons.percent_outlined,
    ReportNavGroup.expenseReport => Icons.payments_outlined,
    ReportNavGroup.salePurchaseOrderReport => Icons.shopping_cart_outlined,
    ReportNavGroup.otherIncomeReport => Icons.savings_outlined,
    ReportNavGroup.loanAccounts => Icons.account_balance_wallet_outlined,
  };

  static ReportNavGroup? fromId(String id) {
    for (final group in ReportNavGroup.values) {
      if (group.id == id) return group;
    }
    return null;
  }
}
