import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/reports/models/dto/gst_report_v2_dto.dart';
import 'package:billing_baba/features/reports/models/dto/report_dto.dart';
import 'package:billing_baba/features/reports/models/gst_report_type.dart';
import 'package:billing_baba/features/reports/models/tax_report_kind.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:dio/dio.dart';

class ReportsRemoteDataSource {
  ReportsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedReportResponse<SaleReportPayloadDto>> getSaleReport(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsSales,
    query,
    SaleReportPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<PurchaseReportPayloadDto>> getPurchaseReport(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsPurchases,
    query,
    PurchaseReportPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<StockSummaryPayloadDto>> getStockSummary(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsStockSummary,
    query,
    StockSummaryPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<LowStockPayloadDto>> getLowStock(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsLowStock,
    query,
    LowStockPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<PartyOutstandingPayloadDto>>
  getPartyOutstanding(ReportQuery query) => _getPaginated(
    ApiEndpoints.reportsPartyOutstanding,
    query,
    PartyOutstandingPayloadDto.fromJson,
  );

  Future<PartyStatementPayloadDto> getPartyStatement(ReportQuery query) =>
      _getData(
        ApiEndpoints.reportsPartyStatement,
        query,
        PartyStatementPayloadDto.fromJson,
      );

  Future<DayBookPayloadDto> getDayBook(ReportQuery query) =>
      _getData(ApiEndpoints.reportsDayBook, query, DayBookPayloadDto.fromJson);

  Future<PaginatedReportResponse<AllTransactionsPayloadDto>> getAllTransactions(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsAllTransactions,
    query,
    AllTransactionsPayloadDto.fromJson,
  );

  Future<ProfitLossPayloadDto> getProfitLoss(ReportQuery query) => _getData(
    ApiEndpoints.reportsProfitLoss,
    query,
    ProfitLossPayloadDto.fromJson,
  );

  Future<TrialBalancePayloadDto> getTrialBalance(ReportQuery query) => _getData(
    ApiEndpoints.reportsTrialBalance,
    query,
    TrialBalancePayloadDto.fromJson,
  );

  Future<BalanceSheetPayloadDto> getBalanceSheet(ReportQuery query) => _getData(
    ApiEndpoints.reportsBalanceSheet,
    query,
    BalanceSheetPayloadDto.fromJson,
  );

  Future<GstReportEnvelopeDto> getGstFilingReport(
    GstReportType type,
    ReportQuery query,
  ) {
    final endpoint = switch (type) {
      GstReportType.gstr1 => ApiEndpoints.reportsGstGstr1,
      GstReportType.gstr2 => ApiEndpoints.reportsGstGstr2,
      GstReportType.gstr3b => ApiEndpoints.reportsGstGstr3b,
      GstReportType.gstr9 => ApiEndpoints.reportsGstGstr9,
      GstReportType.hsnSummary => ApiEndpoints.reportsGstHsnSummary,
      GstReportType.sacReport => ApiEndpoints.reportsGstSacReport,
    };
    return _getData(endpoint, query, GstReportEnvelopeDto.fromJson);
  }

  Future<Map<String, dynamic>> getGstReportGstnJson(
    GstReportType type,
    ReportQuery query,
  ) async {
    final endpoint = switch (type) {
      GstReportType.gstr1 => ApiEndpoints.reportsGstGstr1,
      GstReportType.gstr3b => ApiEndpoints.reportsGstGstr3b,
      _ => throw UnsupportedError('GSTN JSON not supported for $type'),
    };
    final response = await _dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: {
        ...query.toQueryParameters(),
        'format': 'gstn_json',
      },
    );
    return Map<String, dynamic>.from(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<PaginatedReportResponse<BillWiseProfitPayloadDto>> getBillWiseProfit(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsBillWiseProfit,
    query,
    BillWiseProfitPayloadDto.fromJson,
  );

  Future<CashFlowPayloadDto> getCashFlow(ReportQuery query) => _getData(
    ApiEndpoints.reportsCashFlow,
    query,
    CashFlowPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<PartyWiseProfitLossPayloadDto>>
  getPartyWiseProfitLoss(ReportQuery query) => _getPaginated(
    ApiEndpoints.reportsPartyWiseProfitLoss,
    query,
    PartyWiseProfitLossPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<PartyReportByItemPayloadDto>>
  getPartyReportByItem(ReportQuery query) => _getPaginated(
    ApiEndpoints.reportsPartyReportByItem,
    query,
    PartyReportByItemPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<SalePurchaseByPartyPayloadDto>>
  getSalePurchaseByParty(ReportQuery query) => _getPaginated(
    ApiEndpoints.reportsSalePurchaseByParty,
    query,
    SalePurchaseByPartyPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<SalePurchaseByPartyGroupPayloadDto>>
  getSalePurchaseByPartyGroup(ReportQuery query) => _getPaginated(
    ApiEndpoints.reportsSalePurchaseByPartyGroup,
    query,
    SalePurchaseByPartyGroupPayloadDto.fromJson,
  );


  Future<PaginatedReportResponse<ItemReportByPartyPayloadDto>>
  getItemReportByParty(ReportQuery query) => _getPaginated(
    ApiEndpoints.reportsItemReportByParty,
    query,
    ItemReportByPartyPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<ItemWiseProfitLossPayloadDto>>
  getItemWiseProfitLoss(ReportQuery query) => _getPaginated(
    ApiEndpoints.reportsItemWiseProfitLoss,
    query,
    ItemWiseProfitLossPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<StockDetailPayloadDto>> getStockDetail(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsStockDetail,
    query,
    StockDetailPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<ItemDetailPayloadDto>> getItemDetail(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsItemDetail,
    query,
    ItemDetailPayloadDto.fromJson,
  );

  Future<CategoryRowsPayloadDto> getSalePurchaseByItemCategory(
    ReportQuery query,
  ) => _getData(
    ApiEndpoints.reportsSalePurchaseByItemCategory,
    query,
    CategoryRowsPayloadDto.fromJson,
  );

  Future<CategoryRowsPayloadDto> getStockSummaryByItemCategory(
    ReportQuery query,
  ) => _getData(
    ApiEndpoints.reportsStockSummaryByItemCategory,
    query,
    CategoryRowsPayloadDto.fromJson,
  );

  Future<CategoryRowsPayloadDto> getItemCategoryWiseProfitLoss(
    ReportQuery query,
  ) => _getData(
    ApiEndpoints.reportsItemCategoryWiseProfitLoss,
    query,
    CategoryRowsPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<ItemWiseDiscountPayloadDto>>
  getItemWiseDiscount(ReportQuery query) => _getPaginated(
    ApiEndpoints.reportsItemWiseDiscount,
    query,
    ItemWiseDiscountPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<ManufacturingPayloadDto>> getManufacturing(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsManufacturing,
    query,
    ManufacturingPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<ConsumptionPayloadDto>> getConsumption(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsConsumption,
    query,
    ConsumptionPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<StockTransferPayloadDto>> getStockTransfer(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsStockTransfer,
    query,
    StockTransferPayloadDto.fromJson,
  );

  Future<BankStatementPayloadDto> getBankStatement(ReportQuery query) =>
      _getData(
        ApiEndpoints.reportsBusinessBankStatement,
        query,
        BankStatementPayloadDto.fromJson,
      );

  Future<PaginatedReportResponse<GstTaxReportPayloadDto>> getGstReport(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsGstReport,
    query,
    GstTaxReportPayloadDto.fromJson,
  );

  Future<GstTaxRateReportPayloadDto> getGstRateReport(ReportQuery query) =>
      _getData(
        ApiEndpoints.reportsGstRateReport,
        query,
        GstTaxRateReportPayloadDto.fromJson,
      );

  Future<PaginatedReportResponse<GstReportEnvelopeDto>> getTaxGstRegister(
    ReportQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsTaxGstRegister,
      queryParameters: query.toQueryParameters(),
    );
    final json = response.data ?? {};
    return PaginatedReportResponse(
      data: GstReportEnvelopeDto.fromJson(
        (json['data'] as Map<String, dynamic>?) ?? {},
      ),
      meta: ReportPaginationMeta.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  Future<GstReportEnvelopeDto> getTaxGstRateSummary(ReportQuery query) =>
      _getData(
        ApiEndpoints.reportsTaxGstRateSummary,
        query,
        GstReportEnvelopeDto.fromJson,
      );

  Future<GstReportEnvelopeDto> getTaxReportEnvelope(
    String endpoint,
    ReportQuery query,
  ) => _getData(endpoint, query, GstReportEnvelopeDto.fromJson);

  Future<PaginatedReportResponse<TaxInvoiceReportPayloadDto>> getForm27eq(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsForm27eq,
    query,
    TaxInvoiceReportPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<TaxInvoiceReportPayloadDto>> getTcsReceivable(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsTcsReceivable,
    query,
    TaxInvoiceReportPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<TaxInvoiceReportPayloadDto>> getTdsPayable(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsTdsPayable,
    query,
    TaxInvoiceReportPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<TaxInvoiceReportPayloadDto>> getTdsReceivable(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsTdsReceivable,
    query,
    TaxInvoiceReportPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<ExpensesPayloadDto>> getExpenses(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsExpenses,
    query,
    ExpensesPayloadDto.fromJson,
  );

  Future<ExpenseByCategoryPayloadDto> getExpenseByCategory(
    ReportQuery query,
  ) => _getData(
    ApiEndpoints.reportsExpenseByCategory,
    query,
    ExpenseByCategoryPayloadDto.fromJson,
  );

  Future<ExpenseByItemPayloadDto> getExpenseByItem(ReportQuery query) =>
      _getData(
        ApiEndpoints.reportsExpenseByItem,
        query,
        ExpenseByItemPayloadDto.fromJson,
      );

  Future<PaginatedReportResponse<SalePurchaseOrdersPayloadDto>>
  getSalePurchaseOrders(ReportQuery query) => _getPaginated(
    ApiEndpoints.reportsSalePurchaseOrders,
    query,
    SalePurchaseOrdersPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<SalePurchaseOrderItemsPayloadDto>>
  getSalePurchaseOrderItems(ReportQuery query) => _getPaginated(
    ApiEndpoints.reportsSalePurchaseOrderItems,
    query,
    SalePurchaseOrderItemsPayloadDto.fromJson,
  );

  Future<PaginatedReportResponse<OtherIncomePayloadDto>> getOtherIncome(
    ReportQuery query,
  ) => _getPaginated(
    ApiEndpoints.reportsOtherIncome,
    query,
    OtherIncomePayloadDto.fromJson,
  );

  Future<OtherIncomeByCategoryPayloadDto> getOtherIncomeByCategory(
    ReportQuery query,
  ) => _getData(
    ApiEndpoints.reportsOtherIncomeByCategory,
    query,
    OtherIncomeByCategoryPayloadDto.fromJson,
  );

  Future<OtherIncomeByItemPayloadDto> getOtherIncomeByItem(ReportQuery query) =>
      _getData(
        ApiEndpoints.reportsOtherIncomeByItem,
        query,
        OtherIncomeByItemPayloadDto.fromJson,
      );

  Future<LoanStatementPayloadDto> getLoanStatement(ReportQuery query) =>
      _getData(
        ApiEndpoints.reportsLoanStatement,
        query,
        LoanStatementPayloadDto.fromJson,
      );

  Future<T> _getData<T>(
    String endpoint,
    ReportQuery query,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: query.toQueryParameters(),
    );
    return fromJson((response.data?['data'] as Map<String, dynamic>?) ?? {});
  }

  Future<PaginatedReportResponse<T>> _getPaginated<T>(
    String endpoint,
    ReportQuery query,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(response.data ?? {}, fromJson);
  }

  PaginatedReportResponse<T> _parsePaginated<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedReportResponse(
      data: fromJson((json['data'] as Map<String, dynamic>?) ?? {}),
      meta: ReportPaginationMeta.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
