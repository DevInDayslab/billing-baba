import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/parties/models/delete_status_dto.dart';
import 'package:dio/dio.dart';

class PartyDeleteStatusRepository {
  PartyDeleteStatusRepository(this._dio);

  final Dio _dio;

  Future<DeleteStatusDto> getDeleteStatus(String partyId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.partyDeleteStatus(partyId),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid party delete status response',
      );
    }
    return DeleteStatusDto.fromJson(data);
  }
}
