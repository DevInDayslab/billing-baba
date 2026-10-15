import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/other_income/data/other_income_local_data_source.dart';
import 'package:billing_baba/features/other_income/data/other_income_master_repository.dart';
import 'package:billing_baba/features/other_income/data/other_income_remote_data_source.dart';
import 'package:billing_baba/features/other_income/data/other_income_repository.dart';
import 'package:billing_baba/features/other_income/models/dto/other_income_dto.dart';
import 'package:billing_baba/features/other_income/models/other_income_model.dart';
import 'package:billing_baba/features/other_income/models/mappers/other_income_mapper.dart';
import 'package:billing_baba/features/other_income/models/requests/other_income_requests.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'other_income_service.g.dart';

@Riverpod(keepAlive: true)
Future<OtherIncomeService> otherIncomeService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final storage = await ref.watch(storageServiceProvider.future);
  final db = ref.watch(appDatabaseProvider);
  final queue = ref.watch(syncQueueProvider);
  String? deviceId;
  try {
    final identity = await ref.watch(syncDeviceIdentityProvider.future);
    deviceId = await identity.deviceId();
  } on Object {
    deviceId = null;
  }
  final remote = OtherIncomeRemoteDataSource(api.dio);
  final businessIdReader = () =>
      storage.read(StorageKeys.lastOpenedBusinessId) ?? '';
  return OtherIncomeService(
    repository: OtherIncomeRepository(
      remote: remote,
      master: OtherIncomeMasterRepository(
        local: OtherIncomeLocalDataSource(db),
        remote: remote,
        syncQueue: queue,
        businessIdReader: businessIdReader,
        deviceIdReader: () => deviceId,
      ),
    ),
  );
}

class OtherIncomeService {
  OtherIncomeService({required this._repository});

  final OtherIncomeRepository _repository;

  Future<List<IncomeCategoryModel>> fetchCategories() async {
    try {
      final response = await _repository.listCategories();
      return response.categories.map(OtherIncomeMapper.toCategoryModel).toList();
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<IncomeCategoryModel> getCategory(String id) async {
    try {
      final dto = await _repository.getCategory(id);
      return OtherIncomeMapper.toCategoryModel(dto);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<List<OtherIncomeTransactionModel>> fetchOtherIncomes({
    OtherIncomeListQuery? query,
  }) async {
    try {
      final response = await _repository.listOtherIncomes(
        query ?? const OtherIncomeListQuery(limit: 100),
      );
      return OtherIncomeMapper.toTransactionModels(response.incomes);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<OtherIncomeDto> fetchOtherIncomeDto(String id) async {
    try {
      return await _repository.getOtherIncome(id);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<OtherIncomeTransactionModel> fetchOtherIncome(String id) async {
    try {
      final dto = await _repository.getOtherIncome(id);
      return OtherIncomeMapper.toTransactionModel(dto);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<OtherIncomeDto> createOtherIncome(CreateOtherIncomeRequest request) async {
    try {
      return _repository.createOtherIncome(request);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<OtherIncomeDto> updateOtherIncome(
    String id,
    UpdateOtherIncomeRequest request,
  ) async {
    try {
      return _repository.updateOtherIncome(id, request);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<void> deleteOtherIncome(String id) async {
    try {
      await _repository.deleteOtherIncome(id);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<IncomeCategoryDto> createCategory(
    CreateIncomeCategoryRequest request,
  ) async {
    try {
      return _repository.createCategory(request);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<IncomeCategoryDto> updateCategory(
    String id,
    UpdateIncomeCategoryRequest request,
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

  Future<List<IncomeCatalogItemModel>> fetchIncomeCatalogItems() async {
    try {
      final response = await _repository.listIncomeItems(limit: 500);
      return response.items.map(OtherIncomeMapper.toCatalogItemModel).toList();
    } on DioException {
      // Offline-first: listIncomeItems should still return local rows when
      // hydration fails; if the call still errors, treat as empty catalog.
      return const [];
    } on Object {
      return const [];
    }
  }

  Future<IncomeCatalogItemModel> createOtherIncomeCatalogItem(
    CreateIncomeItemRequest request,
  ) async {
    try {
      final dto = await _repository.createOtherIncomeItem(request);
      return OtherIncomeMapper.toCatalogItemModel(dto);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }
}
