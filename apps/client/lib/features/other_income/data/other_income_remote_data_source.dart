import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/other_income/models/dto/other_income_dto.dart';
import 'package:billing_baba/features/other_income/models/requests/other_income_requests.dart';
import 'package:dio/dio.dart';

class OtherIncomeRemoteDataSource {
  OtherIncomeRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedOtherIncomesDto> listOtherIncomes(OtherIncomeListQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.otherIncomes,
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedOtherIncomesDto.fromJson(response.data ?? {});
  }

  Future<OtherIncomeDto> getOtherIncome(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.otherIncome(id),
    );
    return OtherIncomeDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<OtherIncomeDto> createOtherIncome(CreateOtherIncomeRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.otherIncomes,
      data: request.toJson(),
    );
    return OtherIncomeDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<OtherIncomeDto> updateOtherIncome(
    String id,
    UpdateOtherIncomeRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.otherIncome(id),
      data: request.toJson(),
    );
    return OtherIncomeDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteOtherIncome(String id) async {
    await _dio.delete<void>(ApiEndpoints.otherIncome(id));
  }

  Future<PaginatedIncomeCategoriesDto> listCategories({
    int page = 1,
    int limit = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.incomeCategories,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedIncomeCategoriesDto.fromJson(response.data ?? {});
  }

  Future<IncomeCategoryDto> getCategory(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.incomeCategory(id),
    );
    return IncomeCategoryDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<IncomeCategoryDto> createCategory(
    CreateIncomeCategoryRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.incomeCategories,
      data: request.toJson(),
    );
    return IncomeCategoryDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<IncomeCategoryDto> updateCategory(
    String id,
    UpdateIncomeCategoryRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.incomeCategory(id),
      data: request.toJson(),
    );
    return IncomeCategoryDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteCategory(String id) async {
    await _dio.delete<void>(ApiEndpoints.incomeCategory(id));
  }

  Future<PaginatedIncomeItemsDto> listIncomeItems({
    int page = 1,
    int limit = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.incomeItems,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedIncomeItemsDto.fromJson(response.data ?? {});
  }

  Future<IncomeItemDto> getOtherIncomeItem(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.incomeItem(id),
    );
    return IncomeItemDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<IncomeItemDto> createOtherIncomeItem(
    CreateIncomeItemRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.incomeItems,
      data: request.toJson(),
    );
    return IncomeItemDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<IncomeItemDto> updateOtherIncomeItem(
    String id,
    UpdateIncomeItemRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.incomeItem(id),
      data: request.toJson(),
    );
    return IncomeItemDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteOtherIncomeItem(String id) async {
    await _dio.delete<void>(ApiEndpoints.incomeItem(id));
  }
}
