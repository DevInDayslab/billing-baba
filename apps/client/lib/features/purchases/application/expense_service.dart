import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/data/expense_remote_data_source.dart';
import 'package:billing_baba/features/purchases/data/expense_repository.dart';
import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/models/mappers/expense_mapper.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_service.g.dart';

@Riverpod(keepAlive: true)
Future<ExpenseService> expenseService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return ExpenseService(
    repository: ExpenseRepository(
      remote: ExpenseRemoteDataSource(api.dio),
    ),
  );
}

class ExpenseService {
  ExpenseService({required this._repository});

  final ExpenseRepository _repository;

  Future<List<ExpenseCategoryModel>> fetchCategories() async {
    try {
      final response = await _repository.listCategories();
      return response.categories.map(ExpenseMapper.toCategoryModel).toList();
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<ExpenseCategoryModel> getCategory(String id) async {
    try {
      final dto = await _repository.getCategory(id);
      return ExpenseMapper.toCategoryModel(dto);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<List<ExpenseTransactionModel>> fetchExpenses({
    ExpenseListQuery? query,
  }) async {
    try {
      final response = await _repository.listExpenses(
        query ?? const ExpenseListQuery(limit: 100),
      );
      return ExpenseMapper.toTransactionModels(response.expenses);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<ExpenseDto> fetchExpenseDto(String id) async {
    try {
      return await _repository.getExpense(id);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<ExpenseTransactionModel> fetchExpense(String id) async {
    try {
      final dto = await _repository.getExpense(id);
      return ExpenseMapper.toTransactionModel(dto);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<ExpenseDto> createExpense(CreateExpenseRequest request) async {
    try {
      return _repository.createExpense(request);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<ExpenseDto> updateExpense(
    String id,
    UpdateExpenseRequest request,
  ) async {
    try {
      return _repository.updateExpense(id, request);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<ExpenseCategoryDto> createCategory(
    CreateExpenseCategoryRequest request,
  ) async {
    try {
      return _repository.createCategory(request);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<ExpenseCategoryDto> updateCategory(
    String id,
    UpdateExpenseCategoryRequest request,
  ) async {
    try {
      return _repository.updateCategory(id, request);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }
}
