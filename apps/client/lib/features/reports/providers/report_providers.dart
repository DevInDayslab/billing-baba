import 'package:billing_baba/features/reports/application/reports_service.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:billing_baba/features/reports/providers/report_refresh_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_providers.g.dart';

ReportQuery _currentQuery(Ref ref) {
  ref.watch(reportDataEpochProvider);
  return ref.watch(reportFiltersProvider).toQuery();
}

@riverpod
class BillWiseProfitReport extends _$BillWiseProfitReport {
  @override
  Future<BillWiseProfitReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<BillWiseProfitReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchBillWiseProfit(_currentQuery(ref));
  }
}

@riverpod
class CashFlowReport extends _$CashFlowReport {
  @override
  Future<CashFlowReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<CashFlowReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchCashFlow(_currentQuery(ref));
  }
}

@riverpod
class PartyWiseProfitLossReport extends _$PartyWiseProfitLossReport {
  @override
  Future<PartyWiseProfitLossReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<PartyWiseProfitLossReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchPartyWiseProfitLoss(_currentQuery(ref));
  }
}

@riverpod
class PartyReportByItemReport extends _$PartyReportByItemReport {
  @override
  Future<PartyReportByItemReportData?> build() async {
    final filters = ref.watch(reportFiltersProvider);
    final value = filters.itemId;
    if (value == null || value.isEmpty) return null;
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<PartyReportByItemReportData?> _load() async {
    final filters = ref.read(reportFiltersProvider);
    final value = filters.itemId;
    if (value == null || value.isEmpty) return null;
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchPartyReportByItem(filters.toQuery());
  }
}

@riverpod
class SalePurchaseByPartyReport extends _$SalePurchaseByPartyReport {
  @override
  Future<SalePurchaseByPartyReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<SalePurchaseByPartyReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchSalePurchaseByParty(_currentQuery(ref));
  }
}

@riverpod
class SalePurchaseByPartyGroupReport extends _$SalePurchaseByPartyGroupReport {
  @override
  Future<SalePurchaseByPartyGroupReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<SalePurchaseByPartyGroupReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchSalePurchaseByPartyGroup(_currentQuery(ref));
  }
}

@riverpod
class Gstr9Report extends _$Gstr9Report {
  @override
  Future<Gstr9ReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<Gstr9ReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchGstr9(_currentQuery(ref));
  }
}

@riverpod
class SaleSummaryByHsnReport extends _$SaleSummaryByHsnReport {
  @override
  Future<SaleSummaryByHsnReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<SaleSummaryByHsnReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchSaleSummaryByHsn(_currentQuery(ref));
  }
}

@riverpod
class SacReportReport extends _$SacReportReport {
  @override
  Future<SacReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<SacReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchSacReport(_currentQuery(ref));
  }
}

@riverpod
class ItemReportByPartyReport extends _$ItemReportByPartyReport {
  @override
  Future<ItemReportByPartyReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<ItemReportByPartyReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchItemReportByParty(_currentQuery(ref));
  }
}

@riverpod
class ItemWiseProfitLossReport extends _$ItemWiseProfitLossReport {
  @override
  Future<ItemWiseProfitLossReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<ItemWiseProfitLossReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchItemWiseProfitLoss(_currentQuery(ref));
  }
}

@riverpod
class StockDetailReport extends _$StockDetailReport {
  @override
  Future<StockDetailReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<StockDetailReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchStockDetail(_currentQuery(ref));
  }
}

@riverpod
class ItemDetailReport extends _$ItemDetailReport {
  @override
  Future<ItemDetailReportData?> build() async {
    final filters = ref.watch(reportFiltersProvider);
    final value = filters.itemId;
    if (value == null || value.isEmpty) return null;
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<ItemDetailReportData?> _load() async {
    final filters = ref.read(reportFiltersProvider);
    final value = filters.itemId;
    if (value == null || value.isEmpty) return null;
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchItemDetail(filters.toQuery());
  }
}

@riverpod
class SalePurchaseByItemCategoryReport
    extends _$SalePurchaseByItemCategoryReport {
  @override
  Future<CategoryAmountReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<CategoryAmountReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchSalePurchaseByItemCategory(_currentQuery(ref));
  }
}

@riverpod
class StockSummaryByItemCategoryReport
    extends _$StockSummaryByItemCategoryReport {
  @override
  Future<CategoryAmountReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<CategoryAmountReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchStockSummaryByItemCategory(_currentQuery(ref));
  }
}

@riverpod
class ItemCategoryWiseProfitLossReport
    extends _$ItemCategoryWiseProfitLossReport {
  @override
  Future<CategoryAmountReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<CategoryAmountReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchItemCategoryWiseProfitLoss(_currentQuery(ref));
  }
}

@riverpod
class ItemWiseDiscountReport extends _$ItemWiseDiscountReport {
  @override
  Future<ItemWiseDiscountReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<ItemWiseDiscountReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchItemWiseDiscount(_currentQuery(ref));
  }
}

