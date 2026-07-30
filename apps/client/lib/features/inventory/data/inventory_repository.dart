import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/brand_master_repository.dart';
import 'package:billing_baba/features/inventory/data/godown_master_repository.dart';
import 'package:billing_baba/features/inventory/data/inventory_document_stock_applier.dart';
import 'package:billing_baba/features/inventory/data/inventory_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_movement_projector.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_master_repository.dart';
import 'package:billing_baba/features/inventory/data/stock_adjustment_command_repository.dart';
import 'package:billing_baba/features/inventory/data/unit_master_repository.dart';
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
import 'package:billing_baba/features/inventory/models/item_model.dart';
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
    required this._items,
    required this._stockLocal,
    required this._movementProjector,
    this._units,
    this._godowns,
    this._brands,
    this._deviceIdReader,
    this._stockApplier,
  });

  final InventoryRemoteDataSource _remote;
  final InventoryLocalDataSource _local;
  final SyncQueue _syncQueue;
  final String Function() _businessIdReader;
  final ItemMasterRepository _items;
  final InventoryStockLocalDataSource _stockLocal;
  final InventoryMovementProjector _movementProjector;
  final UnitMasterRepository? _units;
  final GodownMasterRepository? _godowns;
  final BrandMasterRepository? _brands;
  final String? Function()? _deviceIdReader;
  final InventoryDocumentStockApplier? _stockApplier;

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
      _brands?.list(query) ?? _remote.listBrands(query);

  Future<BrandDto> getBrand(String id) async {
    final local = await _brands?.getActive(id);
    if (local != null) return local;
    return _remote.getBrand(id);
  }

  Future<BrandDto> createBrand(CreateBrandRequest request) =>
      _brands?.create(request) ?? _remote.createBrand(request);

  Future<BrandDto> updateBrand(String id, UpdateBrandRequest request) =>
      _brands?.update(id, request) ?? _remote.updateBrand(id, request);

  Future<void> deleteBrand(String id) =>
      _brands?.softDelete(id) ?? _remote.deleteBrand(id);

  Future<PaginatedUnitsDto> getUnits(UnitListQuery query) =>
      _units?.list(query) ?? _remote.listUnits(query);

  Future<UnitDetailDto> getUnit(String id) async {
    final local = await _units?.getActive(id);
    if (local != null) return local;
    return _remote.getUnit(id);
  }

  Future<UnitDetailDto> createUnit(CreateUnitRequest request) =>
      _units?.create(request) ?? _remote.createUnit(request);

  Future<UnitDetailDto> updateUnit(String id, UpdateUnitRequest request) =>
      _units?.update(id, request) ?? _remote.updateUnit(id, request);

  Future<void> deleteUnit(String id) =>
      _units?.softDelete(id) ?? _remote.deleteUnit(id);

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
      _godowns?.list(query) ?? _remote.listGodowns(query);

  Future<GodownDto> getGodown(String id) async {
    final local = await _godowns?.getActive(id);
    if (local != null) return local;
    return _remote.getGodown(id);
  }

  Future<GodownDto> createGodown(CreateGodownRequest request) =>
      _godowns?.create(request) ?? _remote.createGodown(request);

  Future<GodownDto> updateGodown(String id, UpdateGodownRequest request) =>
      _godowns?.update(id, request) ?? _remote.updateGodown(id, request);

  Future<void> deleteGodown(String id) =>
      _godowns?.softDelete(id) ?? _remote.deleteGodown(id);

  Future<PaginatedItemsDto> listItems(ItemListQuery query) =>
      _items.list(query);

  Future<int> countItemsPage({
    String? searchQuery,
    ItemType? type,
    String? categoryId,
  }) =>
      _items.countActive(
        searchQuery: searchQuery,
        type: type,
        categoryId: categoryId,
      );

  Future<List<ItemListDto>> listItemsPage({
    required int limit,
    required int offset,
    String? searchQuery,
    ItemType? type,
    String? categoryId,
  }) =>
      _items.listPage(
        limit: limit,
        offset: offset,
        searchQuery: searchQuery,
        type: type,
        categoryId: categoryId,
      );

  Stream<List<ItemListDto>> watchItemsPage({
    required int limit,
    required int offset,
    String? searchQuery,
    ItemType? type,
    String? categoryId,
  }) =>
      _items.watchPage(
        limit: limit,
        offset: offset,
        searchQuery: searchQuery,
        type: type,
        categoryId: categoryId,
      );

  Future<Map<String, double>> localStockQuantitiesForItems(
    Iterable<String> itemIds,
  ) async {
    final all = await localStockQuantitiesByItem();
    final ids = itemIds.toSet();
    return Map.fromEntries(all.entries.where((entry) => ids.contains(entry.key)));
  }

  Future<ItemDetailDto> getItem(String id) async {
    final local = await _items.getActive(id);
    if (local != null) return local;
    return _remote.getItem(id);
  }

  Future<Map<String, List<String>>> getAlternativesIndex() =>
      _remote.getAlternativesIndex();

  Future<ItemDetailDto> createItem(CreateItemRequest request) =>
      _items.create(request);

  Future<ItemDetailDto> updateItem(String id, UpdateItemRequest request) =>
      _items.update(id, request);

  Future<void> deleteItem(String id) => _items.softDelete(id);

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

  Future<PaginatedStockLevelsDto> getStockLevels(StockLevelListQuery query) async {
    final businessId = _requireBusinessId();
    if (query.itemId != null && query.itemId!.isNotEmpty) {
      final rows = await _stockLocal.listStockLevelRowsForItem(
        businessId: businessId,
        itemId: query.itemId!,
      );
      final levels = await _mapLocalStockRows(businessId, rows);
      return PaginatedStockLevelsDto(
        stockLevels: levels,
        meta: PaginationMetaDto(
          page: query.page,
          limit: query.limit,
          total: levels.length,
        ),
      );
    }
    try {
      return await _remote.listStockLevels(query);
    } on Object {
      return PaginatedStockLevelsDto(
        stockLevels: const [],
        meta: PaginationMetaDto(
          page: query.page,
          limit: query.limit,
          total: 0,
        ),
      );
    }
  }

  Future<StockLevelDto> getStockLevel(String id) => _remote.getStockLevel(id);

  Future<List<StockLevelDto>> listLocalStockLevelsForItem(String itemId) async {
    final businessId = _requireBusinessId();
    final rows = await _stockLocal.listStockLevelRowsForItem(
      businessId: businessId,
      itemId: itemId,
    );
    return _mapLocalStockRows(businessId, rows);
  }

  Future<Map<String, double>> localStockQuantitiesByItem() async {
    final businessId = _requireBusinessId();
    var quantities = await _stockLocal.quantitiesByItem(businessId: businessId);
    if (quantities.isEmpty) {
      await _maybeBackfillBusinessStock(businessId);
      quantities = await _stockLocal.quantitiesByItem(businessId: businessId);
    }
    return quantities;
  }

  Future<void> _maybeBackfillBusinessStock(String businessId) async {
    final applier = _stockApplier;
    if (applier == null) return;
    final hasMovements = await _stockLocal.hasAnyMovements(businessId: businessId);
    if (hasMovements) return;
    await applier.backfillBusinessStock(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
    );
  }

  Future<PaginatedMovementsDto> getMovements(MovementListQuery query) =>
      _remote.listMovements(query);

  Future<MovementDto> getMovement(String id) => _remote.getMovement(id);

  Future<void> createMovement(CreateMovementRequest request) {
    return StockAdjustmentCommandRepository(
      syncQueue: _syncQueue,
      local: _stockLocal,
      businessIdReader: _businessIdReader,
      deviceIdReader: _deviceIdReader,
    ).applyAdjustment(request);
  }

  Future<List<MovementDto>> listLocalMovementsForItem(String itemId) async {
    final businessId = _requireBusinessId();
    final stored = await _stockLocal.listMovementsForItem(
      businessId: businessId,
      itemId: itemId,
    );
    final projected = await _movementProjector.projectForItem(
      businessId: businessId,
      itemId: itemId,
    );

    final byId = <String, MovementDto>{};
    for (final movement in [...stored, ...projected]) {
      byId[movement.id] = movement;
    }

    final merged = byId.values.toList()
      ..sort(
        (a, b) => DateTime.parse(b.createdAt).compareTo(
          DateTime.parse(a.createdAt),
        ),
      );
    return merged;
  }

  Future<double> localStockQuantityForItem(String itemId) async {
    final businessId = _requireBusinessId();
    var qty = await _stockLocal.totalQuantityForItem(
      businessId: businessId,
      itemId: itemId,
    );
    if (qty == 0) {
      await _maybeBackfillBusinessStock(businessId);
      qty = await _stockLocal.totalQuantityForItem(
        businessId: businessId,
        itemId: itemId,
      );
    }
    return qty;
  }

  Future<void> reconcileLocalItemStock(String itemId) {
    return _stockLocal.reconcileItemStock(
      businessId: _requireBusinessId(),
      itemId: itemId,
    );
  }

  Future<MovementDto> createMovementRemote(CreateMovementRequest request) =>
      _remote.createMovement(request);

  Future<List<StockLevelDto>> _mapLocalStockRows(
    String businessId,
    List<StockLevelLocalData> rows,
  ) async {
    if (rows.isEmpty) return const [];

    final itemIds = rows.map((row) => row.itemId).toSet();
    final godownIds = rows.map((row) => row.godownId).toSet();

    final itemNames = <String, String>{};
    for (final itemId in itemIds) {
      final item = await _items.getActive(itemId);
      if (item != null) {
        itemNames[itemId] = item.name;
      }
    }

    final godownNames = <String, String>{};
    if (_godowns != null) {
      for (final godownId in godownIds) {
        final godown = await _godowns.getActive(godownId);
        if (godown != null) {
          godownNames[godownId] = godown.name;
        }
      }
    }

    final now = DateTime.now().toUtc().toIso8601String();
    return [
      for (final row in rows)
        StockLevelDto(
          id: row.id,
          itemId: row.itemId,
          itemName: itemNames[row.itemId] ?? row.itemId,
          godownId: row.godownId,
          godownName: godownNames[row.godownId] ?? row.godownId,
          quantity: row.currentQuantity,
          averageCost: row.averageCost,
          isLowStock: false,
          createdAt: now,
          updatedAt: row.updatedAt.toUtc().toIso8601String(),
        ),
    ];
  }

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
