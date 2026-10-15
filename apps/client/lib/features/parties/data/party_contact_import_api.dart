import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/parties/models/party_contact_import_models.dart';
import 'package:dio/dio.dart';

class PartyContactImportApi {
  PartyContactImportApi(this._dio);

  final Dio _dio;

  Future<PartyContactImportSessionCreated> createSession() async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.partyContactImportSessions,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid contact import session response',
      );
    }
    return PartyContactImportSessionCreated.fromJson(data);
  }

  Future<PartyContactImportSession> getSession(
    String sessionId, {
    bool includeStaging = false,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.partyContactImportSession(sessionId),
      queryParameters: includeStaging ? {'include_staging': 'true'} : null,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid contact import session response',
      );
    }
    return PartyContactImportSession.fromJson(data);
  }

  Future<PartyContactImportSession> getSessionByToken(String token) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.partyContactImportSessionByToken(token),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid contact import session response',
      );
    }
    return PartyContactImportSession.fromJson(data);
  }

  Future<PartyContactImportSession> submitStaging(
    String token,
    List<PartyContactImportStagingRowDto> contacts,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.partyContactImportStagingByToken(token),
      data: {
        'contacts': contacts.map((c) => c.toJson()).toList(),
      },
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid contact import staging response',
      );
    }
    return PartyContactImportSession.fromJson(data);
  }

  Future<void> commitSession(String sessionId) async {
    await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.partyContactImportSessionCommit(sessionId),
    );
  }

  Future<void> cancelSession(String sessionId) async {
    await _dio.delete<Map<String, dynamic>>(
      ApiEndpoints.partyContactImportSession(sessionId),
    );
  }
}
