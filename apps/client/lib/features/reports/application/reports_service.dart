import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/dashboard/application/local_business_metrics_provider.dart';
import 'package:billing_baba/features/dashboard/application/local_business_metrics_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/application/reports_error_mapper.dart';
import 'package:billing_baba/features/reports/data/reports_remote_data_source.dart';
import 'package:billing_baba/features/reports/data/reports_repository.dart';
import 'package:billing_baba/features/reports/models/mappers/report_extended_mapper.dart';
import 'package:billing_baba/features/reports/models/mappers/report_mapper.dart';
import 'package:billing_baba/features/reports/models/dto/gst_report_v2_dto.dart';
import 'package:billing_baba/features/reports/models/gst_report_type.dart';
import 'package:billing_baba/features/reports/models/tax_report_kind.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/reports/utils/item_detail_ledger.dart';
import 'package:billing_baba/features/reports/utils/profit_loss_report_builder.dart';
import 'package:billing_baba/features/reports/utils/report_transaction_table_shared.dart';
import 'package:billing_baba/features/reports/utils/balance_sheet_report_builder.dart';
import 'package:billing_baba/features/reports/utils/consumption_report_builder.dart';
import 'package:billing_baba/features/reports/utils/manufacturing_report_builder.dart';
import 'package:billing_baba/features/reports/utils/trial_balance_report_builder.dart';
import 'package:billing_baba/features/sales/data/job_work_remote_data_source.dart';
import 'package:billing_baba/features/sales/data/job_work_repository.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'reports_error_mapper.dart' show ReportsException;

part 'reports_service.g.dart';

@Riverpod(keepAlive: true)
Future<ReportsService> reportsService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final localMetrics = await ref.watch(localBusinessMetricsServiceProvider.future);
  return ReportsService(
    repository: ReportsRepository(
      remote: ReportsRemoteDataSource(api.dio),
    ),
    localMetrics: localMetrics,
    jobWorkRepository: JobWorkRepository(
      remote: JobWorkRemoteDataSource(api.dio),
    ),
  );
}

class SaleReportData {
  const SaleReportData({
    required this.rows,
    required this.totalSalesAmount,
    required this.receivedAmount,
    required this.balanceAmount,
    required this.meta,
  });

  final List<SaleInvoiceModel> rows;
  final double totalSalesAmount;
  final double receivedAmount;
  final double balanceAmount;
  final ReportPaginationMeta meta;
}

class PurchaseReportData {
  const PurchaseReportData({
    required this.rows,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceAmount,
    required this.meta,
  });

  final List<ReportPurchaseRow> rows;
  final double totalAmount;
  final double paidAmount;
  final double balanceAmount;
  final ReportPaginationMeta meta;
}

class StockSummaryReportData {
  const StockSummaryReportData({
    required this.rows,
    required this.totalStockValue,
    required this.meta,
  });

  final List<ReportStockSummaryRow> rows;
  final double totalStockValue;
  final ReportPaginationMeta meta;
}

class LowStockReportData {
  const LowStockReportData({
    required this.rows,
    required this.lowStockCount,
    required this.meta,
  });

  final List<ReportLowStockRow> rows;
  final int lowStockCount;
  final ReportPaginationMeta meta;
}

class PartyOutstandingReportData {
  const PartyOutstandingReportData({
    required this.rows,
    required this.totalReceivable,
    required this.receivablePartyCount,
    required this.totalPayable,
    required this.payablePartyCount,
    required this.meta,
  });

  final List<PartyModel> rows;
  final double totalReceivable;
  final int receivablePartyCount;
  final double totalPayable;
  final int payablePartyCount;
  final ReportPaginationMeta meta;
}

class PartyStatementReportData {
  const PartyStatementReportData({
    required this.entries,
    required this.summary,
  });

  final List<ReportPartyStatementEntry> entries;
  final ReportPartyStatementSummary summary;
}

class DayBookReportData {
  const DayBookReportData({
    required this.rows,
    required this.totalMoneyIn,
    required this.totalMoneyOut,
    required this.netTotal,
  });

  final List<ReportTransactionRow> rows;
  final double totalMoneyIn;
  final double totalMoneyOut;
  final double netTotal;
}

class AllTransactionsReportData {
  const AllTransactionsReportData({
    required this.rows,
    required this.meta,
  });

  final List<ReportTransactionRow> rows;
  final ReportPaginationMeta meta;
}

class ProfitLossReportData {
  const ProfitLossReportData({
    required this.items,
    required this.netProfit,
  });

  final List<ReportProfitLossItem> items;
  final double netProfit;
}

class TrialBalanceReportData {
  const TrialBalanceReportData({
    required this.rows,
    required this.totalDebit,
    required this.totalCredit,
    required this.isBalanced,
  });

  final List<ReportTrialBalanceRow> rows;
  final double totalDebit;
  final double totalCredit;
  final bool isBalanced;
}

class BalanceSheetReportData {
  const BalanceSheetReportData({
    required this.assets,
    required this.liabilities,
    required this.assetsTotal,
    required this.liabilitiesTotal,
    required this.netProfit,
    required this.openingAssets,
    required this.closingAssets,
    required this.openingLiabilities,
    required this.closingLiabilities,
    required this.openingEquity,
    required this.closingEquity,
    required this.isBalanced,
    required this.asOn,
  });

  final List<ReportBalanceSheetItem> assets;
  final List<ReportBalanceSheetItem> liabilities;
  final double assetsTotal;
  final double liabilitiesTotal;
  final double netProfit;
  final double openingAssets;
  final double closingAssets;
  final double openingLiabilities;
  final double closingLiabilities;
  final double openingEquity;
  final double closingEquity;
  final bool isBalanced;
  final DateTime asOn;
}

