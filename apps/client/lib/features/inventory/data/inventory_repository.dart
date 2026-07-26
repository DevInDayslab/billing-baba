import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_service.dart';
import 'package:billing_baba/features/inventory/data/inventory_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/models/dto/brand_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/category_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/godown_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/item_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/item_location_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/item_summary_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/movement_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/price_history_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/stock_level_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/unit_conversion_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/unit_dto.dart';
import 'package:billing_baba/features/inventory/models/requests/brand_requests.dart';
import 'package:billing_baba/features/inventory/models/requests/category_requests.dart';
import 'package:billing_baba/features/inventory/models/requests/godown_requests.dart';
import 'package:billing_baba/features/inventory/models/requests/item_requests.dart';
import 'package:billing_baba/features/inventory/models/requests/movement_requests.dart';
import 'package:billing_baba/features/inventory/models/requests/unit_requests.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _categoriesEntity = 'categories';

class InventoryRepository {
  InventoryRepository({
    required this._remote,
    required this._local,
    required this._syncQueue,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final InventoryRemoteDataSource _remote;
  final InventoryLocalDataSource _local;
  final SyncQueueService _syncQueue;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  InventoryRemoteDataSource get remoteDataSource => _remote;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for inventory operations');
    }
    return id;
  }

  Future<PaginatedCategoriesDto> getCategories(CategoryListQuery query) async {
    final businessId = _requireBusinessId();
    await _hydrateCategoriesIfEmpty(businessId);
    final all = await _local.categories.listActive(
      businessId,
      searchQuery: query.q,
    );
    final start = (query.page - 1) * query.limit;
    final pageItems = start >= all.length
        ? <CategoryDto>[]
        : all.skip(start).take(query.limit).toList();
    return PaginatedCategoriesDto(
      categories: pageItems,
      meta: PaginationMetaDto(
        page: query.page,
        limit: query.limit,
        total: all.length,
      ),
    );
  }

  Future<CategoryDto> getCategory(String id) async {
    final local = await _local.categories.getActiveDto(id);
    if (local != null) return local;
    // Fallback for missing local row (e.g. deep link before hydrate).
    final remote = await _remote.getCategory(id);
    final businessId = _requireBusinessId();
    await _local.categories.upsertFromDto(businessId, remote);
    return remote;
  }

