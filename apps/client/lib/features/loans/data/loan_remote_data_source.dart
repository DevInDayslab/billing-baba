import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/loans/models/loan_models.dart';
import 'package:dio/dio.dart';

class LoanRemoteDataSource {
  LoanRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<LoanAccountDto>> listAccounts({int limit = 100}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.loanAccounts,
      queryParameters: {'page': 1, 'limit': limit},
    );
    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => LoanAccountDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LoanAccountDto> getAccount(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.loanAccount(id),
    );
    return LoanAccountDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<LoanAccountDto> createAccount(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.loanAccounts,
      data: body,
    );
    return LoanAccountDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<LoanAccountDto> updateAccount(
    String id,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.loanAccount(id),
      data: body,
    );
    return LoanAccountDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteAccount(String id) async {
    await _dio.delete<void>(ApiEndpoints.loanAccount(id));
  }

  Future<List<LoanTransactionDto>> listTransactions({
    required String loanAccountId,
    int limit = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.loanTransactions,
      queryParameters: {
        'page': 1,
        'limit': limit,
        'loan_account_id': loanAccountId,
      },
    );
    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => LoanTransactionDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LoanTransactionDto> createTransaction(
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.loanTransactions,
      data: body,
    );
    return LoanTransactionDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<LoanTransactionDto> updateTransaction(
    String id,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.loanTransaction(id),
      data: body,
    );
    return LoanTransactionDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteTransaction(String id) async {
    await _dio.delete<void>(ApiEndpoints.loanTransaction(id));
  }
}
