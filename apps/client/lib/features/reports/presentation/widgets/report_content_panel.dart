import 'package:billing_baba/core/theme/app_theme.dart';
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
import 'package:billing_baba/features/reports/presentation/widgets/business_status/bank_statement_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/expense/expense_category_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/expense/expense_item_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/expense/expense_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/gst/gstr1_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/gst/gstr2_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/gst/gstr3b_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/gst/gstr9_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/gst/sac_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/gst/sale_summary_by_hsn_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/consumption_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/item_category_wise_profit_loss_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/item_detail_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/item_report_by_party_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/item_wise_discount_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/item_wise_profit_loss_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/low_stock_summary_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/manufacturing_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/sale_purchase_report_by_item_category_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/stock_detail_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/stock_summary_report_by_item_category_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/stock_summary_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/item_stock/stock_transfer_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/loan_accounts/loan_statement_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/party/all_parties_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/party/party_report_by_item_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/party/party_statement_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/party/party_wise_profit_loss_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/party/sale_purchase_by_party_group_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/party/sale_purchase_by_party_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/sale_purchase_order/sale_purchase_order_item_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/sale_purchase_order/sale_purchase_orders_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_deferred_module_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_panel_scope.dart';
import 'package:billing_baba/features/reports/presentation/widgets/taxes/gst_tax_rate_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/taxes/gst_tax_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/all_transactions_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/balance_sheet_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/bill_wise_profit_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/cash_flow_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/day_book_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/profit_loss_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/purchase_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/sale_report_content.dart';
import 'package:billing_baba/features/reports/presentation/widgets/transaction/trial_balance_report_content.dart';
import 'package:flutter/material.dart';

class ReportContentPanel extends StatelessWidget {
  const ReportContentPanel({
    required this.navGroup,
    this.transactionSub,
    this.partySub,
    this.gstSub,
    this.itemStockSub,
    this.businessStatusSub,
    this.taxesSub,
    this.expenseSub,
    this.salePurchaseOrderSub,
    this.otherIncomeSub,
    this.loanAccountsSub,
    super.key,
  });

  final ReportNavGroup navGroup;
  final TransactionReportSubSection? transactionSub;
  final PartyReportSubSection? partySub;
  final GstReportSubSection? gstSub;
  final ItemStockReportSubSection? itemStockSub;
  final BusinessStatusReportSubSection? businessStatusSub;
  final TaxesReportSubSection? taxesSub;
  final ExpenseReportSubSection? expenseSub;
  final SalePurchaseOrderReportSubSection? salePurchaseOrderSub;
  final OtherIncomeReportSubSection? otherIncomeSub;
  final LoanAccountsReportSubSection? loanAccountsSub;