class GstrReportData {
  const GstrReportData({required this.rows});

  final List<ReportGstrRow> rows;
}

class Gstr3bReportData {
  const Gstr3bReportData({required this.rows});

  final List<ReportGstr3bRow> rows;
}

class BillWiseProfitReportData {
  const BillWiseProfitReportData({required this.rows, required this.meta});

  final List<ReportBillWiseProfitRow> rows;
  final ReportPaginationMeta meta;
}

class CashFlowReportData {
  const CashFlowReportData({
    required this.rows,
    required this.openingBalance,
    required this.closingBalance,
    required this.totalMoneyIn,
    required this.totalMoneyOut,
  });

  final List<ReportTransactionRow> rows;
  final double openingBalance;
  final double closingBalance;
  final double totalMoneyIn;
  final double totalMoneyOut;
}

class PartyWiseProfitLossReportData {
  const PartyWiseProfitLossReportData({required this.rows, required this.meta});

  final List<ReportPartyWiseProfitLossRow> rows;
  final ReportPaginationMeta meta;
}

class PartyReportByItemReportData {
  const PartyReportByItemReportData({required this.rows, required this.meta});

  final List<ReportPartyByItemRow> rows;
  final ReportPaginationMeta meta;
}

class SalePurchaseByPartyReportData {
  const SalePurchaseByPartyReportData({required this.rows, required this.meta});

  final List<ReportSalePurchaseByPartyRow> rows;
  final ReportPaginationMeta meta;
}

class SalePurchaseByPartyGroupReportData {
  const SalePurchaseByPartyGroupReportData({
    required this.rows,
    required this.meta,
  });

  final List<ReportSalePurchaseByPartyGroupRow> rows;
  final ReportPaginationMeta meta;
}

class Gstr9ReportData {
  const Gstr9ReportData({required this.rows});

  final List<ReportGstr9SupplyRow> rows;
}

class SaleSummaryByHsnReportData {
  const SaleSummaryByHsnReportData({required this.rows});

  final List<ReportHsnRow> rows;
}

class SacReportData {
  const SacReportData({required this.rows});

  final List<ReportSacRow> rows;
}

class ItemReportByPartyReportData {
  const ItemReportByPartyReportData({
    required this.rows,
    required this.meta,
    this.totalSaleAmount,
  });

  final List<ReportItemByPartyRow> rows;
  final ReportPaginationMeta meta;

  /// Full-period sale total when computed offline (not just the current page).
  final double? totalSaleAmount;

  double get resolvedTotalSaleAmount =>
      totalSaleAmount ??
      rows.fold<double>(0, (sum, row) => sum + row.amount);
}

class ItemWiseProfitLossReportData {
  const ItemWiseProfitLossReportData({
    required this.rows,
    required this.meta,
    this.totalSaleAmount,
    this.totalProfit,
  });

  final List<ReportItemWiseProfitLossRow> rows;
  final ReportPaginationMeta meta;
  final double? totalSaleAmount;
  final double? totalProfit;

  double get resolvedTotalSaleAmount =>
      totalSaleAmount ??
      rows.fold<double>(0, (sum, row) => sum + row.saleAmount);

  double get resolvedTotalProfit =>
      totalProfit ?? rows.fold<double>(0, (sum, row) => sum + row.profit);
}

class StockDetailReportData {
  const StockDetailReportData({required this.rows, required this.meta});

  final List<ReportStockDetailRow> rows;
  final ReportPaginationMeta meta;
}

class ItemDetailReportData {
  const ItemDetailReportData({
    required this.rows,
    required this.meta,
    this.openingQuantity = 0,
    this.ledgerRows,
  });

  final List<ReportItemDetailRow> rows;
  final ReportPaginationMeta meta;
  final double openingQuantity;
  final List<ReportItemDetailTableRow>? ledgerRows;
}

class CategoryAmountReportData {
  const CategoryAmountReportData({
    required this.rows,
    this.lowStockCategoryNames = const {},
  });

  final List<ReportCategoryAmountRow> rows;
  final Set<String> lowStockCategoryNames;
}

class ItemWiseDiscountReportData {
  const ItemWiseDiscountReportData({
    required this.rows,
    required this.meta,
    this.totalSaleAmount,
    this.totalDiscountAmount,
  });

  final List<ReportItemDiscountRow> rows;
  final ReportPaginationMeta meta;
  final double? totalSaleAmount;
  final double? totalDiscountAmount;

  double get resolvedTotalSaleAmount =>
      totalSaleAmount ??
      rows.fold<double>(0, (sum, row) => sum + row.saleAmount);

  double get resolvedTotalDiscountAmount =>
      totalDiscountAmount ??
      rows.fold<double>(0, (sum, row) => sum + row.discountAmount);
}

class ManufacturingReportData {
  const ManufacturingReportData({
    required this.rows,
    required this.meta,
    this.totalQtyManufactured,
    this.totalAmount,
  });

  final List<ReportManufacturingRow> rows;
  final ReportPaginationMeta meta;
  final double? totalQtyManufactured;
  final double? totalAmount;

  double get resolvedTotalQtyManufactured =>
      totalQtyManufactured ??
      rows.fold<double>(0, (sum, row) => sum + row.quantity);

  double get resolvedTotalAmount =>
      totalAmount ?? rows.fold<double>(0, (sum, row) => sum + row.cost);
}

class ConsumptionReportData {
  const ConsumptionReportData({
    required this.rows,
    required this.meta,
    this.totalQtyConsumed,
    this.totalAmount,
  });

