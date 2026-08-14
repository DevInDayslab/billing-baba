import 'package:billing_baba/features/reports/application/reports_nav_catalog.dart';
import 'package:billing_baba/features/reports/models/report_nav_group.dart';

/// Display configuration for a mobile report subsection.
class MobileReportSubsectionConfig {
  const MobileReportSubsectionConfig({
    required this.title,
    required this.referencePrefix,
    this.summaryLabels = const [
      'No of Txns',
      'Total',
      'Balance Due',
    ],
    this.columnLabels = const [
      'Amount',
      'Balance',
      'Due Date',
    ],
  });

  final String title;
  final String referencePrefix;
  final List<String> summaryLabels;
  final List<String> columnLabels;
}

/// Resolves titles and labels for every desktop report subsection on mobile.
///
/// Labels mirror the desktop report table schemas so each subsection shows
/// distinct columns instead of a generic Amount / Balance / Due Date layout.
abstract final class MobileReportSubsectionRegistry {
  static MobileReportSubsectionConfig? config(
    ReportNavGroup group,
    String subsectionId,
  ) {
    final entry = ReportsNavCatalog.subsection(group, subsectionId);
    if (entry == null) return null;

    final title = switch (group) {
      ReportNavGroup.transaction => switch (subsectionId) {
        'sale' => 'Sale Report',
        'purchase' => 'Purchase Report',
        _ => entry.label,
      },
      _ => entry.label,
    };

    final prefix = switch (group) {
      ReportNavGroup.transaction => switch (subsectionId) {
        'purchase' => 'PURCHASE',
        'dayBook' => 'DAY',
        'billWiseProfit' => 'BILL',
        'cashFlow' => 'CASH',
        'trialBalance' => 'TB',
        'balanceSheet' => 'BS',
        'profitLoss' => 'P&L',
        _ => 'SALE',
      },
      ReportNavGroup.party => 'PARTY',
      ReportNavGroup.gst => 'GST',
      ReportNavGroup.itemStock => 'ITEM',
      ReportNavGroup.businessStatus => 'BANK',
      ReportNavGroup.taxes => 'TAX',
      ReportNavGroup.expenseReport => 'EXP',
      ReportNavGroup.salePurchaseOrderReport => 'ORDER',
      ReportNavGroup.otherIncomeReport => 'INCOME',
      ReportNavGroup.loanAccounts => 'LOAN',
    };

    final (summaryLabels, columnLabels) = _labelsFor(group, subsectionId);

    return MobileReportSubsectionConfig(
      title: title,
      referencePrefix: prefix,
      summaryLabels: summaryLabels,
      columnLabels: columnLabels,
    );
  }

