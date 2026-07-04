import 'package:billing_baba/features/inventory/providers/inventory_catalog.dart';
import 'package:billing_baba/features/parties/providers/parties_provider.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:billing_baba/features/parties/providers/party_catalog.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/providers/report_catalog.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Transaction reports ────────────────────────────────────────────────

final reportAllTransactionsProvider = Provider<List<ReportTransactionRow>>(
  (ref) => ReportCatalog.allTransactions(),
);

final reportDayBookProvider =
    Provider.family<List<ReportTransactionRow>, DateTime>((ref, date) {
  return ReportCatalog.dayBookForDate(date);
});

final reportPurchasesProvider = Provider<List<ReportPurchaseRow>>(
  (ref) => ReportCatalog.purchases(),
);

final reportPurchaseSummaryProvider = Provider<({double total, double paid, double balance})>(
  (ref) => (
    total: ReportCatalog.purchaseTotalAmount(),
    paid: ReportCatalog.purchasePaidAmount(),
    balance: ReportCatalog.purchaseBalanceAmount(),
  ),
);

final reportProfitLossProvider = Provider<List<ReportProfitLossItem>>(
  (ref) => ReportCatalog.profitLossItems(),
);

final reportBillWiseProfitProvider = Provider<List<ReportBillWiseProfitRow>>(
  (ref) => ReportCatalog.billWiseProfit(),
);

final reportTrialBalanceProvider = Provider<List<ReportTrialBalanceRow>>(
  (ref) => ReportCatalog.trialBalance(),
);

final reportBalanceSheetAssetsProvider = Provider<List<ReportBalanceSheetItem>>(
  (ref) => ReportCatalog.balanceSheetAssets(),
);

final reportBalanceSheetLiabilitiesProvider =
    Provider<List<ReportBalanceSheetItem>>(
  (ref) => ReportCatalog.balanceSheetLiabilities(),
);

// Sale report reuses sale invoices provider
final reportSaleInvoicesProvider = Provider<List<SaleInvoiceModel>>(
  (ref) => ref.watch(saleInvoicesProvider),
);

final reportSaleSummaryProvider = Provider<SaleInvoiceSummaryData>(
  (ref) => ref.watch(saleInvoiceSummaryProvider),
);

// ── Party reports ────────────────────────────────────────────────────────

final reportAllPartiesProvider = Provider((ref) => ref.watch(partiesProvider));

final reportPartyBalanceSummaryProvider = Provider(
  (ref) => ref.watch(partyBalanceSummaryProvider),
);

final reportPartyStatementProvider =
    Provider.family<List<ReportPartyStatementEntry>, String?>((ref, partyId) {
  if (partyId == null) return [];
  return ReportCatalog.partyStatement(partyId);
});

final reportPartyStatementSummaryProvider =
    Provider.family<ReportPartyStatementSummary, String?>((ref, partyId) {
  if (partyId == null) {
    return const ReportPartyStatementSummary(
      totalSale: 0,
      totalPurchase: 0,
      totalMoneyIn: 0,
      totalMoneyOut: 0,
      totalReceivable: 0,
    );
  }
  return ReportCatalog.partyStatementSummary(partyId);
});

final reportPartyWiseProfitLossProvider =
    Provider<List<ReportPartyWiseProfitLossRow>>(
  (ref) => ReportCatalog.partyWiseProfitLoss(),
);

final reportSalePurchaseByPartyProvider =
    Provider<List<ReportSalePurchaseByPartyRow>>(
  (ref) => ReportCatalog.salePurchaseByParty(),
);

final reportSalePurchaseByPartyGroupProvider =
    Provider<List<ReportSalePurchaseByPartyGroupRow>>(
  (ref) => ReportCatalog.salePurchaseByPartyGroup(),
);

final reportPartyByItemProvider =
    Provider.family<List<ReportPartyByItemRow>, String>((ref, itemName) {
  return ReportCatalog.partyByItem(itemName);
});

// ── GST reports ────────────────────────────────────────────────────────

final reportGstr1SaleProvider = Provider<List<ReportGstrRow>>(
  (ref) => ReportCatalog.gstr1SaleRows(),
);

final reportGstr2PurchaseProvider = Provider<List<ReportGstrRow>>(
  (ref) => ReportCatalog.gstr2PurchaseRows(),
);

final reportSacRowsProvider = Provider<List<ReportSacRow>>(
  (ref) => ReportCatalog.sacRows(),
);

final reportHsnRowsProvider = Provider<List<ReportHsnRow>>(
  (ref) => ReportCatalog.hsnRows(),
);

final reportGstr3bProvider = Provider<List<ReportGstr3bRow>>(
  (ref) => ReportCatalog.gstr3bRows(),
);

final reportGstr9SupplyProvider = Provider<List<ReportGstr9SupplyRow>>(
  (ref) => ReportCatalog.gstr9SupplyRows(),
);

