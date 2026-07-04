import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/sales/models/dto/job_work_order_dto.dart';
import 'package:billing_baba/features/sales/models/requests/job_work_requests.dart';
import 'package:dio/dio.dart';

class JobWorkRemoteDataSource {
  JobWorkRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedJobWorkOrdersDto> listOrders(
    JobWorkOrderListQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.jobWorkOrders,
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedJobWorkOrdersDto.fromJson(response.data ?? {});
  }

  Future<JobWorkOrderDto> getOrder(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.jobWorkOrder(id),
    );
    return JobWorkOrderDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<JobWorkOrderDto> createOrder(CreateJobWorkOrderRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.jobWorkOrders,
      data: request.toJson(),
    );
    return JobWorkOrderDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<JobWorkOrderDto> updateOrder(
    String id,
    UpdateJobWorkOrderRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.jobWorkOrder(id),
      data: request.toJson(),
    );
    return JobWorkOrderDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteOrder(String id) async {
    await _dio.delete<void>(ApiEndpoints.jobWorkOrder(id));
  }
}
