import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/crm/domain/models/contact.dart';
import 'package:billing_baba/features/crm/domain/models/contact_activity.dart';
import 'package:dio/dio.dart';

/// REST API calls for contacts — used by the sync engine, not normal CRUD reads.
class ContactRemoteSource {
  ContactRemoteSource(this._dio);

  final Dio _dio;

  Future<List<Contact>> listContacts({
    String? search,
    String? accountName,
    String? assignedTo,
    String? from,
    String? to,
    int page = 1,
    int limit = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.crmContacts,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'q': search,
        if (accountName != null) 'account_name': accountName,
        if (assignedTo != null) 'assigned_to': assignedTo,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        'page': page,
        'limit': limit,
      },
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(Contact.fromJson).toList();
  }

  Future<Contact> getContact(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.crmContact(id),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid contact response',
      );
    }
    return Contact.fromJson(data);
  }

  Future<Contact> createContact(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.crmContacts,
      data: body,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid create contact response',
      );
    }
    return Contact.fromJson(data);
  }

  Future<Contact> updateContact(String id, Map<String, dynamic> body) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.crmContact(id),
      data: body,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid update contact response',
      );
    }
    return Contact.fromJson(data);
  }

  Future<void> deleteContact(String id) async {
    await _dio.delete<void>(ApiEndpoints.crmContact(id));
  }

  Future<ContactActivity> addActivity(
    String contactId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.crmContactActivities(contactId),
      data: body,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid contact activity response',
      );
    }
    return ContactActivity.fromJson(data);
  }
}