// ── Item / Stock reports ───────────────────────────────────────────────

final reportStockSummaryProvider = Provider<List<ReportStockSummaryRow>>(
  (ref) => ReportCatalog.stockSummary(),
);

final reportItemByPartyProvider = Provider<List<ReportItemByPartyRow>>(
  (ref) => ReportCatalog.itemReportByParty(),
);

final reportItemWiseProfitLossProvider =
    Provider<List<ReportItemWiseProfitLossRow>>(
  (ref) => ReportCatalog.itemWiseProfitLoss(),
);

final reportLowStockProvider = Provider<List<ReportLowStockRow>>(
  (ref) => ReportCatalog.lowStock(),
);

final reportStockDetailProvider = Provider<List<ReportStockDetailRow>>(
  (ref) => ReportCatalog.stockDetail(),
);

final reportItemDetailProvider =
    Provider.family<List<ReportItemDetailRow>, String>((ref, itemName) {
  return ReportCatalog.itemDetail(itemName);
});

final reportSalePurchaseByCategoryProvider =
    Provider<List<ReportCategoryAmountRow>>(
  (ref) => ReportCatalog.salePurchaseByCategory(),
);

final reportStockSummaryByCategoryProvider =
    Provider<List<ReportCategoryAmountRow>>(
  (ref) => ReportCatalog.stockSummaryByCategory(),
);

final reportCategoryWiseProfitLossProvider =
    Provider<List<ReportItemWiseProfitLossRow>>(
  (ref) => ReportCatalog.categoryWiseProfitLoss(),
);

final reportItemWiseDiscountProvider = Provider<List<ReportItemDiscountRow>>(
  (ref) => ReportCatalog.itemWiseDiscount(),
);

final reportManufacturingProvider = Provider<List<ReportManufacturingRow>>(
  (ref) => ReportCatalog.manufacturing(),
);

final reportConsumptionProvider = Provider<List<ReportConsumptionRow>>(
  (ref) => ReportCatalog.consumption(),
);

final reportStockTransferProvider = Provider<List<ReportStockTransferRow>>(
  (ref) => ReportCatalog.stockTransfers(),
);

// ── Expense reports ────────────────────────────────────────────────────

final reportExpensesProvider = Provider<List<ReportExpenseRow>>(
  (ref) => ReportCatalog.expenses(),
);

final reportExpenseByCategoryProvider =
    Provider<List<ReportExpenseCategoryRow>>(
  (ref) => ReportCatalog.expenseByCategory(),
);

final reportExpenseByItemProvider = Provider<List<ReportExpenseItemRow>>(
  (ref) => ReportCatalog.expenseByItem(),
);

// ── Business status ──────────────────────────────────────────────────────

final reportBankStatementProvider =
    Provider.family<List<ReportBankStatementRow>, String>((ref, bank) {
  return ReportCatalog.bankStatement(bank);
});

// ── Orders ───────────────────────────────────────────────────────────────

final reportOrdersProvider = Provider<List<ReportOrderRow>>(
  (ref) => ReportCatalog.orders(),
);

final reportOrderItemsProvider = Provider<List<ReportOrderItemRow>>(
  (ref) => ReportCatalog.orderItems(),
);

final reportGstTaxByPartyProvider = Provider<List<ReportGstTaxPartyRow>>(
  (ref) => ReportCatalog.gstTaxByParty(),
);

final reportGstTaxRateRowsProvider = Provider<List<ReportGstTaxRateRow>>(
  (ref) => ReportCatalog.gstTaxRateRows(),
);

final reportOtherIncomesProvider = Provider<List<ReportOtherIncomeRow>>(
  (ref) => ReportCatalog.otherIncomes(),
);

final reportOtherIncomeByCategoryProvider =
    Provider<List<ReportOtherIncomeCategoryRow>>(
  (ref) => ReportCatalog.otherIncomeByCategory(),
);

final reportOtherIncomeByItemProvider =
    Provider<List<ReportOtherIncomeItemRow>>(
  (ref) => ReportCatalog.otherIncomeByItem(),
);

final reportLoanStatementProvider =
    Provider.family<List<ReportLoanStatementRow>, String>(
  (ref, loanAccount) => ReportCatalog.loanStatement(loanAccount),
);

// Party selection for party statement report
final reportSelectedPartyIdProvider =
    NotifierProvider<ReportSelectedPartyId, String?>(
  ReportSelectedPartyId.new,
);

class ReportSelectedPartyId extends Notifier<String?> {
  @override
  String? build() => PartyCatalog.parties.first.id;

  void select(String? id) => state = id;
}

// Item name for item detail report
final reportSelectedItemNameProvider =
    NotifierProvider<ReportSelectedItemName, String>(
  ReportSelectedItemName.new,
);

class ReportSelectedItemName extends Notifier<String> {
  @override
  String build() => InventoryCatalog.items.first.name;

  void select(String name) => state = name;
}
