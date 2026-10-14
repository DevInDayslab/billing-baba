import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:billing_baba/features/purchases/data/expense_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/expense_remote_data_source.dart';
import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _expensesEntity = 'expenses';
const _expenseCategoriesEntity = 'expense_categories';
const _expenseItemsEntity = 'expense_items';

class ExpenseMasterRepository {
  ExpenseMasterRepository({
    required this._local,
    required this._remote,
    required this._syncQueue,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final ExpenseLocalDataSource _local;
  final ExpenseRemoteDataSource _remote;
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
    final items = await _local.listExpenseItems(businessId);
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
          final response = await _remote.listExpenseItems(page: page, limit: 100);
          for (final dto in response.items) {
            await _local.upsertExpenseItemFromDto(businessId, dto);
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

  Future<PaginatedExpensesDto> listExpenses(ExpenseListQuery query) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    final all = await _local.listExpenses(
      businessId,
      categoryId: query.categoryId,
    );
    final start = (query.page - 1) * query.limit;
    final pageItems = start >= all.length
        ? <ExpenseDto>[]
        : all.skip(start).take(query.limit).toList();
    return PaginatedExpensesDto(
      expenses: pageItems,
      meta: PaginationMetaDto(
        page: query.page,
        limit: query.limit,
        total: all.length,
      ),
    );
  }

  Future<ExpenseDto> getExpense(String id) async {
    final local = await _local.getExpense(id);
    if (local != null) return local;
    final remote = await _remote.getExpense(id);
    await _local.upsertExpenseFromDto(_requireBusinessId(), remote);
    return remote;
  }

  Future<ExpenseDto> createExpense(CreateExpenseRequest request) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _local.upsertExpense(
      id: id,
      businessId: businessId,
      categoryId: request.categoryId,
      expenseItemId: request.expenseItemId,
      partyId: request.partyId,
      amount: request.amount,
      expenseDate: request.expenseDate,
      description: request.description,
      notes: request.notes,
      referenceNumber: request.referenceNumber,
      taxAmount: request.taxAmount,
      taxRate: request.taxRate,
      paymentMode: request.paymentMode,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _expensesEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: request.toJson(),
      clientUpdatedAt: now,
    );
    return (await _local.getExpense(id))!;
  }

  Future<ExpenseDto> updateExpense(
    String id,
    UpdateExpenseRequest request,
  ) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getExpense(id);
    if (existing == null) {
      return _remote.updateExpense(id, request);
    }
    final now = DateTime.now().toUtc();
    await _local.upsertExpense(
      id: id,
      businessId: businessId,
      categoryId: request.categoryId ?? existing.categoryId,
      expenseItemId: request.expenseItemId ?? existing.expenseItemId,
      partyId: request.partyId ?? existing.partyId,
      amount: request.amount ?? existing.amount,
      expenseDate: request.expenseDate ?? existing.expenseDate,
      description: request.description ?? existing.description,
      notes: request.notes ?? existing.notes,
      referenceNumber: request.referenceNumber ?? existing.referenceNumber,
      taxAmount: request.taxAmount ?? existing.taxAmount,
      taxRate: request.taxRate ?? existing.taxRate,
      paymentMode: request.paymentMode ?? existing.paymentMode,
      syncVersion: 0,
      createdAt: DateTime.tryParse(existing.createdAt)?.toUtc() ?? now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _expensesEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: request.toJson(),
      clientUpdatedAt: now,
    );
    return (await _local.getExpense(id))!;
  }

  Future<void> deleteExpense(String id) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    await _local.softDeleteExpense(id, now);
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _expensesEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      clientUpdatedAt: now,
    );
  }

  Future<PaginatedExpenseCategoriesDto> listCategories({
    int page = 1,
    int limit = 100,
  }) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    final all = await _local.listCategories(businessId);
    final start = (page - 1) * limit;
    final pageItems = start >= all.length
        ? <ExpenseCategoryDto>[]
        : all.skip(start).take(limit).toList();
    return PaginatedExpenseCategoriesDto(
      categories: pageItems,
      meta: PaginationMetaDto(page: page, limit: limit, total: all.length),
    );
  }

  Future<ExpenseCategoryDto> getCategory(String id) async {
    final local = await _local.getCategory(id);
    if (local != null) return local;
    final remote = await _remote.getCategory(id);
    await _local.upsertCategoryFromDto(_requireBusinessId(), remote);
    return remote;
  }

  Future<ExpenseCategoryDto> createCategory(
    CreateExpenseCategoryRequest request,
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
      entityType: _expenseCategoriesEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: request.toJson(),
      clientUpdatedAt: now,
    );
    return (await _local.getCategory(id))!;
  }

  Future<ExpenseCategoryDto> updateCategory(
    String id,
    UpdateExpenseCategoryRequest request,
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
      entityType: _expenseCategoriesEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: request.toJson(),
      clientUpdatedAt: now,
    );
    return (await _local.getCategory(id))!;
  }

  Future<PaginatedExpenseItemsDto> listExpenseItems({
    int page = 1,
    int limit = 100,
  }) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    final all = await _local.listExpenseItems(businessId);
    final start = (page - 1) * limit;
    final pageItems = start >= all.length
        ? <ExpenseItemDto>[]
        : all.skip(start).take(limit).toList();
    return PaginatedExpenseItemsDto(
      items: pageItems,
      meta: PaginationMetaDto(page: page, limit: limit, total: all.length),
    );
  }

  Future<ExpenseItemDto> getExpenseItem(String id) async {
    final local = await _local.getExpenseItem(id);
    if (local != null) return local;
    final remote = await _remote.getExpenseItem(id);
    await _local.upsertExpenseItemFromDto(_requireBusinessId(), remote);
    return remote;
  }

  Future<ExpenseItemDto> createExpenseItem(
    CreateExpenseItemRequest request,
  ) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _local.upsertExpenseItem(
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
      entityType: _expenseItemsEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: request.toJson(),
      clientUpdatedAt: now,
    );
    return (await _local.getExpenseItem(id))!;
  }

  Future<ExpenseItemDto> updateExpenseItem(
    String id,
    UpdateExpenseItemRequest request,
  ) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getExpenseItem(id);
    if (existing == null) {
      return _remote.updateExpenseItem(id, request);
    }
    final now = DateTime.now().toUtc();
    await _local.upsertExpenseItem(
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
      entityType: _expenseItemsEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: request.toJson(),
      clientUpdatedAt: now,
    );
    return (await _local.getExpenseItem(id))!;
  }

  Future<void> deleteExpenseItem(String id) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    await _local.softDeleteExpenseItem(id, now);
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _expenseItemsEntity,
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
      entityType: _expenseCategoriesEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      clientUpdatedAt: now,
    );
  }
}
