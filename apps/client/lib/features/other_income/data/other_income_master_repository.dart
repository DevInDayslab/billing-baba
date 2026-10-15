import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:billing_baba/features/other_income/data/other_income_local_data_source.dart';
import 'package:billing_baba/features/other_income/data/other_income_remote_data_source.dart';
import 'package:billing_baba/features/other_income/models/dto/other_income_dto.dart';
import 'package:billing_baba/features/other_income/models/requests/other_income_requests.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _otherIncomesEntity = 'other_incomes';
const _incomeCategoriesEntity = 'income_categories';
const _incomeItemsEntity = 'income_items';

class OtherIncomeMasterRepository {
  OtherIncomeMasterRepository({
    required this._local,
    required this._remote,
    required this._syncQueue,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final OtherIncomeLocalDataSource _local;
  final OtherIncomeRemoteDataSource _remote;
  final SyncQueue _syncQueue;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for expense operations');
    }
    return id;
  }

  Future<void> _hydrateIfEmpty(String businessId) async {
    final categories = await _local.listCategories(businessId);
    final items = await _local.listIncomeItems(businessId);
    if (categories.isNotEmpty && items.isNotEmpty) return;
    try {
      if (categories.isEmpty) {
        var page = 1;
        while (true) {
          final response = await _remote.listCategories(page: page, limit: 100);
          for (final dto in response.categories) {
            await _local.upsertCategoryFromDto(businessId, dto);
          }
          if (response.categories.length < 100) break;
          if (page * 100 >= response.meta.total) break;
          page += 1;
        }
      }
      if (items.isEmpty) {
        var page = 1;
        while (true) {
          final response = await _remote.listIncomeItems(page: page, limit: 100);
          for (final dto in response.items) {
            await _local.upsertOtherIncomeItemFromDto(businessId, dto);
          }
          if (response.items.length < 100) break;
          if (page * 100 >= response.meta.total) break;
          page += 1;
        }
      }
    } on Object {
      // Offline.
    }
  }

