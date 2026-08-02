import 'package:billing_baba/features/purchases/data/expense_master_repository.dart';
import 'package:billing_baba/features/purchases/data/expense_remote_data_source.dart';
import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';

class ExpenseRepository {
  ExpenseRepository({
    required ExpenseRemoteDataSource remote,
    ExpenseMasterRepository? master,
  }) : _remote = remote,
       _master = master;

  final ExpenseRemoteDataSource _remote;
  final ExpenseMasterRepository? _master;

  Future<PaginatedExpensesDto> listExpenses(ExpenseListQuery query) =>
      _master?.listExpenses(query) ?? _remote.listExpenses(query);

  Future<ExpenseDto> getExpense(String id) =>
      _master?.getExpense(id) ?? _remote.getExpense(id);

  Future<ExpenseDto> createExpense(CreateExpenseRequest request) =>
      _master?.createExpense(request) ?? _remote.createExpense(request);

  Future<ExpenseDto> updateExpense(String id, UpdateExpenseRequest request) =>
      _master?.updateExpense(id, request) ?? _remote.updateExpense(id, request);

  Future<void> deleteExpense(String id) =>
      _master?.deleteExpense(id) ?? _remote.deleteExpense(id);

  Future<PaginatedExpenseCategoriesDto> listCategories({
    int page = 1,
    int limit = 100,
  }) =>
      _master?.listCategories(page: page, limit: limit) ??
      _remote.listCategories(page: page, limit: limit);

  Future<ExpenseCategoryDto> getCategory(String id) =>
      _master?.getCategory(id) ?? _remote.getCategory(id);

  Future<ExpenseCategoryDto> createCategory(
    CreateExpenseCategoryRequest request,
  ) => _master?.createCategory(request) ?? _remote.createCategory(request);

  Future<ExpenseCategoryDto> updateCategory(
    String id,
    UpdateExpenseCategoryRequest request,
  ) =>
      _master?.updateCategory(id, request) ??
      _remote.updateCategory(id, request);

  Future<void> deleteCategory(String id) =>
      _master?.deleteCategory(id) ?? _remote.deleteCategory(id);
}