  final List<ReportConsumptionRow> rows;
  final ReportPaginationMeta meta;
  final double? totalQtyConsumed;
  final double? totalAmount;

  double get resolvedTotalQtyConsumed =>
      totalQtyConsumed ??
      rows.fold<double>(0, (sum, row) => sum + row.quantity);

  double get resolvedTotalAmount =>
      totalAmount ?? rows.fold<double>(0, (sum, row) => sum + row.value);
}

class StockTransferReportData {
  const StockTransferReportData({
    required this.rows,
    required this.meta,
    this.totalQtyTransferred,
    this.totalValue,
  });

  final List<ReportStockTransferRow> rows;
  final ReportPaginationMeta meta;
  final double? totalQtyTransferred;
  final double? totalValue;

  double get resolvedTotalQtyTransferred =>
      totalQtyTransferred ??
      rows.fold<double>(0, (sum, row) => sum + row.quantity);

  double get resolvedTotalValue =>
      totalValue ?? rows.fold<double>(0, (sum, row) => sum + row.value);
}

class BankStatementReportData {
  const BankStatementReportData({
    required this.rows,
    this.accountName,
    this.openingBalance,
    this.closingBalance,
  });

  final List<ReportBankStatementRow> rows;
  final String? accountName;
  final String? openingBalance;
  final String? closingBalance;
}

class GstTaxReportData {
  const GstTaxReportData({required this.rows, required this.meta});

  final List<ReportGstTaxPartyRow> rows;
  final ReportPaginationMeta meta;
}

class GstTaxRateReportData {
  const GstTaxRateReportData({required this.rows});

  final List<ReportGstTaxRateRow> rows;
}

class TaxInvoiceReportData {
  const TaxInvoiceReportData({required this.rows, required this.meta});

  final List<ReportTaxInvoiceRow> rows;
  final ReportPaginationMeta meta;
}

class ExpensesReportData {
  const ExpensesReportData({
    required this.rows,
    required this.totalAmount,
    required this.meta,
  });

  final List<ReportExpenseRow> rows;
  final double totalAmount;
  final ReportPaginationMeta meta;
}

class ExpenseByCategoryReportData {
  const ExpenseByCategoryReportData({required this.rows});

  final List<ReportExpenseCategoryRow> rows;
}

class ExpenseByItemReportData {
  const ExpenseByItemReportData({required this.rows});

  final List<ReportExpenseItemRow> rows;
}

class SalePurchaseOrdersReportData {
  const SalePurchaseOrdersReportData({
    required this.rows,
    required this.totalAmount,
    required this.meta,
  });

  final List<ReportOrderRow> rows;
  final double totalAmount;
  final ReportPaginationMeta meta;
}

class SalePurchaseOrderItemsReportData {
  const SalePurchaseOrderItemsReportData({
    required this.rows,
    required this.meta,
  });

  final List<ReportOrderItemRow> rows;
  final ReportPaginationMeta meta;
}

class OtherIncomeReportData {
  const OtherIncomeReportData({
    required this.rows,
    required this.totalAmount,
    required this.meta,
  });

  final List<ReportOtherIncomeRow> rows;
  final double totalAmount;
  final ReportPaginationMeta meta;
}

class OtherIncomeByCategoryReportData {
  const OtherIncomeByCategoryReportData({required this.rows});

  final List<ReportOtherIncomeCategoryRow> rows;
}

class OtherIncomeByItemReportData {
  const OtherIncomeByItemReportData({required this.rows});

  final List<ReportOtherIncomeItemRow> rows;
}

class LoanStatementReportData {
  const LoanStatementReportData({required this.rows});

  final List<ReportLoanStatementRow> rows;
}

class ReportsService {
  ReportsService({
    required this._repository,
    this._localMetrics,
    JobWorkRepository? jobWorkRepository,
  }) : _jobWorkRepository = jobWorkRepository;

  final ReportsRepository _repository;
  final LocalBusinessMetricsService? _localMetrics;
  final JobWorkRepository? _jobWorkRepository;

