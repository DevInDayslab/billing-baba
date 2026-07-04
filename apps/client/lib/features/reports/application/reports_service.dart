import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/application/reports_error_mapper.dart';
import 'package:billing_baba/features/reports/data/reports_remote_data_source.dart';
import 'package:billing_baba/features/reports/data/reports_repository.dart';
import 'package:billing_baba/features/reports/models/mappers/report_extended_mapper.dart';
import 'package:billing_baba/features/reports/models/mappers/report_mapper.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'reports_error_mapper.dart' show ReportsException;

part 'reports_service.g.dart';

@Riverpod(keepAlive: true)
Future<ReportsService> reportsService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return ReportsService(
    repository: ReportsRepository(
      remote: ReportsRemoteDataSource(api.dio),
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
  const ItemReportByPartyReportData({required this.rows, required this.meta});

  final List<ReportItemByPartyRow> rows;
  final ReportPaginationMeta meta;
}

class ItemWiseProfitLossReportData {
  const ItemWiseProfitLossReportData({required this.rows, required this.meta});

  final List<ReportItemWiseProfitLossRow> rows;
  final ReportPaginationMeta meta;
}

class StockDetailReportData {
  const StockDetailReportData({required this.rows, required this.meta});

  final List<ReportStockDetailRow> rows;
  final ReportPaginationMeta meta;
}

class ItemDetailReportData {
  const ItemDetailReportData({required this.rows, required this.meta});

  final List<ReportItemDetailRow> rows;
  final ReportPaginationMeta meta;
}

class CategoryAmountReportData {
  const CategoryAmountReportData({required this.rows});

  final List<ReportCategoryAmountRow> rows;
}

class ItemWiseDiscountReportData {
  const ItemWiseDiscountReportData({required this.rows, required this.meta});

  final List<ReportItemDiscountRow> rows;
  final ReportPaginationMeta meta;
}

class ManufacturingReportData {
  const ManufacturingReportData({required this.rows, required this.meta});

  final List<ReportManufacturingRow> rows;
  final ReportPaginationMeta meta;
}

class ConsumptionReportData {
  const ConsumptionReportData({required this.rows, required this.meta});

  final List<ReportConsumptionRow> rows;
  final ReportPaginationMeta meta;
}

class StockTransferReportData {
  const StockTransferReportData({required this.rows, required this.meta});

  final List<ReportStockTransferRow> rows;
  final ReportPaginationMeta meta;
}

class BankStatementReportData {
  const BankStatementReportData({required this.rows});

  final List<ReportBankStatementRow> rows;
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
  const SalePurchaseOrderItemsReportData({required this.rows, required this.meta});

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
  ReportsService({required this._repository});

  final ReportsRepository _repository;

  Future<SaleReportData> fetchSaleReport(ReportQuery query) async {
    try {
      final response = await _repository.getSaleReport(query);
      final payload = response.data;
      return SaleReportData(
        rows: payload.rows.map(ReportMapper.toSaleInvoice).toList(),
        totalSalesAmount: _amount(payload.summary.totalAmount),
        receivedAmount: _amount(payload.summary.receivedAmount ?? '0'),
        balanceAmount: _amount(payload.summary.balanceAmount ?? '0'),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<PurchaseReportData> fetchPurchaseReport(ReportQuery query) async {
    try {
      final response = await _repository.getPurchaseReport(query);
      final payload = response.data;
      return PurchaseReportData(
        rows: payload.rows.map(ReportMapper.toPurchaseRow).toList(),
        totalAmount: _amount(payload.summary.totalAmount),
        paidAmount: _amount(payload.summary.paidAmount ?? '0'),
        balanceAmount: _amount(payload.summary.balanceAmount ?? '0'),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<StockSummaryReportData> fetchStockSummary(ReportQuery query) async {
    try {
      final response = await _repository.getStockSummary(query);
      final payload = response.data;
      return StockSummaryReportData(
        rows: payload.rows.map(ReportMapper.toStockSummaryRow).toList(),
        totalStockValue: _amount(payload.totalStockValue),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<LowStockReportData> fetchLowStock(ReportQuery query) async {
    try {
      final response = await _repository.getLowStock(query);
      final payload = response.data;
      return LowStockReportData(
        rows: payload.rows.map(ReportMapper.toLowStockRow).toList(),
        lowStockCount: payload.lowStockCount,
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<PartyOutstandingReportData> fetchPartyOutstanding(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getPartyOutstanding(query);
      final payload = response.data;
      return PartyOutstandingReportData(
        rows: payload.rows.map(ReportMapper.toPartyModel).toList(),
        totalReceivable: _amount(payload.summary.totalReceivable),
        receivablePartyCount: payload.summary.receivablePartyCount,
        totalPayable: _amount(payload.summary.totalPayable),
        payablePartyCount: payload.summary.payablePartyCount,
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<PartyStatementReportData> fetchPartyStatement(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getPartyStatement(query);
      return PartyStatementReportData(
        entries: payload.entries.map(ReportMapper.toPartyStatementEntry).toList(),
        summary: ReportMapper.toPartyStatementSummary(payload.summary),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<DayBookReportData> fetchDayBook(ReportQuery query) async {
    try {
      final payload = await _repository.getDayBook(query);
      return DayBookReportData(
        rows: payload.rows.map(ReportMapper.toTransactionRow).toList(),
        totalMoneyIn: _amount(payload.totalMoneyIn),
        totalMoneyOut: _amount(payload.totalMoneyOut),
        netTotal: _amount(payload.netTotal),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<AllTransactionsReportData> fetchAllTransactions(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getAllTransactions(query);
      final payload = response.data;
      return AllTransactionsReportData(
        rows: payload.rows.map(ReportMapper.toTransactionRow).toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<ProfitLossReportData> fetchProfitLoss(ReportQuery query) async {
    try {
      final payload = await _repository.getProfitLoss(query);
      return ProfitLossReportData(
        items: payload.items.map(ReportMapper.toProfitLossItem).toList(),
        netProfit: _amount(payload.netProfit),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<TrialBalanceReportData> fetchTrialBalance(ReportQuery query) async {
    try {
      final payload = await _repository.getTrialBalance(query);
      return TrialBalanceReportData(
        rows: payload.rows.map(ReportMapper.toTrialBalanceRow).toList(),
        totalDebit: _amount(payload.totalDebit),
        totalCredit: _amount(payload.totalCredit),
        isBalanced: payload.isBalanced,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<BalanceSheetReportData> fetchBalanceSheet(ReportQuery query) async {
    try {
      final payload = await _repository.getBalanceSheet(query);
      return BalanceSheetReportData(
        assets: payload.assets.map(ReportMapper.toBalanceSheetItem).toList(),
        liabilities:
            payload.liabilities.map(ReportMapper.toBalanceSheetItem).toList(),
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
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<GstrReportData> fetchGstr1(ReportQuery query) async {
    try {
      final payload = await _repository.getGstr1(query);
      return GstrReportData(
        rows: payload.rows.map(ReportMapper.toGstrRow).toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<GstrReportData> fetchGstr2(ReportQuery query) async {
    try {
      final payload = await _repository.getGstr2(query);
      return GstrReportData(
        rows: payload.rows.map(ReportMapper.toGstrRow).toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<Gstr3bReportData> fetchGstr3b(ReportQuery query) async {
    try {
      final payload = await _repository.getGstr3b(query);
      return Gstr3bReportData(
        rows: payload.rows.map(ReportMapper.toGstr3bRow).toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<BillWiseProfitReportData> fetchBillWiseProfit(ReportQuery query) async {
    try {
      final response = await _repository.getBillWiseProfit(query);
      return BillWiseProfitReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toBillWiseProfitRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<CashFlowReportData> fetchCashFlow(ReportQuery query) async {
    try {
      final payload = await _repository.getCashFlow(query);
      return CashFlowReportData(
        rows: payload.rows.map(ReportMapper.toTransactionRow).toList(),
        openingBalance: _amount(payload.openingBalance),
        closingBalance: _amount(payload.closingBalance),
        totalMoneyIn: _amount(payload.totalMoneyIn),
        totalMoneyOut: _amount(payload.totalMoneyOut),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<PartyWiseProfitLossReportData> fetchPartyWiseProfitLoss(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getPartyWiseProfitLoss(query);
      return PartyWiseProfitLossReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toPartyWiseProfitLossRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<PartyReportByItemReportData> fetchPartyReportByItem(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getPartyReportByItem(query);
      return PartyReportByItemReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toPartyByItemRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<SalePurchaseByPartyReportData> fetchSalePurchaseByParty(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getSalePurchaseByParty(query);
      return SalePurchaseByPartyReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toSalePurchaseByPartyRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<SalePurchaseByPartyGroupReportData> fetchSalePurchaseByPartyGroup(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getSalePurchaseByPartyGroup(query);
      return SalePurchaseByPartyGroupReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toSalePurchaseByPartyGroupRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<Gstr9ReportData> fetchGstr9(ReportQuery query) async {
    try {
      final payload = await _repository.getGstr9(query);
      return Gstr9ReportData(
        rows: payload.rows.map(ReportExtendedMapper.toGstr9SupplyRow).toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<SaleSummaryByHsnReportData> fetchSaleSummaryByHsn(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getSaleSummaryByHsn(query);
      return SaleSummaryByHsnReportData(
        rows: payload.rows.map(ReportExtendedMapper.toHsnRow).toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<SacReportData> fetchSacReport(ReportQuery query) async {
    try {
      final payload = await _repository.getSacReport(query);
      return SacReportData(
        rows: payload.rows.map(ReportExtendedMapper.toSacRow).toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<ItemReportByPartyReportData> fetchItemReportByParty(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getItemReportByParty(query);
      return ItemReportByPartyReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toItemByPartyRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<ItemWiseProfitLossReportData> fetchItemWiseProfitLoss(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getItemWiseProfitLoss(query);
      return ItemWiseProfitLossReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toItemWiseProfitLossRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<StockDetailReportData> fetchStockDetail(ReportQuery query) async {
    try {
      final response = await _repository.getStockDetail(query);
      return StockDetailReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toStockDetailRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<ItemDetailReportData> fetchItemDetail(ReportQuery query) async {
    try {
      final response = await _repository.getItemDetail(query);
      return ItemDetailReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toItemDetailRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<CategoryAmountReportData> fetchSalePurchaseByItemCategory(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getSalePurchaseByItemCategory(query);
      return CategoryAmountReportData(
        rows: payload.rows.map(ReportExtendedMapper.toCategoryAmountRow).toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<CategoryAmountReportData> fetchStockSummaryByItemCategory(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getStockSummaryByItemCategory(query);
      return CategoryAmountReportData(
        rows: payload.rows.map(ReportExtendedMapper.toCategoryAmountRow).toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<CategoryAmountReportData> fetchItemCategoryWiseProfitLoss(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getItemCategoryWiseProfitLoss(query);
      return CategoryAmountReportData(
        rows: payload.rows.map(ReportExtendedMapper.toCategoryAmountRow).toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<ItemWiseDiscountReportData> fetchItemWiseDiscount(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getItemWiseDiscount(query);
      return ItemWiseDiscountReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toItemDiscountRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<ManufacturingReportData> fetchManufacturing(ReportQuery query) async {
    try {
      final response = await _repository.getManufacturing(query);
      return ManufacturingReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toManufacturingRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<ConsumptionReportData> fetchConsumption(ReportQuery query) async {
    try {
      final response = await _repository.getConsumption(query);
      return ConsumptionReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toConsumptionRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<StockTransferReportData> fetchStockTransfer(ReportQuery query) async {
    try {
      final response = await _repository.getStockTransfer(query);
      return StockTransferReportData(
        rows: response.data.rows
            .map(ReportExtendedMapper.toStockTransferRow)
            .toList(),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<BankStatementReportData> fetchBankStatement(ReportQuery query) async {
    try {
      final payload = await _repository.getBankStatement(query);
      return BankStatementReportData(
        rows: payload.rows.map(ReportExtendedMapper.toBankStatementRow).toList(),
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
      return ExpensesReportData(
        rows: response.data.rows.map(ReportExtendedMapper.toExpenseRow).toList(),
        totalAmount: _amount(response.data.totalAmount),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<ExpenseByCategoryReportData> fetchExpenseByCategory(
    ReportQuery query,
  ) async {
    try {
      final payload = await _repository.getExpenseByCategory(query);
      return ExpenseByCategoryReportData(
        rows: payload.rows
            .map(ReportExtendedMapper.toExpenseCategoryRow)
            .toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<ExpenseByItemReportData> fetchExpenseByItem(ReportQuery query) async {
    try {
      final payload = await _repository.getExpenseByItem(query);
      return ExpenseByItemReportData(
        rows: payload.rows.map(ReportExtendedMapper.toExpenseItemRow).toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  Future<SalePurchaseOrdersReportData> fetchSalePurchaseOrders(
    ReportQuery query,
  ) async {
    try {
      final response = await _repository.getSalePurchaseOrders(query);
      return SalePurchaseOrdersReportData(
        rows: response.data.rows.map(ReportExtendedMapper.toOrderRow).toList(),
        totalAmount: _amount(response.data.totalAmount),
        meta: response.meta,
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
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
        rows: payload.rows.map(ReportExtendedMapper.toLoanStatementRow).toList(),
      );
    } on DioException catch (error) {
      throw mapReportsError(error);
    }
  }

  double _amount(String value) => double.tryParse(value) ?? 0;
}