@riverpod
class ManufacturingReport extends _$ManufacturingReport {
  @override
  Future<ManufacturingReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<ManufacturingReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchManufacturing(_currentQuery(ref));
  }
}

@riverpod
class ConsumptionReport extends _$ConsumptionReport {
  @override
  Future<ConsumptionReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<ConsumptionReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchConsumption(_currentQuery(ref));
  }
}

@riverpod
class StockTransferReport extends _$StockTransferReport {
  @override
  Future<StockTransferReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<StockTransferReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchStockTransfer(_currentQuery(ref));
  }
}

@riverpod
class BankStatementReport extends _$BankStatementReport {
  @override
  Future<BankStatementReportData?> build() async {
    final filters = ref.watch(reportFiltersProvider);
    final value = filters.bankName;
    if (value == null || value.isEmpty) return null;
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<BankStatementReportData?> _load() async {
    final filters = ref.read(reportFiltersProvider);
    final value = filters.bankName;
    if (value == null || value.isEmpty) return null;
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchBankStatement(filters.toQuery());
  }
}

@riverpod
class GstTaxReport extends _$GstTaxReport {
  @override
  Future<GstTaxReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<GstTaxReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchGstReport(_currentQuery(ref));
  }
}

@riverpod
class GstTaxRateReport extends _$GstTaxRateReport {
  @override
  Future<GstTaxRateReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<GstTaxRateReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchGstRateReport(_currentQuery(ref));
  }
}

@riverpod
class Form27eqReport extends _$Form27eqReport {
  @override
  Future<TaxInvoiceReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<TaxInvoiceReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchForm27eq(_currentQuery(ref));
  }
}

@riverpod
class TcsReceivableReport extends _$TcsReceivableReport {
  @override
  Future<TaxInvoiceReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<TaxInvoiceReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchTcsReceivable(_currentQuery(ref));
  }
}

@riverpod
class TdsPayableReport extends _$TdsPayableReport {
  @override
  Future<TaxInvoiceReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<TaxInvoiceReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchTdsPayable(_currentQuery(ref));
  }
}

@riverpod
class TdsReceivableReport extends _$TdsReceivableReport {
  @override
  Future<TaxInvoiceReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<TaxInvoiceReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchTdsReceivable(_currentQuery(ref));
  }
}

@riverpod
class ExpensesReport extends _$ExpensesReport {
  @override
  Future<ExpensesReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<ExpensesReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchExpenses(_currentQuery(ref));
  }
}

@riverpod
class ExpenseByCategoryReport extends _$ExpenseByCategoryReport {
  @override
  Future<ExpenseByCategoryReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<ExpenseByCategoryReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchExpenseByCategory(_currentQuery(ref));
  }
}

@riverpod
class ExpenseByItemReport extends _$ExpenseByItemReport {
  @override
  Future<ExpenseByItemReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<ExpenseByItemReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchExpenseByItem(_currentQuery(ref));
  }
}

@riverpod
class SalePurchaseOrdersReport extends _$SalePurchaseOrdersReport {
  @override
  Future<SalePurchaseOrdersReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<SalePurchaseOrdersReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchSalePurchaseOrders(_currentQuery(ref));
  }
}

@riverpod
class SalePurchaseOrderItemsReport extends _$SalePurchaseOrderItemsReport {
  @override
  Future<SalePurchaseOrderItemsReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<SalePurchaseOrderItemsReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchSalePurchaseOrderItems(_currentQuery(ref));
  }
}

@riverpod
class OtherIncomeReport extends _$OtherIncomeReport {
  @override
  Future<OtherIncomeReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> goToPage(int page) async {
    ref.read(reportFiltersProvider.notifier).setPage(page);
    ref.invalidateSelf();
    await future;
  }

  Future<OtherIncomeReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchOtherIncome(_currentQuery(ref));
  }
}

@riverpod
class OtherIncomeByCategoryReport extends _$OtherIncomeByCategoryReport {
  @override
  Future<OtherIncomeByCategoryReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<OtherIncomeByCategoryReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchOtherIncomeByCategory(_currentQuery(ref));
  }
}

@riverpod
class OtherIncomeByItemReport extends _$OtherIncomeByItemReport {
  @override
  Future<OtherIncomeByItemReportData> build() async {
    ref.watch(reportFiltersProvider);
    ref.watch(reportDataEpochProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<OtherIncomeByItemReportData> _load() async {
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchOtherIncomeByItem(_currentQuery(ref));
  }
}

@riverpod
class LoanStatementReport extends _$LoanStatementReport {
  @override
  Future<LoanStatementReportData?> build() async {
    final filters = ref.watch(reportFiltersProvider);
    final value = filters.loanAccount;
    if (value == null || value.isEmpty) return null;
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<LoanStatementReportData?> _load() async {
    final filters = ref.read(reportFiltersProvider);
    final value = filters.loanAccount;
    if (value == null || value.isEmpty) return null;
    final service = await ref.read(reportsServiceProvider.future);
    return service.fetchLoanStatement(filters.toQuery());
  }
}
