import 'package:billing_baba/features/reports/data/reports_remote_data_source.dart';
import 'package:billing_baba/features/reports/models/dto/report_dto.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';

class ReportsRepository {
  ReportsRepository({required this._remote});

  final ReportsRemoteDataSource _remote;

  Future<PaginatedReportResponse<SaleReportPayloadDto>> getSaleReport(
    ReportQuery query,
  ) => _remote.getSaleReport(query);

  Future<PaginatedReportResponse<PurchaseReportPayloadDto>> getPurchaseReport(
    ReportQuery query,
  ) => _remote.getPurchaseReport(query);

  Future<PaginatedReportResponse<StockSummaryPayloadDto>> getStockSummary(
    ReportQuery query,
  ) => _remote.getStockSummary(query);

  Future<PaginatedReportResponse<LowStockPayloadDto>> getLowStock(
    ReportQuery query,
  ) => _remote.getLowStock(query);

  Future<PaginatedReportResponse<PartyOutstandingPayloadDto>>
  getPartyOutstanding(ReportQuery query) => _remote.getPartyOutstanding(query);

  Future<PartyStatementPayloadDto> getPartyStatement(ReportQuery query) =>
      _remote.getPartyStatement(query);

  Future<DayBookPayloadDto> getDayBook(ReportQuery query) =>
      _remote.getDayBook(query);

  Future<PaginatedReportResponse<AllTransactionsPayloadDto>> getAllTransactions(
    ReportQuery query,
  ) => _remote.getAllTransactions(query);

  Future<ProfitLossPayloadDto> getProfitLoss(ReportQuery query) =>
      _remote.getProfitLoss(query);

  Future<TrialBalancePayloadDto> getTrialBalance(ReportQuery query) =>
      _remote.getTrialBalance(query);

  Future<BalanceSheetPayloadDto> getBalanceSheet(ReportQuery query) =>
      _remote.getBalanceSheet(query);

  Future<GstrReportPayloadDto> getGstr1(ReportQuery query) =>
      _remote.getGstr1(query);

  Future<GstrReportPayloadDto> getGstr2(ReportQuery query) =>
      _remote.getGstr2(query);

  Future<Gstr3bPayloadDto> getGstr3b(ReportQuery query) =>
      _remote.getGstr3b(query);

  Future<PaginatedReportResponse<BillWiseProfitPayloadDto>> getBillWiseProfit(
    ReportQuery query,
  ) => _remote.getBillWiseProfit(query);

  Future<CashFlowPayloadDto> getCashFlow(ReportQuery query) =>
      _remote.getCashFlow(query);

  Future<PaginatedReportResponse<PartyWiseProfitLossPayloadDto>>
  getPartyWiseProfitLoss(ReportQuery query) =>
      _remote.getPartyWiseProfitLoss(query);

  Future<PaginatedReportResponse<PartyReportByItemPayloadDto>>
  getPartyReportByItem(ReportQuery query) =>
      _remote.getPartyReportByItem(query);

  Future<PaginatedReportResponse<SalePurchaseByPartyPayloadDto>>
  getSalePurchaseByParty(ReportQuery query) =>
      _remote.getSalePurchaseByParty(query);

  Future<PaginatedReportResponse<SalePurchaseByPartyGroupPayloadDto>>
  getSalePurchaseByPartyGroup(ReportQuery query) =>
      _remote.getSalePurchaseByPartyGroup(query);

  Future<Gstr9PayloadDto> getGstr9(ReportQuery query) =>
      _remote.getGstr9(query);

  Future<SaleSummaryByHsnPayloadDto> getSaleSummaryByHsn(ReportQuery query) =>
      _remote.getSaleSummaryByHsn(query);

  Future<SacReportPayloadDto> getSacReport(ReportQuery query) =>
      _remote.getSacReport(query);

  Future<PaginatedReportResponse<ItemReportByPartyPayloadDto>>
  getItemReportByParty(ReportQuery query) =>
      _remote.getItemReportByParty(query);

  Future<PaginatedReportResponse<ItemWiseProfitLossPayloadDto>>
  getItemWiseProfitLoss(ReportQuery query) =>
      _remote.getItemWiseProfitLoss(query);

