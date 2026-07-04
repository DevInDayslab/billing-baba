import 'package:billing_baba/features/purchases/data/expense_remote_data_source.dart';
import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';

class ExpenseRepository {
  ExpenseRepository({required ExpenseRemoteDataSource remote}) : _remote = remote;

  final ExpenseRemoteDataSource _remote;

  Future<PaginatedExpensesDto> listExpenses(ExpenseListQuery query) =>
      _remote.listExpenses(query);

  Future<ExpenseDto> getExpense(String id) => _remote.getExpense(id);

  Future<ExpenseDto> createExpense(CreateExpenseRequest request) =>
      _remote.createExpense(request);

  Future<ExpenseDto> updateExpense(String id, UpdateExpenseRequest request) =>
      _remote.updateExpense(id, request);

  Future<void> deleteExpense(String id) => _remote.deleteExpense(id);

  Future<PaginatedExpenseCategoriesDto> listCategories({
    int page = 1,
    int limit = 100,
  }) => _remote.listCategories(page: page, limit: limit);

  Future<ExpenseCategoryDto> getCategory(String id) => _remote.getCategory(id);

  Future<ExpenseCategoryDto> createCategory(
    CreateExpenseCategoryRequest request,
  ) => _remote.createCategory(request);

  Future<ExpenseCategoryDto> updateCategory(
    String id,
    UpdateExpenseCategoryRequest request,
  ) => _remote.updateCategory(id, request);

  Future<void> deleteCategory(String id) => _remote.deleteCategory(id);
}