  Future<PaginatedOtherIncomesDto> listOtherIncomes(OtherIncomeListQuery query) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    final all = await _local.listOtherIncomes(
      businessId,
      categoryId: query.categoryId,
    );
    final start = (query.page - 1) * query.limit;
    final pageItems = start >= all.length
        ? <OtherIncomeDto>[]
        : all.skip(start).take(query.limit).toList();
    return PaginatedOtherIncomesDto(
      incomes: pageItems,
      meta: PaginationMetaDto(
        page: query.page,
        limit: query.limit,
        total: all.length,
      ),
    );
  }

  Future<OtherIncomeDto> getOtherIncome(String id) async {
    final local = await _local.getOtherIncome(id);
    if (local != null) return local;
    final remote = await _remote.getOtherIncome(id);
    await _local.upsertOtherIncomeFromDto(_requireBusinessId(), remote);
    return remote;
  }

  Future<OtherIncomeDto> createOtherIncome(CreateOtherIncomeRequest request) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _local.upsertOtherIncome(
      id: id,
      businessId: businessId,
      categoryId: request.categoryId,
      incomeItemId: request.incomeItemId,
      amount: request.amount,
      incomeDate: request.incomeDate,
      description: request.description,
      notes: request.notes,
      referenceNumber: request.referenceNumber,
      taxAmount: request.taxAmount,
      taxRate: request.taxRate,
      paymentMode: request.paymentMode,
      bankAccountId: request.bankAccountId,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _otherIncomesEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: request.toJson(),
      clientUpdatedAt: now,
    );
    return (await _local.getOtherIncome(id))!;
  }

  Future<OtherIncomeDto> updateOtherIncome(
    String id,
    UpdateOtherIncomeRequest request,
  ) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getOtherIncome(id);
    if (existing == null) {
      return _remote.updateOtherIncome(id, request);
    }
    final now = DateTime.now().toUtc();
    await _local.upsertOtherIncome(
      id: id,
      businessId: businessId,
      categoryId: request.categoryId ?? existing.categoryId,
      incomeItemId: request.incomeItemId ?? existing.incomeItemId,
      amount: request.amount ?? existing.amount,
      incomeDate: request.incomeDate ?? existing.incomeDate,
      description: request.description ?? existing.description,
      notes: request.notes ?? existing.notes,
      referenceNumber: request.referenceNumber ?? existing.referenceNumber,
      taxAmount: request.taxAmount ?? existing.taxAmount,
      taxRate: request.taxRate ?? existing.taxRate,
      paymentMode: request.paymentMode ?? existing.paymentMode,
      bankAccountId: request.bankAccountId ?? existing.bankAccountId,
      syncVersion: 0,
      createdAt: DateTime.tryParse(existing.createdAt)?.toUtc() ?? now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _otherIncomesEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: request.toJson(),
      clientUpdatedAt: now,
    );
    return (await _local.getOtherIncome(id))!;
  }

  Future<void> deleteOtherIncome(String id) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    await _local.softDeleteOtherIncome(id, now);
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _otherIncomesEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      clientUpdatedAt: now,
    );
  }

  Future<PaginatedIncomeCategoriesDto> listCategories({
    int page = 1,
    int limit = 100,
  }) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    final all = await _local.listCategories(businessId);
    final start = (page - 1) * limit;
    final pageItems = start >= all.length
        ? <IncomeCategoryDto>[]
        : all.skip(start).take(limit).toList();
    return PaginatedIncomeCategoriesDto(
      categories: pageItems,
      meta: PaginationMetaDto(page: page, limit: limit, total: all.length),
    );
  }

  Future<IncomeCategoryDto> getCategory(String id) async {
    final local = await _local.getCategory(id);
    if (local != null) return local;
    final remote = await _remote.getCategory(id);
    await _local.upsertCategoryFromDto(_requireBusinessId(), remote);
    return remote;
  }

  Future<IncomeCategoryDto> createCategory(
    CreateIncomeCategoryRequest request,
  ) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _local.upsertCategory(
      id: id,
      businessId: businessId,
      name: request.name.trim(),
      categoryType: request.categoryType,
      isSystem: false,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _incomeCategoriesEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: request.toJson(),
      clientUpdatedAt: now,
    );
    return (await _local.getCategory(id))!;
  }

  Future<IncomeCategoryDto> updateCategory(
    String id,
    UpdateIncomeCategoryRequest request,
  ) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getCategory(id);
    if (existing == null) {
      return _remote.updateCategory(id, request);
    }
    final now = DateTime.now().toUtc();
    final name = request.name?.trim() ?? existing.name;
    await _local.upsertCategory(
      id: id,
      businessId: businessId,
      name: name,
      categoryType: request.categoryType ?? existing.categoryType,
      isSystem: existing.isSystem,
      syncVersion: 0,
      createdAt: DateTime.tryParse(existing.createdAt)?.toUtc() ?? now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _incomeCategoriesEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: request.toJson(),
      clientUpdatedAt: now,
    );
    return (await _local.getCategory(id))!;
  }

  Future<PaginatedIncomeItemsDto> listIncomeItems({
    int page = 1,
    int limit = 100,
  }) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    final all = await _local.listIncomeItems(businessId);
    final start = (page - 1) * limit;
    final pageItems = start >= all.length
        ? <IncomeItemDto>[]
        : all.skip(start).take(limit).toList();
    return PaginatedIncomeItemsDto(
      items: pageItems,
      meta: PaginationMetaDto(page: page, limit: limit, total: all.length),
    );
  }

  Future<IncomeItemDto> getOtherIncomeItem(String id) async {
    final local = await _local.getIncomeItem(id);
    if (local != null) return local;
    final remote = await _remote.getOtherIncomeItem(id);
    await _local.upsertOtherIncomeItemFromDto(_requireBusinessId(), remote);
    return remote;
  }

  Future<IncomeItemDto> createOtherIncomeItem(
    CreateIncomeItemRequest request,
  ) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _local.upsertOtherIncomeItem(
      id: id,
      businessId: businessId,
      name: request.name.trim(),
      hsnSac: request.hsnSac?.trim(),
      price: request.price,
      priceIsTaxInclusive: request.priceIsTaxInclusive,
      taxRate: request.taxRate,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _incomeItemsEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: request.toJson(),
      clientUpdatedAt: now,
    );
    return (await _local.getIncomeItem(id))!;
  }

  Future<IncomeItemDto> updateOtherIncomeItem(
    String id,
    UpdateIncomeItemRequest request,
  ) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getIncomeItem(id);
    if (existing == null) {
      return _remote.updateOtherIncomeItem(id, request);
    }
    final now = DateTime.now().toUtc();
    await _local.upsertOtherIncomeItem(
      id: id,
      businessId: businessId,
      name: request.name?.trim() ?? existing.name,
      hsnSac: request.hsnSac ?? existing.hsnSac,
      price: request.price ?? existing.price,
      priceIsTaxInclusive:
          request.priceIsTaxInclusive ?? existing.priceIsTaxInclusive,
      taxRate: request.taxRate ?? existing.taxRate,
      syncVersion: 0,
      createdAt: DateTime.tryParse(existing.createdAt)?.toUtc() ?? now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _incomeItemsEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: request.toJson(),
      clientUpdatedAt: now,
    );
    return (await _local.getIncomeItem(id))!;
  }

  Future<void> deleteOtherIncomeItem(String id) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    await _local.softDeleteOtherIncomeItem(id, now);
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _incomeItemsEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      clientUpdatedAt: now,
    );
  }

  Future<void> deleteCategory(String id) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    await _local.softDeleteCategory(id, now);
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _incomeCategoriesEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      clientUpdatedAt: now,
    );
  }
}