  Future<PaginatedReportResponse<StockDetailPayloadDto>> getStockDetail(
    ReportQuery query,
  ) => _remote.getStockDetail(query);

  Future<PaginatedReportResponse<ItemDetailPayloadDto>> getItemDetail(
    ReportQuery query,
  ) => _remote.getItemDetail(query);

  Future<CategoryRowsPayloadDto> getSalePurchaseByItemCategory(
    ReportQuery query,
  ) => _remote.getSalePurchaseByItemCategory(query);

  Future<CategoryRowsPayloadDto> getStockSummaryByItemCategory(
    ReportQuery query,
  ) => _remote.getStockSummaryByItemCategory(query);

  Future<CategoryRowsPayloadDto> getItemCategoryWiseProfitLoss(
    ReportQuery query,
  ) => _remote.getItemCategoryWiseProfitLoss(query);

  Future<PaginatedReportResponse<ItemWiseDiscountPayloadDto>>
  getItemWiseDiscount(ReportQuery query) => _remote.getItemWiseDiscount(query);

  Future<PaginatedReportResponse<ManufacturingPayloadDto>> getManufacturing(
    ReportQuery query,
  ) => _remote.getManufacturing(query);

  Future<PaginatedReportResponse<ConsumptionPayloadDto>> getConsumption(
    ReportQuery query,
  ) => _remote.getConsumption(query);

  Future<PaginatedReportResponse<StockTransferPayloadDto>> getStockTransfer(
    ReportQuery query,
  ) => _remote.getStockTransfer(query);

  Future<BankStatementPayloadDto> getBankStatement(ReportQuery query) =>
      _remote.getBankStatement(query);

  Future<PaginatedReportResponse<GstTaxReportPayloadDto>> getGstReport(
    ReportQuery query,
  ) => _remote.getGstReport(query);

  Future<GstTaxRateReportPayloadDto> getGstRateReport(ReportQuery query) =>
      _remote.getGstRateReport(query);

  Future<PaginatedReportResponse<TaxInvoiceReportPayloadDto>> getForm27eq(
    ReportQuery query,
  ) => _remote.getForm27eq(query);

  Future<PaginatedReportResponse<TaxInvoiceReportPayloadDto>> getTcsReceivable(
    ReportQuery query,
  ) => _remote.getTcsReceivable(query);

  Future<PaginatedReportResponse<TaxInvoiceReportPayloadDto>> getTdsPayable(
    ReportQuery query,
  ) => _remote.getTdsPayable(query);

  Future<PaginatedReportResponse<TaxInvoiceReportPayloadDto>> getTdsReceivable(
    ReportQuery query,
  ) => _remote.getTdsReceivable(query);

  Future<PaginatedReportResponse<ExpensesPayloadDto>> getExpenses(
    ReportQuery query,
  ) => _remote.getExpenses(query);

  Future<ExpenseByCategoryPayloadDto> getExpenseByCategory(ReportQuery query) =>
      _remote.getExpenseByCategory(query);

  Future<ExpenseByItemPayloadDto> getExpenseByItem(ReportQuery query) =>
      _remote.getExpenseByItem(query);

  Future<PaginatedReportResponse<SalePurchaseOrdersPayloadDto>>
  getSalePurchaseOrders(ReportQuery query) =>
      _remote.getSalePurchaseOrders(query);

  Future<PaginatedReportResponse<SalePurchaseOrderItemsPayloadDto>>
  getSalePurchaseOrderItems(ReportQuery query) =>
      _remote.getSalePurchaseOrderItems(query);

  Future<PaginatedReportResponse<OtherIncomePayloadDto>> getOtherIncome(
    ReportQuery query,
  ) => _remote.getOtherIncome(query);

  Future<OtherIncomeByCategoryPayloadDto> getOtherIncomeByCategory(
    ReportQuery query,
  ) => _remote.getOtherIncomeByCategory(query);

  Future<OtherIncomeByItemPayloadDto> getOtherIncomeByItem(ReportQuery query) =>
      _remote.getOtherIncomeByItem(query);

  Future<LoanStatementPayloadDto> getLoanStatement(ReportQuery query) =>
      _remote.getLoanStatement(query);
}
