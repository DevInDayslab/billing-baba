import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/reports/models/dto/report_dto.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:dio/dio.dart';

class ReportsRemoteDataSource {
  ReportsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedReportResponse<SaleReportPayloadDto>> getSaleReport(
    ReportQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsSales,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(
      response.data ?? {},
      SaleReportPayloadDto.fromJson,
    );
  }

  Future<PaginatedReportResponse<PurchaseReportPayloadDto>> getPurchaseReport(
    ReportQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsPurchases,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(
      response.data ?? {},
      PurchaseReportPayloadDto.fromJson,
    );
  }

  Future<PaginatedReportResponse<StockSummaryPayloadDto>> getStockSummary(
    ReportQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsStockSummary,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(
      response.data ?? {},
      StockSummaryPayloadDto.fromJson,
    );
  }

  Future<PaginatedReportResponse<LowStockPayloadDto>> getLowStock(
    ReportQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsLowStock,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(response.data ?? {}, LowStockPayloadDto.fromJson);
  }

  Future<PaginatedReportResponse<PartyOutstandingPayloadDto>>
  getPartyOutstanding(ReportQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsPartyOutstanding,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(
      response.data ?? {},
      PartyOutstandingPayloadDto.fromJson,
    );
  }

  Future<PartyStatementPayloadDto> getPartyStatement(ReportQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsPartyStatement,
      queryParameters: query.toQueryParameters(),
    );
    return PartyStatementPayloadDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<DayBookPayloadDto> getDayBook(ReportQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsDayBook,
      queryParameters: query.toQueryParameters(),
    );
    return DayBookPayloadDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<PaginatedReportResponse<AllTransactionsPayloadDto>> getAllTransactions(
    ReportQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsAllTransactions,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(
      response.data ?? {},
      AllTransactionsPayloadDto.fromJson,
    );
  }

  Future<ProfitLossPayloadDto> getProfitLoss(ReportQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsProfitLoss,
      queryParameters: query.toQueryParameters(),
    );
    return ProfitLossPayloadDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<GstrReportPayloadDto> getGstr1(ReportQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsGstr1,
      queryParameters: query.toQueryParameters(),
    );
    return GstrReportPayloadDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<GstrReportPayloadDto> getGstr2(ReportQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsGstr2,
      queryParameters: query.toQueryParameters(),
    );
    return GstrReportPayloadDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<Gstr3bPayloadDto> getGstr3b(ReportQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.reportsGstr3b,
      queryParameters: query.toQueryParameters(),
    );
    return Gstr3bPayloadDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
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
