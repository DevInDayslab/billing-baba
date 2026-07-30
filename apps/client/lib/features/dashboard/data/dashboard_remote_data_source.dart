import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/dashboard/models/dto/dashboard_dto.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:dio/dio.dart';

class DashboardFetchResult {
  const DashboardFetchResult({
    required this.dto,
    required this.rawPayload,
  });

  final DashboardDto dto;
  final Map<String, dynamic> rawPayload;
}

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._dio);

  final Dio _dio;

  Future<DashboardFetchResult> getDashboard(DashboardQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.dashboard,
      queryParameters: query.toQueryParameters(),
    );

    final raw =
        (response.data?['data'] as Map<String, dynamic>?) ??
        <String, dynamic>{};
    return DashboardFetchResult(
      dto: DashboardDto.fromJson(raw),
      rawPayload: raw,
    );
  }
}
