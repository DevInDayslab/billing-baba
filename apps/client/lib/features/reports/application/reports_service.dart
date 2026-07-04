import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/application/reports_error_mapper.dart';
import 'package:billing_baba/features/reports/data/reports_remote_data_source.dart';
import 'package:billing_baba/features/reports/data/reports_repository.dart';
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

class GstrReportData {
  const GstrReportData({required this.rows});

  final List<ReportGstrRow> rows;
}

class Gstr3bReportData {
  const Gstr3bReportData({required this.rows});

  final List<ReportGstr3bRow> rows;
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

  double _amount(String value) => double.tryParse(value) ?? 0;
}
