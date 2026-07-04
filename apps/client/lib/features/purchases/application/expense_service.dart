import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/data/expense_remote_data_source.dart';
import 'package:billing_baba/features/purchases/data/expense_repository.dart';
import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
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
      return response.categories
          .map(
            (dto) => ExpenseCategoryModel(
              id: dto.id,
              name: dto.name,
              type: ExpenseCategoryType.direct,
              variant: ExpenseCategoryVariant.standard,
              totalAmount: 0,
              balance: 0,
            ),
          )
          .toList();
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
      return response.expenses
          .map(
            (dto) => ExpenseTransactionModel(
              id: dto.id,
              categoryId: dto.categoryId,
              date: DateTime.tryParse(dto.expenseDate) ?? DateTime.now(),
              transactionNo: dto.id.substring(0, 8),
              party: '',
              paymentType: dto.paymentMode,
              amount: double.tryParse(dto.amount) ?? 0,
              balance: 0,
              status: ExpenseStatus.paid,
            ),
          )
          .toList();
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

  Future<ExpenseCategoryDto> createCategory(
    CreateExpenseCategoryRequest request,
  ) async {
    try {
      return _repository.createCategory(request);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }
}