  @override
  Widget build(BuildContext context) {
    if (navGroup == ReportNavGroup.transaction && transactionSub != null) {
      return _scoped(
        switch (transactionSub!) {
          TransactionReportSubSection.sale => const SaleReportContent(),
          TransactionReportSubSection.purchase => const PurchaseReportContent(),
          TransactionReportSubSection.dayBook => const DayBookReportContent(),
          TransactionReportSubSection.allTransaction =>
            const AllTransactionsReportContent(),
          TransactionReportSubSection.profitLoss =>
            const ProfitLossReportContent(),
          TransactionReportSubSection.billWiseProfit =>
            const BillWiseProfitReportContent(),
          TransactionReportSubSection.cashFlow => const CashFlowReportContent(),
          TransactionReportSubSection.trialBalance =>
            const TrialBalanceReportContent(),
          TransactionReportSubSection.balanceSheet =>
            const BalanceSheetReportContent(),
        },
      );
    }

    if (navGroup == ReportNavGroup.party && partySub != null) {
      return _scoped(
        switch (partySub!) {
          PartyReportSubSection.partyStatement =>
            const PartyStatementReportContent(),
          PartyReportSubSection.partyWiseProfitLoss =>
            const PartyWiseProfitLossReportContent(),
          PartyReportSubSection.allParties => const AllPartiesReportContent(),
          PartyReportSubSection.partyReportByItem =>
            const PartyReportByItemContent(),
          PartyReportSubSection.salePurchaseByParty =>
            const SalePurchaseByPartyReportContent(),
          PartyReportSubSection.salePurchaseByPartyGroup =>
            const SalePurchaseByPartyGroupReportContent(),
        },
      );
    }

    if (navGroup == ReportNavGroup.gst && gstSub != null) {
      return _scoped(
        switch (gstSub!) {
          GstReportSubSection.gstr1 => const Gstr1ReportContent(),
          GstReportSubSection.gstr2 => const Gstr2ReportContent(),
          GstReportSubSection.gstr3b => const Gstr3bReportContent(),
          GstReportSubSection.gstr9 => const Gstr9ReportContent(),
          GstReportSubSection.saleSummaryByHsn =>
            const SaleSummaryByHsnReportContent(),
          GstReportSubSection.sacReport => const SacReportContent(),
        },
      );
    }

    if (navGroup == ReportNavGroup.itemStock && itemStockSub != null) {
      return _scoped(
        switch (itemStockSub!) {
          ItemStockReportSubSection.stockSummary =>
            const StockSummaryReportContent(),
          ItemStockReportSubSection.itemReportByParty =>
            const ItemReportByPartyReportContent(),
          ItemStockReportSubSection.itemWiseProfitLoss =>
            const ItemWiseProfitLossReportContent(),
          ItemStockReportSubSection.lowStockSummary =>
            const LowStockSummaryReportContent(),
          ItemStockReportSubSection.stockDetail =>
            const StockDetailReportContent(),
          ItemStockReportSubSection.itemDetail =>
            const ItemDetailReportContent(),
          ItemStockReportSubSection.salePurchaseReportByItemCategory =>
            const SalePurchaseReportByItemCategoryReportContent(),
          ItemStockReportSubSection.stockSummaryReportByItemCategory =>
            const StockSummaryReportByItemCategoryReportContent(),
          ItemStockReportSubSection.itemCategoryWiseProfitLoss =>
            const ItemCategoryWiseProfitLossReportContent(),
          ItemStockReportSubSection.itemWiseDiscount =>
            const ItemWiseDiscountReportContent(),
          ItemStockReportSubSection.manufacturingReport =>
            const ManufacturingReportContent(),
          ItemStockReportSubSection.consumptionReport =>
            const ConsumptionReportContent(),
          ItemStockReportSubSection.stockTransferReport =>
            const StockTransferReportContent(),
        },
      );
    }

    if (navGroup == ReportNavGroup.businessStatus &&
        businessStatusSub != null) {
      return _scoped(const BankStatementReportContent());
    }

    if (navGroup == ReportNavGroup.taxes && taxesSub != null) {
      return _scoped(
        switch (taxesSub!) {
          TaxesReportSubSection.gstReport => const GstTaxReportContent(),
          TaxesReportSubSection.gstRateReport =>
            const GstTaxRateReportContent(),
          TaxesReportSubSection.formNo27Eq =>
            ReportDeferredModuleContent(reportName: taxesSub!.label),
          TaxesReportSubSection.tcsReceivable =>
            ReportDeferredModuleContent(reportName: taxesSub!.label),
          TaxesReportSubSection.tdsPayable =>
            ReportDeferredModuleContent(reportName: taxesSub!.label),
          TaxesReportSubSection.tdsReceivable =>
            ReportDeferredModuleContent(reportName: taxesSub!.label),
        },
      );
    }

    if (navGroup == ReportNavGroup.expenseReport && expenseSub != null) {
      return _scoped(
        switch (expenseSub!) {
          ExpenseReportSubSection.expense => const ExpenseReportContent(),
          ExpenseReportSubSection.expenseCategoryReport =>
            const ExpenseCategoryReportContent(),
          ExpenseReportSubSection.expenseItemReport =>
            const ExpenseItemReportContent(),
        },
      );
    }

    if (navGroup == ReportNavGroup.salePurchaseOrderReport &&
        salePurchaseOrderSub != null) {
      return _scoped(
        switch (salePurchaseOrderSub!) {
          SalePurchaseOrderReportSubSection.salePurchaseOrders =>
            const SalePurchaseOrdersReportContent(),
          SalePurchaseOrderReportSubSection.salePurchaseOrderItem =>
            const SalePurchaseOrderItemReportContent(),
        },
      );
    }

    if (navGroup == ReportNavGroup.otherIncomeReport &&
        otherIncomeSub != null) {
      return _scoped(
        switch (otherIncomeSub!) {
          OtherIncomeReportSubSection.otherIncome =>
            ReportDeferredModuleContent(reportName: otherIncomeSub!.label),
          OtherIncomeReportSubSection.otherIncomeCategoryReport =>
            ReportDeferredModuleContent(reportName: otherIncomeSub!.label),
          OtherIncomeReportSubSection.otherIncomeItemReport =>
            ReportDeferredModuleContent(reportName: otherIncomeSub!.label),
        },
      );
    }

    if (navGroup == ReportNavGroup.loanAccounts && loanAccountsSub != null) {
      return _scoped(const LoanStatementReportContent());
    }

    final title = switch (navGroup) {
      ReportNavGroup.transaction =>
        transactionSub?.label ?? 'Transaction Report',
      ReportNavGroup.party => partySub?.label ?? 'Party Report',
      ReportNavGroup.gst => gstSub?.label ?? 'GST Reports',
      ReportNavGroup.itemStock => itemStockSub?.label ?? 'Item/Stock Report',
      ReportNavGroup.businessStatus =>
        businessStatusSub?.label ?? 'Business Status',
      ReportNavGroup.taxes => taxesSub?.label ?? 'Taxes',
      ReportNavGroup.expenseReport =>
        expenseSub?.label ?? 'Expense Report',
      ReportNavGroup.salePurchaseOrderReport =>
        salePurchaseOrderSub?.label ?? 'Sale/Purchase Order Report',
      ReportNavGroup.otherIncomeReport =>
        otherIncomeSub?.label ?? 'Other Income Report',
      ReportNavGroup.loanAccounts =>
        loanAccountsSub?.label ?? 'Loan Accounts',
    };

    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoped(Widget child) => ReportPanelScope(child: child);
}