  Future<SaleReportData> fetchSaleReport(ReportQuery query) async {
    try {
      final response = await _repository.getSaleReport(query);
      final payload = response.data;
      final remote = SaleReportData(
        rows: payload.rows.map(ReportMapper.toSaleInvoice).toList(),
        totalSalesAmount: _amount(payload.summary.totalAmount),
        receivedAmount: _amount(payload.summary.receivedAmount ?? '0'),
        balanceAmount: _amount(payload.summary.balanceAmount ?? '0'),
        meta: response.meta,
      );
      return _preferLocalSaleReport(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildSaleReport(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<PurchaseReportData> fetchPurchaseReport(ReportQuery query) async {
    try {
      final response = await _repository.getPurchaseReport(query);
      final payload = response.data;
      final remote = PurchaseReportData(
        rows: payload.rows.map(ReportMapper.toPurchaseRow).toList(),
        totalAmount: _amount(payload.summary.totalAmount),
        paidAmount: _amount(payload.summary.paidAmount ?? '0'),
        balanceAmount: _amount(payload.summary.balanceAmount ?? '0'),
        meta: response.meta,
      );
      return _preferLocalPurchaseReport(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildPurchaseReport(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<SaleReportData> _preferLocalSaleReport(
    SaleReportData remote,
    ReportQuery query,
  ) async {
    if (remote.totalSalesAmount != 0 && remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildSaleReport(query);
    if (local == null) return remote;
    return local;
  }

  Future<PurchaseReportData> _preferLocalPurchaseReport(
    PurchaseReportData remote,
    ReportQuery query,
  ) async {
    if (remote.totalAmount != 0 && remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildPurchaseReport(query);
    if (local == null) return remote;
    return local;
  }

  Future<StockSummaryReportData> fetchStockSummary(ReportQuery query) async {
    try {
      final response = await _repository.getStockSummary(query);
      final payload = response.data;
      final remote = StockSummaryReportData(
        rows: payload.rows.map(ReportMapper.toStockSummaryRow).toList(),
        totalStockValue: _amount(payload.totalStockValue),
        meta: response.meta,
      );
      return _preferLocalStockSummary(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildStockSummary(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<StockSummaryReportData> _preferLocalStockSummary(
    StockSummaryReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty || remote.totalStockValue != 0) return remote;
    final local = await _localMetrics?.buildStockSummary(query);
    if (local == null) return remote;
    return local;
  }

  Future<LowStockReportData> fetchLowStock(ReportQuery query) async {
    try {
      final response = await _repository.getLowStock(query);
      final payload = response.data;
      final remote = LowStockReportData(
        rows: payload.rows.map(ReportMapper.toLowStockRow).toList(),
        lowStockCount: payload.lowStockCount,
        meta: response.meta,
      );
      return _preferLocalLowStock(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildLowStock(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<LowStockReportData> _preferLocalLowStock(
    LowStockReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildLowStock(query);
    if (local == null) return remote;
    return local;
  }

  Future<PartyOutstandingReportData> fetchPartyOutstanding(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getPartyOutstanding(query);
      final payload = response.data;
      final remote = PartyOutstandingReportData(
        rows: payload.rows.map(ReportMapper.toPartyModel).toList(),
        totalReceivable: _amount(payload.summary.totalReceivable),
        receivablePartyCount: payload.summary.receivablePartyCount,
        totalPayable: _amount(payload.summary.totalPayable),
        payablePartyCount: payload.summary.payablePartyCount,
        meta: response.meta,
      );
      return _preferLocalPartyOutstanding(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildPartyOutstanding(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<PartyOutstandingReportData> _preferLocalPartyOutstanding(
    PartyOutstandingReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildPartyOutstanding(query);
    if (local == null) return remote;
    return local;
  }

  Future<PartyStatementReportData> fetchPartyStatement(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getPartyStatement(query);
      final remote = PartyStatementReportData(
        entries: payload.entries
            .map(ReportMapper.toPartyStatementEntry)
            .toList(),
        summary: ReportMapper.toPartyStatementSummary(payload.summary),
      );
      return _preferLocalPartyStatement(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildPartyStatement(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<PartyStatementReportData> _preferLocalPartyStatement(
    PartyStatementReportData remote,
    ReportQuery query,
  ) async {
    final local = await _localMetrics?.buildPartyStatement(query);
    if (local == null) return remote;
    if (remote.entries.isNotEmpty) return remote;
    return local;
  }

  Future<DayBookReportData> fetchDayBook(ReportQuery query) async {
    try {
      final payload = await _repository.getDayBook(query);
      final remote = DayBookReportData(
        rows: payload.rows.map(ReportMapper.toTransactionRow).toList(),
        totalMoneyIn: _amount(payload.totalMoneyIn),
        totalMoneyOut: _amount(payload.totalMoneyOut),
        netTotal: _amount(payload.netTotal),
      );
      return _preferLocalDayBook(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildDayBook(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<DayBookReportData> _preferLocalDayBook(
    DayBookReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildDayBook(query);
    if (local == null) return remote;
    return local;
  }

  Future<AllTransactionsReportData> fetchAllTransactions(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getAllTransactions(query);
      final payload = response.data;
      final remote = AllTransactionsReportData(
        rows: payload.rows.map(ReportMapper.toTransactionRow).toList(),
        meta: response.meta,
      );
      return _preferLocalAllTransactions(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildAllTransactions(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<AllTransactionsReportData> _preferLocalAllTransactions(
    AllTransactionsReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildAllTransactions(query);
    if (local == null) return remote;
    return local;
  }

  Future<ProfitLossReportData> fetchProfitLoss(ReportQuery query) async {
    try {
      final payload = await _repository.getProfitLoss(query);
      final remote = ProfitLossReportData(
        items: payload.items.map(ReportMapper.toProfitLossItem).toList(),
        netProfit: _amount(payload.netProfit),
      );
      return _preferLocalProfitLoss(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildProfitLoss(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<ProfitLossReportData> _preferLocalProfitLoss(
    ProfitLossReportData remote,
    ReportQuery query,
  ) async {
    if (ProfitLossReportBuilder.hasMeaningfulActivity(
      items: remote.items,
      netProfit: remote.netProfit,
    )) {
      return remote;
    }
    final local = await _localMetrics?.buildProfitLoss(query);
    if (local != null) return local;
    return remote;
  }

  Future<TrialBalanceReportData> fetchTrialBalance(ReportQuery query) async {
    try {
      final payload = await _repository.getTrialBalance(query);
      final remote = TrialBalanceReportData(
        rows: payload.rows.map(ReportMapper.toTrialBalanceRow).toList(),
        totalDebit: _amount(payload.totalDebit),
        totalCredit: _amount(payload.totalCredit),
        isBalanced: payload.isBalanced,
      );
      return _preferLocalTrialBalance(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildTrialBalance(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<TrialBalanceReportData> _preferLocalTrialBalance(
    TrialBalanceReportData remote,
    ReportQuery query,
  ) async {
    if (TrialBalanceReportBuilder.hasMeaningfulActivity(
      rows: remote.rows,
      totalDebit: remote.totalDebit,
      totalCredit: remote.totalCredit,
    )) {
      return remote;
    }
    final local = await _localMetrics?.buildTrialBalance(query);
    if (local != null) return local;
    return remote;
  }

  Future<BalanceSheetReportData> fetchBalanceSheet(ReportQuery query) async {
    try {
      final payload = await _repository.getBalanceSheet(query);
      final remote = BalanceSheetReportData(
        assets: payload.assets.map(ReportMapper.toBalanceSheetItem).toList(),
        liabilities: payload.liabilities
            .map(ReportMapper.toBalanceSheetItem)
            .toList(),
        assetsTotal: _amount(payload.assetsTotal),
        liabilitiesTotal: _amount(payload.liabilitiesTotal),
        netProfit: _amount(payload.netProfit),
        openingAssets: _amount(payload.openingAssets),
        closingAssets: _amount(payload.closingAssets),
        openingLiabilities: _amount(payload.openingLiabilities),
        closingLiabilities: _amount(payload.closingLiabilities),
        openingEquity: _amount(payload.openingEquity),
        closingEquity: _amount(payload.closingEquity),
        isBalanced: payload.isBalanced,
        asOn: DateTime.tryParse(payload.asOn) ?? DateTime.now(),
      );
      return _preferLocalBalanceSheet(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildBalanceSheet(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<BalanceSheetReportData> _preferLocalBalanceSheet(
    BalanceSheetReportData remote,
    ReportQuery query,
  ) async {
    if (BalanceSheetReportBuilder.hasMeaningfulActivity(
      assets: remote.assets,
      liabilities: remote.liabilities,
      assetsTotal: remote.assetsTotal,
      liabilitiesTotal: remote.liabilitiesTotal,
      netProfit: remote.netProfit,
    )) {
      return remote;
    }
    final local = await _localMetrics?.buildBalanceSheet(query);
    if (local != null) return local;
    return remote;
  }

  Future<GstReportEnvelopeDto> fetchGstFilingReport(
    GstReportType type,
    ReportQuery query,
  ) async {
    try {
      return await _repository.getGstFilingReport(type, query);
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<GstReportEnvelopeDto> fetchTaxReport(
    TaxReportKind kind,
    ReportQuery query,
  ) async {
    try {
      return switch (kind) {
        TaxReportKind.gstRegister =>
          (await _repository.getTaxGstRegister(query)).data,
        TaxReportKind.gstRateSummary =>
          await _repository.getTaxGstRateSummary(query),
        TaxReportKind.form27eq => await _repository.getTaxReportEnvelope(
          ApiEndpoints.reportsTaxForm27eq,
          query,
        ),
        TaxReportKind.tcsReceivable => await _repository.getTaxReportEnvelope(
          ApiEndpoints.reportsTaxTcsReceivable,
          query,
        ),
        TaxReportKind.tdsPayable => await _repository.getTaxReportEnvelope(
          ApiEndpoints.reportsTaxTdsPayable,
          query,
        ),
        TaxReportKind.tdsReceivable => await _repository.getTaxReportEnvelope(
          ApiEndpoints.reportsTaxTdsReceivable,
          query,
        ),
      };
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<BillWiseProfitReportData> fetchBillWiseProfit(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getBillWiseProfit(query);
      final remote = BillWiseProfitReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toBillWiseProfitRow)
            .toList(),
        meta: response.meta,
      );
      return _preferLocalBillWiseProfit(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildBillWiseProfit(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<BillWiseProfitReportData> _preferLocalBillWiseProfit(
    BillWiseProfitReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildBillWiseProfit(query);
    if (local == null) return remote;
    return local;
  }

  Future<CashFlowReportData> fetchCashFlow(ReportQuery query) async {
    try {
      final payload = await _repository.getCashFlow(query);
      final remote = CashFlowReportData(
        rows: payload.rows.map(ReportMapper.toTransactionRow).toList(),
        openingBalance: _amount(payload.openingBalance),
        closingBalance: _amount(payload.closingBalance),
        totalMoneyIn: _amount(payload.totalMoneyIn),
        totalMoneyOut: _amount(payload.totalMoneyOut),
      );
      return _preferLocalCashFlow(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildCashFlow(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<CashFlowReportData> _preferLocalCashFlow(
    CashFlowReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildCashFlow(query);
    if (local == null) return remote;
    return local;
  }

  Future<PartyWiseProfitLossReportData> fetchPartyWiseProfitLoss(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getPartyWiseProfitLoss(query);
      final remote = PartyWiseProfitLossReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toPartyWiseProfitLossRow)
            .toList(),
        meta: response.meta,
      );
      return _preferLocalPartyWiseProfitLoss(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildPartyWiseProfitLoss(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<PartyWiseProfitLossReportData> _preferLocalPartyWiseProfitLoss(
    PartyWiseProfitLossReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildPartyWiseProfitLoss(query);
    if (local == null) return remote;
    return local;
  }

  Future<PartyReportByItemReportData> fetchPartyReportByItem(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getPartyReportByItem(query);
      final remote = PartyReportByItemReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toPartyByItemRow)
            .toList(),
        meta: response.meta,
      );
      return _preferLocalPartyReportByItem(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildPartyReportByItem(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<PartyReportByItemReportData> _preferLocalPartyReportByItem(
    PartyReportByItemReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildPartyReportByItem(query);
    if (local == null) return remote;
    return local;
  }

  Future<SalePurchaseByPartyReportData> fetchSalePurchaseByParty(
    ReportQuery query,
  ) async {
    final localFuture = _localMetrics?.buildSalePurchaseByParty(query);
    try {
      final response = await _repository.getSalePurchaseByParty(query);
      final remote = SalePurchaseByPartyReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toSalePurchaseByPartyRow)
            .toList(),
        meta: response.meta,
      );
      return _preferLocalSalePurchaseByParty(remote, localFuture);
    } on DioException catch (error) {
      final local = await localFuture;
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<SalePurchaseByPartyReportData> _preferLocalSalePurchaseByParty(
    SalePurchaseByPartyReportData remote,
    Future<SalePurchaseByPartyReportData?>? localFuture,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await localFuture;
    if (local == null) return remote;
    return local;
  }

  Future<SalePurchaseByPartyGroupReportData> fetchSalePurchaseByPartyGroup(
    ReportQuery query,
  ) async {
    final localFuture = _localMetrics?.buildSalePurchaseByPartyGroup(query);
    try {
      final response = await _repository.getSalePurchaseByPartyGroup(query);
      final remote = SalePurchaseByPartyGroupReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toSalePurchaseByPartyGroupRow)
            .toList(),
        meta: response.meta,
      );
      return _preferLocalSalePurchaseByPartyGroup(remote, localFuture);
    } on DioException catch (error) {
      final local = await localFuture;
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<SalePurchaseByPartyGroupReportData>
  _preferLocalSalePurchaseByPartyGroup(
    SalePurchaseByPartyGroupReportData remote,
    Future<SalePurchaseByPartyGroupReportData?>? localFuture,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await localFuture;
    if (local == null) return remote;
    return local;
  }

  Future<ItemReportByPartyReportData> fetchItemReportByParty(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getItemReportByParty(query);
      final remote = ItemReportByPartyReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toItemByPartyRow)
            .toList(),
        meta: response.meta,
      );
      return _preferLocalItemReportByParty(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildItemReportByParty(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<ItemReportByPartyReportData> _preferLocalItemReportByParty(
    ItemReportByPartyReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildItemReportByParty(query);
    if (local == null) return remote;
    return local;
  }

  Future<ItemWiseProfitLossReportData> fetchItemWiseProfitLoss(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getItemWiseProfitLoss(query);
      final remote = ItemWiseProfitLossReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toItemWiseProfitLossRow)
            .toList(),
        meta: response.meta,
      );
      return _preferLocalItemWiseProfitLoss(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildItemWiseProfitLoss(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<ItemWiseProfitLossReportData> _preferLocalItemWiseProfitLoss(
    ItemWiseProfitLossReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildItemWiseProfitLoss(query);
    if (local == null) return remote;
    return local;
  }

  Future<StockDetailReportData> fetchStockDetail(ReportQuery query) async {
    try {
      final response = await _repository.getStockDetail(query);
      final remote = StockDetailReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toStockDetailRow)
            .toList(),
        meta: response.meta,
      );
      return _preferLocalStockDetail(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildStockDetail(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<StockDetailReportData> _preferLocalStockDetail(
    StockDetailReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildStockDetail(query);
    if (local == null) return remote;
    return local;
  }

  Future<ItemDetailReportData> fetchItemDetail(ReportQuery query) async {
    try {
      final response = await _repository.getItemDetail(query);
      final rows = response.data.rows
          .map(ReportExtendedMapper.toItemDetailRow)
          .toList();
      final remote = _enrichItemDetailReportData(
        rows: rows,
        meta: response.meta,
      );
      return _preferLocalItemDetail(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildItemDetail(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<ItemDetailReportData> _preferLocalItemDetail(
    ItemDetailReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildItemDetail(query);
    if (local == null) return remote;
    return local;
  }

  ItemDetailReportData _enrichItemDetailReportData({
    required List<ReportItemDetailRow> rows,
    required ReportPaginationMeta meta,
    double openingQuantity = 0,
  }) {
    return ItemDetailReportData(
      rows: rows,
      meta: meta,
      openingQuantity: openingQuantity,
      ledgerRows: buildItemDetailLedgerRows(
        rows,
        openingQty: openingQuantity,
        newestFirst: true,
      ),
    );
  }

  Future<CategoryAmountReportData> fetchSalePurchaseByItemCategory(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getSalePurchaseByItemCategory(query);
      final remote = CategoryAmountReportData(
        rows: payload.rows
            .map(ReportExtendedMapper.toCategoryAmountRow)
            .toList(),
      );
      return _preferLocalSalePurchaseByItemCategory(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildSalePurchaseByItemCategory(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<CategoryAmountReportData> _preferLocalSalePurchaseByItemCategory(
    CategoryAmountReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildSalePurchaseByItemCategory(query);
    if (local == null) return remote;
    return local;
  }

  Future<CategoryAmountReportData> fetchStockSummaryByItemCategory(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getStockSummaryByItemCategory(query);
      final remote = CategoryAmountReportData(
        rows: payload.rows
            .map(ReportExtendedMapper.toCategoryAmountRow)
            .toList(),
      );
      return _preferLocalStockSummaryByItemCategory(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildStockSummaryByItemCategory(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<CategoryAmountReportData> _preferLocalStockSummaryByItemCategory(
    CategoryAmountReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildStockSummaryByItemCategory(query);
    if (local == null) return remote;
    return local;
  }

  Future<CategoryAmountReportData> fetchItemCategoryWiseProfitLoss(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getItemCategoryWiseProfitLoss(query);
      final remote = CategoryAmountReportData(
        rows: payload.rows
            .map(ReportExtendedMapper.toCategoryAmountRow)
            .toList(),
      );
      return _preferLocalItemCategoryWiseProfitLoss(remote, query);
    } on DioException catch (error) {
      final local =
          await _localMetrics?.buildItemCategoryWiseProfitLoss(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<CategoryAmountReportData> _preferLocalItemCategoryWiseProfitLoss(
    CategoryAmountReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local =
        await _localMetrics?.buildItemCategoryWiseProfitLoss(query);
    if (local == null) return remote;
    return local;
  }

  Future<ItemWiseDiscountReportData> fetchItemWiseDiscount(
    ReportQuery query,
  ) async {
    final localFuture = _localMetrics?.buildItemWiseDiscount(query);
    try {
      final response = await _repository.getItemWiseDiscount(query);
      final remote = ItemWiseDiscountReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toItemDiscountRow)
            .toList(),
        meta: response.meta,
      );
      return _preferLocalItemWiseDiscount(remote, localFuture);
    } on DioException catch (error) {
      final local = await localFuture;
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<ItemWiseDiscountReportData> _preferLocalItemWiseDiscount(
    ItemWiseDiscountReportData remote,
    Future<ItemWiseDiscountReportData?>? localFuture,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await localFuture;
    if (local == null) return remote;
    return local;
  }

  Future<ManufacturingReportData> fetchManufacturing(ReportQuery query) async {
    final localFuture = buildManufacturingReportFromJobWork(
      repository: _jobWorkRepository,
      query: query,
    );
    try {
      final response = await _repository.getManufacturing(query);
      final remote = ManufacturingReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toManufacturingRow)
            .toList(),
        meta: response.meta,
      );
      return _preferLocalManufacturing(remote, localFuture);
    } on DioException catch (error) {
      final local = _mapManufacturingBuild(await localFuture);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<ManufacturingReportData> _preferLocalManufacturing(
    ManufacturingReportData remote,
    Future<ManufacturingReportBuildResult?> localFuture,
  ) async {
    final build = await localFuture;
    final fromJobWork = _mapManufacturingBuild(build);
    if (remote.rows.isEmpty) {
      return fromJobWork ?? remote;
    }
    if (fromJobWork == null) return remote;
    return ManufacturingReportData(
      rows: remote.rows,
      meta: remote.meta,
      totalQtyManufactured: fromJobWork.totalQtyManufactured,
      totalAmount: fromJobWork.totalAmount,
    );
  }

  ManufacturingReportData? _mapManufacturingBuild(
    ManufacturingReportBuildResult? result,
  ) {
    if (result == null) return null;
    return ManufacturingReportData(
      rows: result.rows,
      meta: result.meta,
      totalQtyManufactured: result.totalQtyManufactured,
      totalAmount: result.totalAmount,
    );
  }

  Future<ConsumptionReportData> fetchConsumption(ReportQuery query) async {
    final localFuture = buildConsumptionReportFromJobWork(
      repository: _jobWorkRepository,
      query: query,
      itemNameById: () async =>
          await _localMetrics?.activeItemNameById() ?? {},
    );
    try {
      final response = await _repository.getConsumption(query);
      final remote = ConsumptionReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toConsumptionRow)
            .toList(),
        meta: response.meta,
      );
      return _preferLocalConsumption(remote, localFuture);
    } on DioException catch (error) {
      final local = _mapConsumptionBuild(await localFuture);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<ConsumptionReportData> _preferLocalConsumption(
    ConsumptionReportData remote,
    Future<ConsumptionReportBuildResult?> localFuture,
  ) async {
    final build = await localFuture;
    final fromJobWork = _mapConsumptionBuild(build);
    if (remote.rows.isEmpty) {
      return fromJobWork ?? remote;
    }
    if (fromJobWork == null) return remote;
    return ConsumptionReportData(
      rows: remote.rows,
      meta: remote.meta,
      totalQtyConsumed: fromJobWork.totalQtyConsumed,
      totalAmount: fromJobWork.totalAmount,
    );
  }

  ConsumptionReportData? _mapConsumptionBuild(
    ConsumptionReportBuildResult? result,
  ) {
    if (result == null) return null;
    return ConsumptionReportData(
      rows: result.rows,
      meta: result.meta,
      totalQtyConsumed: result.totalQtyConsumed,
      totalAmount: result.totalAmount,
    );
  }

  Future<StockTransferReportData> fetchStockTransfer(ReportQuery query) async {
    final localFuture = _localMetrics?.buildStockTransfer(query);
    try {
      final response = await _repository.getStockTransfer(query);
      final remote = StockTransferReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toStockTransferRow)
            .toList(),
        meta: response.meta,
      );
      return _preferLocalStockTransfer(remote, localFuture);
    } on DioException catch (error) {
      final local = await localFuture;
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<StockTransferReportData> _preferLocalStockTransfer(
    StockTransferReportData remote,
    Future<StockTransferReportData?>? localFuture,
  ) async {
    final local = await localFuture;
    if (remote.rows.isEmpty) {
      return local ?? remote;
    }
    if (local == null) return remote;
    return StockTransferReportData(
      rows: remote.rows,
      meta: remote.meta,
      totalQtyTransferred: local.totalQtyTransferred,
      totalValue: local.totalValue,
    );
  }

  Future<BankStatementReportData> fetchBankStatement(ReportQuery query) async {
    try {
      final payload = await _repository.getBankStatement(query);
      return BankStatementReportData(
        rows: payload.rows
            .map(ReportExtendedMapper.toBankStatementRow)
            .toList(),
        accountName: payload.accountName,
        openingBalance: payload.summary?.openingBalance,
        closingBalance: payload.summary?.closingBalance,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<GstTaxReportData> fetchGstReport(ReportQuery query) async {
    try {
      final response = await _repository.getGstReport(query);
      return GstTaxReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toGstTaxPartyRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<GstTaxRateReportData> fetchGstRateReport(ReportQuery query) async {
    try {
      final payload = await _repository.getGstRateReport(query);
      return GstTaxRateReportData(
        rows: payload.rows.map(ReportExtendedMapper.toGstTaxRateRow).toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<TaxInvoiceReportData> fetchForm27eq(ReportQuery query) async {
    try {
      final response = await _repository.getForm27eq(query);
      return TaxInvoiceReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toTaxInvoiceRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<TaxInvoiceReportData> fetchTcsReceivable(ReportQuery query) async {
    try {
      final response = await _repository.getTcsReceivable(query);
      return TaxInvoiceReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toTaxInvoiceRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<TaxInvoiceReportData> fetchTdsPayable(ReportQuery query) async {
    try {
      final response = await _repository.getTdsPayable(query);
      return TaxInvoiceReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toTaxInvoiceRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<TaxInvoiceReportData> fetchTdsReceivable(ReportQuery query) async {
    try {
      final response = await _repository.getTdsReceivable(query);
      return TaxInvoiceReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toTaxInvoiceRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<ExpensesReportData> fetchExpenses(ReportQuery query) async {
    try {
      final response = await _repository.getExpenses(query);
      final remote = ExpensesReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toExpenseRow)
            .toList(),
        totalAmount: _amount(response.data.totalAmount),
        meta: response.meta,
      );
      return _preferLocalExpensesReport(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildExpensesReport(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<ExpensesReportData> _preferLocalExpensesReport(
    ExpensesReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty || remote.totalAmount > 0) return remote;
    final local = await _localMetrics?.buildExpensesReport(query);
    if (local == null) return remote;
    return local;
  }

  Future<ExpenseByCategoryReportData> fetchExpenseByCategory(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getExpenseByCategory(query);
      final remote = ExpenseByCategoryReportData(
        rows: payload.rows
            .map(ReportExtendedMapper.toExpenseCategoryRow)
            .toList(),
      );
      return _preferLocalExpenseByCategoryReport(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildExpenseByCategoryReport(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<ExpenseByCategoryReportData> _preferLocalExpenseByCategoryReport(
    ExpenseByCategoryReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildExpenseByCategoryReport(query);
    if (local == null) return remote;
    return local;
  }

  Future<ExpenseByItemReportData> fetchExpenseByItem(ReportQuery query) async {
    try {
      final payload = await _repository.getExpenseByItem(query);
      final remote = ExpenseByItemReportData(
        rows: payload.rows.map(ReportExtendedMapper.toExpenseItemRow).toList(),
      );
      return _preferLocalExpenseByItemReport(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildExpenseByItemReport(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<ExpenseByItemReportData> _preferLocalExpenseByItemReport(
    ExpenseByItemReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty) return remote;
    final local = await _localMetrics?.buildExpenseByItemReport(query);
    if (local == null) return remote;
    return local;
  }

  Future<SalePurchaseOrdersReportData> fetchSalePurchaseOrders(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getSalePurchaseOrders(query);
      final remote = SalePurchaseOrdersReportData(
        rows: response.data.rows.map(ReportExtendedMapper.toOrderRow).toList(),
        totalAmount: _amount(response.data.totalAmount),
        meta: response.meta,
      );
      return _preferLocalSalePurchaseOrdersReport(remote, query);
    } on DioException catch (error) {
      final local = await _localMetrics?.buildSalePurchaseOrdersReport(query);
      if (local != null) return local;
      throw mapReportsError(error);
    }
  }

  Future<SalePurchaseOrdersReportData> _preferLocalSalePurchaseOrdersReport(
    SalePurchaseOrdersReportData remote,
    ReportQuery query,
  ) async {
    if (remote.rows.isNotEmpty || remote.totalAmount > 0) return remote;
    final local = await _localMetrics?.buildSalePurchaseOrdersReport(query);
    if (local == null) return remote;
    return local;
  }

  Future<SalePurchaseOrderItemsReportData> fetchSalePurchaseOrderItems(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getSalePurchaseOrderItems(query);
      return SalePurchaseOrderItemsReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toOrderItemRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<OtherIncomeReportData> fetchOtherIncome(ReportQuery query) async {
    try {
      final response = await _repository.getOtherIncome(query);
      return OtherIncomeReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toOtherIncomeRow)
            .toList(),
        totalAmount: _amount(response.data.totalAmount),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<OtherIncomeByCategoryReportData> fetchOtherIncomeByCategory(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getOtherIncomeByCategory(query);
      return OtherIncomeByCategoryReportData(
        rows: payload.rows
            .map(ReportExtendedMapper.toOtherIncomeCategoryRow)
            .toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<OtherIncomeByItemReportData> fetchOtherIncomeByItem(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getOtherIncomeByItem(query);
      return OtherIncomeByItemReportData(
        rows: payload.rows
            .map(ReportExtendedMapper.toOtherIncomeItemRow)
            .toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<LoanStatementReportData> fetchLoanStatement(ReportQuery query) async {
    try {
      final payload = await _repository.getLoanStatement(query);
      return LoanStatementReportData(
        rows: payload.rows
            .map(ReportExtendedMapper.toLoanStatementRow)
            .toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  double _amount(String value) => double.tryParse(value) ?? 0;
}
