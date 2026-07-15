import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/crm/domain/models/lead_activity.dart';
import 'package:dio/dio.dart';

/// REST API calls for leads — used by the sync engine, not normal CRUD reads.
class LeadRemoteSource {
  LeadRemoteSource(this._dio);

  final Dio _dio;

  Future<List<Lead>> listLeads({
    String? search,
    LeadStatus? status,
    LeadSource? leadSource,
    String? from,
    String? to,
    int page = 1,
    int limit = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.crmLeads,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'q': search,
        if (status != null) 'status': status.wireValue,
        if (leadSource != null) 'lead_source': leadSource.wireValue,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        'page': page,
        'limit': limit,
      },
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(Lead.fromJson).toList();
  }

  Future<Lead> getLead(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.crmLead(id),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid lead response',
      );
    }
    return Lead.fromJson(data);
  }

  Future<Lead> createLead(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.crmLeads,
      data: body,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid create lead response',
      );
    }
    return Lead.fromJson(data);
  }

  Future<Lead> updateLead(String id, Map<String, dynamic> body) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.crmLead(id),
      data: body,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid update lead response',
      );
    }
    return Lead.fromJson(data);
  }

  Future<void> deleteLead(String id) async {
    await _dio.delete<void>(ApiEndpoints.crmLead(id));
  }

  Future<LeadActivity> addActivity(
    String leadId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.crmLeadActivities(leadId),
      data: body,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid lead activity response',
      );
    }
    return LeadActivity.fromJson(data);
  }
}
