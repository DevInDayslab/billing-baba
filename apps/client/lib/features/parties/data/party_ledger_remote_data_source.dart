import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/parties/models/dto/party_ledger_dto.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:dio/dio.dart';

class PartyLedgerRemoteDataSource {
  PartyLedgerRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PartyLedgerDto> getPartyLedger(
    String partyId, {
    PartyLedgerFilter filter = PartyLedgerFilter.all,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.partyLedger(partyId),
      queryParameters: {'filter': filter.apiValue},
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid party ledger response',
      );
    }
    return PartyLedgerDto.fromJson(data);
  }
}
