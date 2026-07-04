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

  Future<GstrReportPayloadDto> getGstr1(ReportQuery query) =>
      _remote.getGstr1(query);

  Future<GstrReportPayloadDto> getGstr2(ReportQuery query) =>
      _remote.getGstr2(query);

  Future<Gstr3bPayloadDto> getGstr3b(ReportQuery query) =>
      _remote.getGstr3b(query);
}
