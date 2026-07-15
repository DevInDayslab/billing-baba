import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';
import 'package:dio/dio.dart';

/// REST API calls for deals — used by the sync engine, not normal CRUD reads.
class DealRemoteSource {
  DealRemoteSource(this._dio);

  final Dio _dio;

  Future<List<Deal>> listDeals({
    String? search,
    String? accountName,
    String? assignedTo,
    String? stage,
    String? from,
    String? to,
    int page = 1,
    int limit = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.crmDeals,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'q': search,
        if (accountName != null) 'account_name': accountName,
        if (assignedTo != null) 'assigned_to': assignedTo,
        if (stage != null) 'stage': stage,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        'page': page,
        'limit': limit,
      },
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(Deal.fromJson).toList();
  }

  Future<Deal> getDeal(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.crmDeal(id),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid deal response',
      );
    }
    return Deal.fromJson(data);
  }

  Future<Deal> createDeal(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.crmDeals,
      data: body,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid create deal response',
      );
    }
    return Deal.fromJson(data);
  }

  Future<Deal> updateDeal(String id, Map<String, dynamic> body) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.crmDeal(id),
      data: body,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid update deal response',
      );
    }
    return Deal.fromJson(data);
  }

  Future<void> deleteDeal(String id) async {
    await _dio.delete<void>(ApiEndpoints.crmDeal(id));
  }
}
