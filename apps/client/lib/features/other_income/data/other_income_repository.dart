import 'package:billing_baba/features/other_income/data/other_income_master_repository.dart';
import 'package:billing_baba/features/other_income/data/other_income_remote_data_source.dart';
import 'package:billing_baba/features/other_income/models/dto/other_income_dto.dart';
import 'package:billing_baba/features/other_income/models/requests/other_income_requests.dart';

class OtherIncomeRepository {
  OtherIncomeRepository({
    required OtherIncomeRemoteDataSource remote,
    OtherIncomeMasterRepository? master,
  }) : _remote = remote,
       _master = master;

  final OtherIncomeRemoteDataSource _remote;
  final OtherIncomeMasterRepository? _master;

  Future<PaginatedOtherIncomesDto> listOtherIncomes(OtherIncomeListQuery query) =>
      _master?.listOtherIncomes(query) ?? _remote.listOtherIncomes(query);

  Future<OtherIncomeDto> getOtherIncome(String id) =>
      _master?.getOtherIncome(id) ?? _remote.getOtherIncome(id);

  Future<OtherIncomeDto> createOtherIncome(CreateOtherIncomeRequest request) =>
      _master?.createOtherIncome(request) ?? _remote.createOtherIncome(request);

  Future<OtherIncomeDto> updateOtherIncome(String id, UpdateOtherIncomeRequest request) =>
      _master?.updateOtherIncome(id, request) ?? _remote.updateOtherIncome(id, request);

  Future<void> deleteOtherIncome(String id) =>
      _master?.deleteOtherIncome(id) ?? _remote.deleteOtherIncome(id);

  Future<PaginatedIncomeCategoriesDto> listCategories({
    int page = 1,
    int limit = 100,
  }) =>
      _master?.listCategories(page: page, limit: limit) ??
      _remote.listCategories(page: page, limit: limit);

  Future<IncomeCategoryDto> getCategory(String id) =>
      _master?.getCategory(id) ?? _remote.getCategory(id);

  Future<IncomeCategoryDto> createCategory(
    CreateIncomeCategoryRequest request,
  ) => _master?.createCategory(request) ?? _remote.createCategory(request);

  Future<IncomeCategoryDto> updateCategory(
    String id,
    UpdateIncomeCategoryRequest request,
  ) =>
      _master?.updateCategory(id, request) ??
      _remote.updateCategory(id, request);

  Future<void> deleteCategory(String id) =>
      _master?.deleteCategory(id) ?? _remote.deleteCategory(id);

  Future<PaginatedIncomeItemsDto> listIncomeItems({
    int page = 1,
    int limit = 100,
  }) =>
      _master?.listIncomeItems(page: page, limit: limit) ??
      _remote.listIncomeItems(page: page, limit: limit);

  Future<IncomeItemDto> getOtherIncomeItem(String id) =>
      _master?.getOtherIncomeItem(id) ?? _remote.getOtherIncomeItem(id);

  Future<IncomeItemDto> createOtherIncomeItem(CreateIncomeItemRequest request) =>
      _master?.createOtherIncomeItem(request) ??
      _remote.createOtherIncomeItem(request);

  Future<IncomeItemDto> updateOtherIncomeItem(
    String id,
    UpdateIncomeItemRequest request,
  ) =>
      _master?.updateOtherIncomeItem(id, request) ??
      _remote.updateOtherIncomeItem(id, request);

  Future<void> deleteOtherIncomeItem(String id) =>
      _master?.deleteOtherIncomeItem(id) ?? _remote.deleteOtherIncomeItem(id);
}
