import 'package:billing_baba/features/reports/models/business_status_report_subsection.dart';
import 'package:billing_baba/features/reports/models/expense_report_subsection.dart';
import 'package:billing_baba/features/reports/models/gst_report_subsection.dart';
import 'package:billing_baba/features/reports/models/item_stock_report_subsection.dart';
import 'package:billing_baba/features/reports/models/loan_accounts_report_subsection.dart';
import 'package:billing_baba/features/reports/models/other_income_report_subsection.dart';
import 'package:billing_baba/features/reports/models/party_report_subsection.dart';
import 'package:billing_baba/features/reports/models/report_nav_group.dart';
import 'package:billing_baba/features/reports/models/sale_purchase_order_report_subsection.dart';
import 'package:billing_baba/features/reports/models/taxes_report_subsection.dart';
import 'package:billing_baba/features/reports/models/transaction_report_subsection.dart';

/// One-shot navigation target for reports when opened from search.
final class ReportsNavIntent {
  const ReportsNavIntent._({
    required this.group,
    this.transactionSub,
    this.partySub,
    this.gstSub,
    this.itemStockSub,
    this.businessStatusSub,
    this.taxesSub,
    this.expenseSub,
    this.expenseCategoryId,
    this.expenseCategoryName,
    this.salePurchaseOrderSub,
    this.otherIncomeSub,
    this.loanAccountsSub,
    this.bankAccountId,
  });

  factory ReportsNavIntent.transaction(TransactionReportSubSection sub) {
    return ReportsNavIntent._(
      group: ReportNavGroup.transaction,
      transactionSub: sub,
    );
  }

  factory ReportsNavIntent.party(PartyReportSubSection sub) {
    return ReportsNavIntent._(
      group: ReportNavGroup.party,
      partySub: sub,
    );
  }

  factory ReportsNavIntent.gst(GstReportSubSection sub) {
    return ReportsNavIntent._(
      group: ReportNavGroup.gst,
      gstSub: sub,
    );
  }

  factory ReportsNavIntent.itemStock(ItemStockReportSubSection sub) {
    return ReportsNavIntent._(
      group: ReportNavGroup.itemStock,
      itemStockSub: sub,
    );
  }

  factory ReportsNavIntent.businessStatus(
    BusinessStatusReportSubSection sub, {
    String? bankAccountId,
  }) {
    return ReportsNavIntent._(
      group: ReportNavGroup.businessStatus,
      businessStatusSub: sub,
      bankAccountId: bankAccountId,
    );
  }

  factory ReportsNavIntent.taxes(TaxesReportSubSection sub) {
    return ReportsNavIntent._(
      group: ReportNavGroup.taxes,
      taxesSub: sub,
    );
  }

  factory ReportsNavIntent.expense(
    ExpenseReportSubSection sub, {
    String? categoryId,
    String? categoryName,
  }) {
    return ReportsNavIntent._(
      group: ReportNavGroup.expenseReport,
      expenseSub: sub,
      expenseCategoryId: categoryId,
      expenseCategoryName: categoryName,
    );
  }

  factory ReportsNavIntent.salePurchaseOrder(
    SalePurchaseOrderReportSubSection sub,
  ) {
    return ReportsNavIntent._(
      group: ReportNavGroup.salePurchaseOrderReport,
      salePurchaseOrderSub: sub,
    );
  }

  factory ReportsNavIntent.otherIncome(OtherIncomeReportSubSection sub) {
    return ReportsNavIntent._(
      group: ReportNavGroup.otherIncomeReport,
      otherIncomeSub: sub,
    );
  }

  factory ReportsNavIntent.loanAccounts(LoanAccountsReportSubSection sub) {
    return ReportsNavIntent._(
      group: ReportNavGroup.loanAccounts,
      loanAccountsSub: sub,
    );
  }

  final ReportNavGroup group;
  final TransactionReportSubSection? transactionSub;
  final PartyReportSubSection? partySub;
  final GstReportSubSection? gstSub;
  final ItemStockReportSubSection? itemStockSub;
  final BusinessStatusReportSubSection? businessStatusSub;
  final TaxesReportSubSection? taxesSub;
  final ExpenseReportSubSection? expenseSub;
  final String? expenseCategoryId;
  final String? expenseCategoryName;
  final SalePurchaseOrderReportSubSection? salePurchaseOrderSub;
  final OtherIncomeReportSubSection? otherIncomeSub;
  final LoanAccountsReportSubSection? loanAccountsSub;
  final String? bankAccountId;
}
