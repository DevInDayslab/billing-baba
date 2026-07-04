import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:dio/dio.dart';

class ExpenseRemoteDataSource {
  ExpenseRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedExpensesDto> listExpenses(ExpenseListQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.expenses,
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedExpensesDto.fromJson(response.data ?? {});
  }

  Future<ExpenseDto> getExpense(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.expense(id),
    );
    return ExpenseDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<ExpenseDto> createExpense(CreateExpenseRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.expenses,
      data: request.toJson(),
    );
    return ExpenseDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<ExpenseDto> updateExpense(
    String id,
    UpdateExpenseRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.expense(id),
      data: request.toJson(),
    );
    return ExpenseDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteExpense(String id) async {
    await _dio.delete<void>(ApiEndpoints.expense(id));
  }

  Future<PaginatedExpenseCategoriesDto> listCategories({
    int page = 1,
    int limit = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.expenseCategories,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedExpenseCategoriesDto.fromJson(response.data ?? {});
  }

  Future<ExpenseCategoryDto> getCategory(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.expenseCategory(id),
    );
    return ExpenseCategoryDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<ExpenseCategoryDto> createCategory(
    CreateExpenseCategoryRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.expenseCategories,
      data: request.toJson(),
    );
    return ExpenseCategoryDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<ExpenseCategoryDto> updateCategory(
    String id,
    UpdateExpenseCategoryRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.expenseCategory(id),
      data: request.toJson(),
    );
    return ExpenseCategoryDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteCategory(String id) async {
    await _dio.delete<void>(ApiEndpoints.expenseCategory(id));
  }
}
