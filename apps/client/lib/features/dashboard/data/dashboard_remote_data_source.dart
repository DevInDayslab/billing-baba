import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/dashboard/models/dto/dashboard_dto.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:dio/dio.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._dio);

  final Dio _dio;

  Future<DashboardDto> getDashboard(DashboardQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.dashboard,
      queryParameters: query.toQueryParameters(),
    );

    return DashboardDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }
}
