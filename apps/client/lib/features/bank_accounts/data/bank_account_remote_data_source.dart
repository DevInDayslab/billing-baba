import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/bank_accounts/models/bank_account_models.dart';
import 'package:dio/dio.dart';

class BankAccountRemoteDataSource {
  BankAccountRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<BankAccountDto>> listAccounts() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.bankAccounts,
    );
    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => BankAccountDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BankAccountBalanceDto>> listBalances() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.bankAccountBalances,
    );
    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => BankAccountBalanceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BankAccountDto> createBank(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.bankAccounts,
      data: body,
    );
    return BankAccountDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<BankAccountDto> updateBank(String id, Map<String, dynamic> body) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.bankAccounts}/$id',
      data: body,
    );
    return BankAccountDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> createTransfer(Map<String, dynamic> body) async {
    await _dio.post(ApiEndpoints.accountTransfers, data: body);
  }

  Future<void> createAdjustment(Map<String, dynamic> body) async {
    await _dio.post(ApiEndpoints.accountAdjustments, data: body);
  }
}