  Future<CategoryDto> createCategory(CreateCategoryRequest request) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final name = request.name.trim();
    await _local.categories.upsertRow(
      id: id,
      businessId: businessId,
      name: name,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _categoriesEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: {'name': name},
      clientUpdatedAt: now,
    );
    return CategoryDto(
      id: id,
      name: name,
      itemCount: 0,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );
  }

  Future<CategoryDto> updateCategory(
    String id,
    UpdateCategoryRequest request,
  ) async {
    final businessId = _requireBusinessId();
    final existing = await _local.categories.getById(id);
    if (existing == null || existing.isDeleted) {
      throw StateError('Category not found locally');
    }
    final name = (request.name ?? existing.name).trim();
    final now = DateTime.now().toUtc();
    final baseVersion = existing.syncVersion;
    await _local.categories.upsertRow(
      id: id,
      businessId: businessId,
      name: name,
      syncVersion: baseVersion,
      createdAt: existing.createdAt,
      updatedAt: now,
      deviceId: _deviceIdReader?.call() ?? existing.deviceId,
      itemCount: existing.itemCount,
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _categoriesEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: {'name': name},
      baseSyncVersion: baseVersion,
      clientUpdatedAt: now,
    );
    return CategoryDto(
      id: id,
      name: name,
      itemCount: existing.itemCount,
      createdAt: existing.createdAt.toUtc().toIso8601String(),
      updatedAt: now.toIso8601String(),
    );
  }

  Future<void> deleteCategory(String id) async {
    final businessId = _requireBusinessId();
    final existing = await _local.categories.getById(id);
    if (existing == null || existing.isDeleted) return;
    final now = DateTime.now().toUtc();
    await _local.categories.softDelete(id: id, deletedAt: now);
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _categoriesEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
  }

  /// Temporary remote hydrate until full sync bootstrap lands.
  Future<void> _hydrateCategoriesIfEmpty(String businessId) async {
    final count = await _local.categories.countActive(businessId);
    if (count > 0) return;
    try {
      var page = 1;
      while (true) {
        final response = await _remote.listCategories(
          CategoryListQuery(page: page, limit: 100),
        );
        for (final dto in response.categories) {
          await _local.categories.upsertFromDto(businessId, dto);
        }
        if (response.categories.length < 100) break;
        if (page * 100 >= response.meta.total) break;
        page += 1;
      }
    } on Object {
      // Offline / first launch with empty local — leave empty.
    }
  }

  Future<PaginatedBrandsDto> getBrands(BrandListQuery query) =>
      _remote.listBrands(query);

  Future<BrandDto> getBrand(String id) => _remote.getBrand(id);

  Future<BrandDto> createBrand(CreateBrandRequest request) =>
      _remote.createBrand(request);

  Future<BrandDto> updateBrand(String id, UpdateBrandRequest request) =>
      _remote.updateBrand(id, request);

  Future<void> deleteBrand(String id) => _remote.deleteBrand(id);

  Future<PaginatedUnitsDto> getUnits(UnitListQuery query) =>
      _remote.listUnits(query);

  Future<UnitDetailDto> getUnit(String id) => _remote.getUnit(id);

  Future<UnitDetailDto> createUnit(CreateUnitRequest request) =>
      _remote.createUnit(request);

  Future<UnitDetailDto> updateUnit(String id, UpdateUnitRequest request) =>
      _remote.updateUnit(id, request);

  Future<void> deleteUnit(String id) => _remote.deleteUnit(id);

  Future<PaginatedUnitConversionsDto> getUnitConversions(
    UnitConversionListQuery query,
  ) => _remote.listUnitConversions(query);

  Future<UnitConversionDto> createUnitConversion(
    CreateUnitConversionRequest request,
  ) => _remote.createUnitConversion(request);

  Future<UnitConversionDto> updateUnitConversion(
    String id,
    UpdateUnitConversionRequest request,
  ) => _remote.updateUnitConversion(id, request);

  Future<void> deleteUnitConversion(String id) =>
      _remote.deleteUnitConversion(id);

  Future<PaginatedGodownsDto> getGodowns(GodownListQuery query) =>
      _remote.listGodowns(query);

  Future<GodownDto> getGodown(String id) => _remote.getGodown(id);

  Future<GodownDto> createGodown(CreateGodownRequest request) =>
      _remote.createGodown(request);

  Future<GodownDto> updateGodown(String id, UpdateGodownRequest request) =>
      _remote.updateGodown(id, request);

  Future<void> deleteGodown(String id) => _remote.deleteGodown(id);

  Future<PaginatedItemsDto> listItems(ItemListQuery query) =>
      _remote.listItems(query);

  Future<ItemDetailDto> getItem(String id) => _remote.getItem(id);

  Future<Map<String, List<String>>> getAlternativesIndex() =>
      _remote.getAlternativesIndex();

  Future<ItemDetailDto> createItem(CreateItemRequest request) =>
      _remote.createItem(request);

  Future<ItemDetailDto> updateItem(String id, UpdateItemRequest request) =>
      _remote.updateItem(id, request);

  Future<void> deleteItem(String id) => _remote.deleteItem(id);

  Future<List<ItemImageDto>> getItemImages(String itemId) =>
      _remote.listItemImages(itemId);

  Future<ItemImageDto> createItemImage(
    String itemId,
    CreateItemImageRequest request,
  ) => _remote.createItemImage(itemId, request);

  Future<ItemImageDto> updateItemImage(
    String itemId,
    String imageId,
    UpdateItemImageRequest request,
  ) => _remote.updateItemImage(itemId, imageId, request);

  Future<void> deleteItemImage(String itemId, String imageId) =>
      _remote.deleteItemImage(itemId, imageId);

  Future<List<TierPriceDto>> getItemTierPrices(String itemId) =>
      _remote.getItemTierPrices(itemId);

  Future<List<TierPriceDto>> upsertItemTierPrices(
    String itemId,
    UpsertTierPricesRequest request,
  ) => _remote.upsertItemTierPrices(itemId, request);

  Future<void> deleteItemTierPrice(String itemId, String tier) =>
      _remote.deleteItemTierPrice(itemId, tier);

  Future<PaginatedItemLocationsDto> getItemLocations({
    int page = 1,
    int limit = 100,
    String? itemId,
    String? godownId,
  }) => _remote.listItemLocations(
    page: page,
    limit: limit,
    itemId: itemId,
    godownId: godownId,
  );

  Future<ItemLocationDto> createItemLocation(
    CreateItemLocationRecordRequest request,
  ) => _remote.createItemLocation(request);

  Future<ItemLocationDto> updateItemLocation(
    String id,
    UpdateItemLocationRecordRequest request,
  ) => _remote.updateItemLocation(id, request);

  Future<void> deleteItemLocation(String id) => _remote.deleteItemLocation(id);

  Future<PaginatedStockLevelsDto> getStockLevels(StockLevelListQuery query) =>
      _remote.listStockLevels(query);

  Future<StockLevelDto> getStockLevel(String id) => _remote.getStockLevel(id);

  Future<PaginatedMovementsDto> getMovements(MovementListQuery query) =>
      _remote.listMovements(query);

  Future<MovementDto> getMovement(String id) => _remote.getMovement(id);

  Future<MovementDto> createMovement(CreateMovementRequest request) =>
      _remote.createMovement(request);

  Future<PaginatedPriceHistoryDto> getItemPriceHistory(
    String itemId, {
    int page = 1,
    int limit = 100,
  }) => _remote.getItemPriceHistory(itemId, page: page, limit: limit);

  Future<PaginatedPriceHistoryDto> getPriceHistory(
    PriceHistoryListQuery query,
  ) => _remote.listPriceHistory(query);

  Future<PriceHistoryDto> getPriceHistoryRecord(String id) =>
      _remote.getPriceHistoryRecord(id);
}