  static (List<String>, List<String>) _labelsFor(
    ReportNavGroup group,
    String subsectionId,
  ) {
    return switch ((group, subsectionId)) {
      // ── Transaction ──────────────────────────────────────────────
      (ReportNavGroup.transaction, 'sale') => (
        const ['No of Txns', 'Total Sale', 'Balance Due'],
        const ['Amount', 'Balance', 'Due Date'],
      ),
      (ReportNavGroup.transaction, 'purchase') => (
        const ['No of Txns', 'Total Purchase', 'Balance Due'],
        const ['Amount', 'Balance', 'Date'],
      ),
      (ReportNavGroup.transaction, 'dayBook') => (
        const ['Txns', 'Money In', 'Money Out'],
        const ['Total', 'Money In', 'Money Out'],
      ),
      (ReportNavGroup.transaction, 'allTransaction') => (
        const ['No of Txns', 'Total', 'Balance'],
        const ['Total', 'Balance', 'Due Date'],
      ),
      (ReportNavGroup.transaction, 'profitLoss') => (
        const ['Line Items', 'Net Profit', 'Total'],
        const ['Amount', 'Type', 'Level'],
      ),
      (ReportNavGroup.transaction, 'billWiseProfit') => (
        const ['Bills', 'Total Profit', 'Total Sale'],
        const ['Sale Amount', 'Profit', 'Date'],
      ),
      (ReportNavGroup.transaction, 'cashFlow') => (
        const ['Txns', 'Cash In', 'Closing Balance'],
        const ['Cash In', 'Cash Out', 'Balance'],
      ),
      (ReportNavGroup.transaction, 'trialBalance') => (
        const ['Accounts', 'Total Debit', 'Total Credit'],
        const ['Debit', 'Credit', 'Closing'],
      ),
      (ReportNavGroup.transaction, 'balanceSheet') => (
        const ['Line Items', 'Assets', 'Liabilities'],
        const ['Amount', 'Type', 'Level'],
      ),

      // ── Party ────────────────────────────────────────────────────
      (ReportNavGroup.party, 'partyStatement') => (
        const ['Entries', 'Total Sale', 'Receivable'],
        const ['Total', 'Balance', 'Date'],
      ),
      (ReportNavGroup.party, 'partyWiseProfitLoss') => (
        const ['Parties', 'Total Sale', 'Total Profit'],
        const ['Sale', 'Purchase', 'Profit'],
      ),
      (ReportNavGroup.party, 'allParties') => (
        const ['Parties', 'Receivable', 'Payable'],
        const ['Receivable', 'Payable', 'Credit Limit'],
      ),
      (ReportNavGroup.party, 'partyReportByItem') => (
        const ['Parties', 'Total Amount', 'Qty'],
        const ['Qty', 'Amount', '—'],
      ),
      (ReportNavGroup.party, 'salePurchaseByParty') => (
        const ['Parties', 'Total', 'Net'],
        const ['Sale', 'Purchase', 'Net'],
      ),
      (ReportNavGroup.party, 'salePurchaseByPartyGroup') => (
        const ['Groups', 'Total', 'Net'],
        const ['Sale', 'Purchase', 'Net'],
      ),

      // ── GST ──────────────────────────────────────────────────────
      (ReportNavGroup.gst, 'gstr1') ||
      (ReportNavGroup.gst, 'gstr2') => (
        const ['Invoices', 'Taxable', 'Invoice Value'],
        const ['Taxable', 'IGST', 'Value'],
      ),
      (ReportNavGroup.gst, 'gstr3b') => (
        const ['Rows', 'Taxable', 'Cess'],
        const ['Taxable', 'IGST', 'Cess'],
      ),
      (ReportNavGroup.gst, 'gstr9') => (
        const ['Rows', 'Taxable', 'Tax'],
        const ['Taxable', 'IGST', 'CGST+SGST'],
      ),
      (ReportNavGroup.gst, 'saleSummaryByHsn') => (
        const ['HSNs', 'Taxable', 'Total'],
        const ['Taxable', 'IGST', 'Total'],
      ),
      (ReportNavGroup.gst, 'sacReport') => (
        const ['SACs', 'Taxable', 'Total'],
        const ['Taxable', 'IGST', 'Total'],
      ),

      // ── Item / Stock ─────────────────────────────────────────────
      (ReportNavGroup.itemStock, 'itemReportByParty') => (
        const ['Rows', 'Sale Amount', 'Qty'],
        const ['Qty', 'Amount', '—'],
      ),
      (ReportNavGroup.itemStock, 'itemWiseProfitLoss') => (
        const ['Items', 'Total Profit', 'Total Sale'],
        const ['Sale', 'Purchase', 'Profit'],
      ),
      (ReportNavGroup.itemStock, 'lowStockSummary') => (
        const ['Items', 'Low Stock', 'Shortage'],
        const ['Current', 'Min Stock', 'Shortage'],
      ),
      (ReportNavGroup.itemStock, 'stockDetail') => (
        const ['Items', 'Closing Qty', 'In Qty'],
        const ['Opening', 'Qty In', 'Closing'],
      ),
      (ReportNavGroup.itemStock, 'salePurchaseReportByItemCategory') => (
        const ['Categories', 'Total', 'Net'],
        const ['Sale', 'Purchase', 'Net'],
      ),
      (ReportNavGroup.itemStock, 'stockSummaryReportByItemCategory') => (
        const ['Categories', 'Stock Value', 'Sale Value'],
        const ['Sale', 'Purchase', 'Net'],
      ),
      (ReportNavGroup.itemStock, 'itemCategoryWiseProfitLoss') => (
        const ['Categories', 'Profit', 'Sale'],
        const ['Sale', 'Purchase', 'Profit'],
      ),
      (ReportNavGroup.itemStock, 'itemWiseDiscount') => (
        const ['Items', 'Total Discount', 'Qty Sold'],
        const ['Qty Sold', 'Disc Amt', 'Disc %'],
      ),
      (ReportNavGroup.itemStock, 'manufacturingReport') => (
        const ['Rows', 'Total Cost', 'Qty'],
        const ['Qty', 'Cost', 'Date'],
      ),
      (ReportNavGroup.itemStock, 'consumptionReport') => (
        const ['Rows', 'Total Value', 'Qty'],
        const ['Qty', 'Value', 'Date'],
      ),
      (ReportNavGroup.itemStock, 'stockTransferReport') => (
        const ['Transfers', 'Total Qty', '—'],
        const ['From', 'To', 'Qty'],
      ),
      (ReportNavGroup.itemStock, _) => (
        const ['No. of Items', 'Stock Value', '—'],
        const ['Stock Qty', 'Stock Value', 'Sale Price'],
      ),

      // ── Business Status ──────────────────────────────────────────
      (ReportNavGroup.businessStatus, 'bankStatement') => (
        const ['Txns', 'Deposit', 'Withdrawal'],
        const ['Deposit', 'Withdrawal', 'Balance'],
      ),

      // ── Taxes ────────────────────────────────────────────────────
      (ReportNavGroup.taxes, 'gstReport') => (
        const ['Parties', 'Total Tax', 'Net'],
        const ['Sale Tax', 'Purchase Tax', 'Net'],
      ),
      (ReportNavGroup.taxes, 'gstRateReport') => (
        const ['Rates', 'Tax In', 'Tax Out'],
        const ['Taxable Sale', 'Tax In', 'Tax Out'],
      ),
      (ReportNavGroup.taxes, _) => (
        const ['Invoices', 'Tax Collected', '—'],
        const ['Total Value', 'Tax Collected', 'Date'],
      ),

      // ── Expense ──────────────────────────────────────────────────
      (ReportNavGroup.expenseReport, 'expense') => (
        const ['Txns', 'Total', 'Balance Due'],
        const ['Amount', 'Status', 'Due Date'],
      ),
      (ReportNavGroup.expenseReport, 'expenseCategoryReport') => (
        const ['Categories', 'Total', 'Count'],
        const ['Amount', 'Count', '—'],
      ),
      (ReportNavGroup.expenseReport, 'expenseItemReport') => (
        const ['Items', 'Total', 'Count'],
        const ['Amount', 'Count', '—'],
      ),

      // ── Sale / Purchase Orders ───────────────────────────────────
      (ReportNavGroup.salePurchaseOrderReport, 'salePurchaseOrders') => (
        const ['Orders', 'Total', '—'],
        const ['Total', 'Status', 'Due Date'],
      ),
      (ReportNavGroup.salePurchaseOrderReport, 'salePurchaseOrderItem') => (
        const ['Lines', 'Total', 'Qty'],
        const ['Qty', 'Amount', 'Party'],
      ),

      // ── Other Income ─────────────────────────────────────────────
      (ReportNavGroup.otherIncomeReport, 'otherIncome') => (
        const ['Txns', 'Total', '—'],
        const ['Amount', 'Status', 'Due Date'],
      ),
      (ReportNavGroup.otherIncomeReport, 'otherIncomeCategoryReport') => (
        const ['Categories', 'Total', 'Count'],
        const ['Amount', 'Count', '—'],
      ),
      (ReportNavGroup.otherIncomeReport, 'otherIncomeItemReport') => (
        const ['Items', 'Total', 'Count'],
        const ['Amount', 'Count', '—'],
      ),

      // ── Loan Accounts ────────────────────────────────────────────
      (ReportNavGroup.loanAccounts, 'loanStatement') => (
        const ['Entries', 'Total Debit', 'Total Credit'],
        const ['Debit', 'Credit', 'Outstanding'],
      ),

      _ => (
        const ['No of Txns', 'Total', 'Balance Due'],
        const ['Amount', 'Balance', 'Due Date'],
      ),
    };
  }
}
