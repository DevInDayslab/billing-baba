import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/parties/models/create_party_request.dart';
import 'package:billing_baba/features/parties/models/delete_status_dto.dart';
import 'package:billing_baba/features/parties/models/party_dto.dart';
import 'package:billing_baba/features/parties/models/party_list_query.dart';
import 'package:dio/dio.dart';

class PartyRepository {
  PartyRepository(this._dio);

  final Dio _dio;

  Future<PaginatedPartiesDto> listParties(PartyListQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.parties,
      queryParameters: query.toQueryParameters(),
    );
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid parties list response',
      );
    }
    return PaginatedPartiesDto.fromJson(data);
  }

  Future<PartyDto> getParty(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.party(id),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid party response',
      );
    }
    return PartyDto.fromJson(data);
  }

  Future<PartyDto> createParty(CreatePartyRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.parties,
      data: request.toJson(),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid create party response',
      );
    }
    return PartyDto.fromJson(data);
  }

  Future<PartyDto> updateParty(String id, UpdatePartyRequest request) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.party(id),
      data: request.toJson(),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid update party response',
      );
    }
    return PartyDto.fromJson(data);
  }

  Future<PartyDeleteAction> deleteParty(String id) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      ApiEndpoints.party(id),
      options: Options(
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    final data = response.data?['data'];
    if (data is Map<String, dynamic>) {
      return PartyDeleteResultDto.fromJson(data).action;
    }
    return PartyDeleteAction.deleted;
  }
}
