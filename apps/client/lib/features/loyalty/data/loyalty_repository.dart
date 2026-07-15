import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/loyalty/models/loyalty_dto.dart';
import 'package:dio/dio.dart';

class LoyaltyRepository {
  LoyaltyRepository(this._dio);

  final Dio _dio;

  Future<PartyLoyaltyBalanceDto> getPartyBalance(String partyId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.partyLoyalty(partyId),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid loyalty balance response',
      );
    }
    return PartyLoyaltyBalanceDto.fromJson(data);
  }
}
