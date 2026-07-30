import 'package:billing_baba/features/reports/models/business_status_report_subsection.dart';
import 'package:billing_baba/features/reports/models/expense_report_subsection.dart';
import 'package:billing_baba/features/reports/models/gst_report_subsection.dart';
import 'package:billing_baba/features/reports/models/item_stock_report_subsection.dart';
import 'package:billing_baba/features/reports/models/loan_accounts_report_subsection.dart';
import 'package:billing_baba/features/reports/models/other_income_report_subsection.dart';
import 'package:billing_baba/features/reports/models/party_report_subsection.dart';
import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:billing_baba/features/reports/models/sale_purchase_order_report_subsection.dart';
import 'package:billing_baba/features/reports/models/taxes_report_subsection.dart';
import 'package:billing_baba/features/reports/models/transaction_report_subsection.dart';
import 'package:billing_baba/features/search/domain/search_category.dart';
import 'package:billing_baba/features/search/domain/search_item.dart';
import 'package:flutter/material.dart';

/// ERP report pages exposed in navigation search.
abstract final class SearchRegistryReports {
  static List<SearchItem> items() => [
    ..._transactionReports(),
    ..._partyReports(),
    ..._gstReports(),
    ..._itemStockReports(),
    ..._businessStatusReports(),
    ..._taxesReports(),
    ..._expenseReports(),
    ..._salePurchaseOrderReports(),
    ..._otherIncomeReports(),
    ..._loanAccountReports(),
  ];

  static List<SearchItem> _transactionReports() {
    return TransactionReportSubSection.values
        .map((sub) {
          final title = switch (sub) {
            TransactionReportSubSection.sale => 'Sale Report',
            TransactionReportSubSection.purchase => 'Purchase Report',
            _ => sub.label,
          };
          return _reportItem(
            id: 'report_transaction_${sub.name}',
            title: title,
            intent: ReportsNavIntent.transaction(sub),
            keywords: [sub.label, 'report', 'transaction'],
          );
        })
        .toList(growable: false);
  }

  static List<SearchItem> _partyReports() {
    return PartyReportSubSection.values
        .map(
          (sub) => _reportItem(
            id: 'report_party_${sub.name}',
            title: sub.label,
            intent: ReportsNavIntent.party(sub),
            keywords: [sub.label, 'report', 'party'],
          ),
        )
        .toList(growable: false);
  }

  static List<SearchItem> _gstReports() {
    return GstReportSubSection.values
        .map(
          (sub) => _reportItem(
            id: 'report_gst_${sub.name}',
            title: sub.label,
            intent: ReportsNavIntent.gst(sub),
            keywords: [sub.label, 'report', 'gst', 'gstr'],
          ),
        )
        .toList(growable: false);
  }

  static List<SearchItem> _itemStockReports() {
    return ItemStockReportSubSection.values
        .map(
          (sub) => _reportItem(
            id: 'report_item_stock_${sub.name}',
            title: sub.label,
            intent: ReportsNavIntent.itemStock(sub),
            keywords: [sub.label, 'report', 'stock', 'item'],
          ),
        )
        .toList(growable: false);
  }

  static List<SearchItem> _businessStatusReports() {
    return BusinessStatusReportSubSection.values
        .map(
          (sub) => _reportItem(
            id: 'report_business_status_${sub.name}',
            title: sub.label,
            intent: ReportsNavIntent.businessStatus(sub),
            keywords: [sub.label, 'report', 'business'],
          ),
        )
        .toList(growable: false);
  }

  static List<SearchItem> _taxesReports() {
    return TaxesReportSubSection.values
        .map(
          (sub) => _reportItem(
            id: 'report_taxes_${sub.name}',
            title: sub.pageTitle,
            intent: ReportsNavIntent.taxes(sub),
            keywords: [sub.label, sub.pageTitle, 'report', 'tax', 'gst'],
          ),
        )
        .toList(growable: false);
  }

  static List<SearchItem> _expenseReports() {
    return ExpenseReportSubSection.values
        .map(
          (sub) => _reportItem(
            id: 'report_expense_${sub.name}',
            title: sub.label,
            intent: ReportsNavIntent.expense(sub),
            keywords: [sub.label, 'report', 'expense'],
          ),
        )
        .toList(growable: false);
  }

  static List<SearchItem> _salePurchaseOrderReports() {
    return SalePurchaseOrderReportSubSection.values
        .map(
          (sub) => _reportItem(
            id: 'report_sale_purchase_order_${sub.name}',
            title: sub.label,
            intent: ReportsNavIntent.salePurchaseOrder(sub),
            keywords: [sub.label, 'report', 'sale', 'purchase', 'order'],
          ),
        )
        .toList(growable: false);
  }

  static List<SearchItem> _otherIncomeReports() {
    return OtherIncomeReportSubSection.values
        .map(
          (sub) => _reportItem(
            id: 'report_other_income_${sub.name}',
            title: sub.label,
            intent: ReportsNavIntent.otherIncome(sub),
            keywords: [sub.label, 'report', 'income'],
          ),
        )
        .toList(growable: false);
  }

  static List<SearchItem> _loanAccountReports() {
    return LoanAccountsReportSubSection.values
        .map(
          (sub) => _reportItem(
            id: 'report_loan_accounts_${sub.name}',
            title: sub.label,
            intent: ReportsNavIntent.loanAccounts(sub),
            keywords: [sub.label, 'report', 'loan'],
          ),
        )
        .toList(growable: false);
  }

  static SearchItem _reportItem({
    required String id,
    required String title,
    required ReportsNavIntent intent,
    required List<String> keywords,
  }) {
    return SearchItem(
      id: id,
      title: title,
      icon: Icons.assessment_outlined,
      category: SearchCategory.page,
      action: SearchActionKind.openReport,
      reportIntent: intent,
      keywords: keywords,
    );
  }
}
