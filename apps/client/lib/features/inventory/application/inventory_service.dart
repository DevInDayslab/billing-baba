import 'dart:typed_data';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/data/brand_local_source.dart';
import 'package:billing_baba/features/inventory/data/brand_master_repository.dart';
import 'package:billing_baba/features/inventory/data/category_local_source.dart';
import 'package:billing_baba/features/inventory/data/godown_local_source.dart';
import 'package:billing_baba/features/inventory/data/godown_master_repository.dart';
import 'package:billing_baba/features/inventory/data/inventory_document_stock_applier.dart';
import 'package:billing_baba/features/inventory/data/inventory_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_movement_projector.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_repository.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_local_source.dart';
import 'package:billing_baba/features/inventory/data/item_master_repository.dart';
import 'package:billing_baba/features/inventory/data/item_media_repository.dart';
import 'package:billing_baba/features/inventory/data/unit_local_source.dart';
import 'package:billing_baba/features/inventory/data/unit_master_repository.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/brand_model.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/dto/category_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/item_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/stock_level_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/unit_dto.dart';
import 'package:billing_baba/features/inventory/models/godown_model.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/models/item_location_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/mappers/add_item_form_mapper.dart';
import 'package:billing_baba/features/inventory/models/mappers/brand_mapper.dart';
import 'package:billing_baba/features/inventory/models/mappers/category_mapper.dart';
import 'package:billing_baba/features/inventory/models/mappers/godown_mapper.dart';
import 'package:billing_baba/features/inventory/models/mappers/item_image_mapper.dart';
import 'package:billing_baba/features/inventory/models/mappers/item_location_mapper.dart';
import 'package:billing_baba/features/inventory/models/mappers/item_mapper.dart';
import 'package:billing_baba/features/inventory/models/mappers/movement_mapper.dart';
import 'package:billing_baba/features/inventory/models/mappers/price_history_mapper.dart';
import 'package:billing_baba/features/inventory/models/mappers/unit_mapper.dart';
import 'package:billing_baba/features/inventory/models/paginated_inventory_items.dart';
import 'package:billing_baba/features/inventory/models/price_history_model.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/models/requests/brand_requests.dart';
import 'package:billing_baba/features/inventory/models/requests/category_requests.dart';
import 'package:billing_baba/features/inventory/models/requests/godown_requests.dart';
import 'package:billing_baba/features/inventory/models/requests/item_requests.dart';
import 'package:billing_baba/features/inventory/models/requests/movement_requests.dart';
import 'package:billing_baba/features/inventory/models/requests/unit_requests.dart';
import 'package:billing_baba/features/inventory/models/tier_price_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'inventory_error_mapper.dart'
    show InventoryException, InventoryOfflineException;

part 'inventory_service.g.dart';

@Riverpod(keepAlive: true)
Future<InventoryService> inventoryService(Ref ref) async {
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

  // Rebuild when the active business changes so item ops get a fresh business id.
  final currentBusiness = ref.watch(currentBusinessProvider);

  final remote = InventoryRemoteDataSource(api.dio);
  String businessIdReader() {
    final fromProfile = currentBusiness?.id.trim() ??
        ref.read(currentBusinessProvider)?.id.trim() ??
        '';
    if (fromProfile.isNotEmpty) return fromProfile;
    return storage.read(StorageKeys.lastOpenedBusinessId)?.trim() ?? '';
  }
  String? deviceIdReader() => deviceId;

  final repository = InventoryRepository(
    remote: remote,
    local: DriftInventoryLocalDataSource(CategoryLocalSource(db)),
    syncQueue: queue,
    businessIdReader: businessIdReader,
    deviceIdReader: deviceIdReader,
    stockLocal: InventoryStockLocalDataSource(db),
    movementProjector: InventoryMovementProjector(db),
    stockApplier: InventoryDocumentStockApplier(
      stockLocal: InventoryStockLocalDataSource(db),
      salesLocal: SalesLocalDataSource(db),
      purchaseLocal: PurchaseLocalDataSource(db),
    ),
    items: ItemMasterRepository(
      local: ItemLocalSource(db),
      syncQueue: queue,
      remote: remote,
      businessIdReader: businessIdReader,
      deviceIdReader: deviceIdReader,
    ),
    units: UnitMasterRepository(
      local: UnitLocalSource(db),
      syncQueue: queue,
      remote: remote,
      businessIdReader: businessIdReader,
      deviceIdReader: deviceIdReader,
    ),
    godowns: GodownMasterRepository(
      local: GodownLocalSource(db),
      syncQueue: queue,
      remote: remote,
      businessIdReader: businessIdReader,
      deviceIdReader: deviceIdReader,
    ),
    brands: BrandMasterRepository(
      local: BrandLocalSource(db),
      syncQueue: queue,
      remote: remote,
      businessIdReader: businessIdReader,
      deviceIdReader: deviceIdReader,
    ),
  );
  return InventoryService(
    repository: repository,
    mediaRepository: ItemMediaRepository(api.dio),
  );
}

class InventoryService {
  InventoryService({
    required this._repository,
    ItemMediaRepository? mediaRepository,
  })  : _media = mediaRepository;

  static const inventoryPageSize = 80;

  final InventoryRepository _repository;
  final ItemMediaRepository? _media;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  Future<void> refreshInBackground(Future<void> Function() refresh) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      await refresh();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<List<InventoryCategory>> fetchCategories({String? searchQuery}) async {
    try {
      final dtos = await _fetchAllPages<CategoryDto>(
        fetchPage: (page) async {
          final response = await _repository.getCategories(
            CategoryListQuery(page: page, limit: 100, q: searchQuery),
          );
          return (response.categories, response.meta.total);
        },
      );
      return dtos.map(CategoryMapper.fromDto).toList();
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<InventoryCategory> createCategory(String name) async {
    try {
      final dto = await _repository.createCategory(
        CreateCategoryRequest(name: name.trim()),
      );
      return CategoryMapper.fromDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<InventoryCategory> updateCategory(String id, String name) async {
    try {
      final dto = await _repository.updateCategory(
        id,
        UpdateCategoryRequest(name: name.trim()),
      );
      return CategoryMapper.fromDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<List<BrandModel>> fetchBrands({String? searchQuery}) async {
    try {
      final dtos = await _fetchAllPages(
        fetchPage: (page) async {
          final response = await _repository.getBrands(
            BrandListQuery(page: page, limit: 100, q: searchQuery),
          );
          return (response.brands, response.meta.total);
        },
      );
      return dtos.map(BrandMapper.fromDto).toList();
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<BrandModel> createBrand(String name) async {
    try {
      final dto = await _repository.createBrand(
        CreateBrandRequest(name: name.trim()),
      );
      return BrandMapper.fromDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<BrandModel> updateBrand(String id, String name) async {
    try {
      final dto = await _repository.updateBrand(
        id,
        UpdateBrandRequest(name: name.trim()),
      );
      return BrandMapper.fromDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> deleteBrand(String id) async {
    try {
      await _repository.deleteBrand(id);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<List<InventoryUnit>> fetchUnits({String? searchQuery}) async {
    try {
      final dtos = await _fetchAllPages<UnitListDto>(
        fetchPage: (page) async {
          final response = await _repository.getUnits(
            UnitListQuery(page: page, limit: 100, q: searchQuery),
          );
          return (response.units, response.meta.total);
        },
      );
      return dtos.map(UnitMapper.fromListDto).toList();
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<InventoryUnit> getUnit(String id) async {
    try {
      final dto = await _repository.getUnit(id);
      return UnitMapper.fromDetailDto(dto);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<InventoryUnit> createUnit({
    required String fullName,
    required String shortName,
  }) async {
    try {
      final dto = await _repository.createUnit(
        CreateUnitRequest(
          name: fullName.trim(),
          shortName: shortName.trim().toUpperCase(),
        ),
      );
      return UnitMapper.fromDetailDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<InventoryUnit> updateUnit({
    required String id,
    String? fullName,
    String? shortName,
  }) async {
    try {
      final dto = await _repository.updateUnit(
        id,
        UpdateUnitRequest(
          name: fullName?.trim(),
          shortName: shortName?.trim().toUpperCase(),
        ),
      );
      return UnitMapper.fromDetailDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> deleteUnit(String id) async {
    try {
      await _repository.deleteUnit(id);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<UnitConversion> createUnitConversion({
    required String fromUnitId,
    required String toUnitId,
    required double factor,
  }) async {
    try {
      final dto = await _repository.createUnitConversion(
        CreateUnitConversionRequest(
          fromUnitId: fromUnitId,
          toUnitId: toUnitId,
          conversionFactor: _formatDecimal(factor),
        ),
      );
      return UnitConversionMapper.fromDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> deleteUnitConversion(String id) async {
    try {
      await _repository.deleteUnitConversion(id);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<List<GodownModel>> fetchGodowns({String? searchQuery}) async {
    try {
      final dtos = await _fetchAllPages(
        fetchPage: (page) async {
          final response = await _repository.getGodowns(
            GodownListQuery(page: page, limit: 100, q: searchQuery),
          );
          return (response.godowns, response.meta.total);
        },
      );
      return dtos.map(GodownMapper.fromDto).toList();
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<GodownModel?> getDefaultGodown() async {
    final godowns = await fetchGodowns();
    if (godowns.isEmpty) return null;
    return godowns.firstWhere(
      (godown) => godown.isDefault,
      orElse: () => godowns.first,
    );
  }

  Future<GodownModel> createGodown(String name, {String? address}) async {
    try {
      final dto = await _repository.createGodown(
        CreateGodownRequest(name: name.trim(), address: address?.trim()),
      );
      return GodownMapper.fromDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<GodownModel> updateGodown(
    String id, {
    String? name,
    String? address,
  }) async {
    try {
      final dto = await _repository.updateGodown(
        id,
        UpdateGodownRequest(name: name?.trim(), address: address?.trim()),
      );
      return GodownMapper.fromDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> deleteGodown(String id) async {
    try {
      await _repository.deleteGodown(id);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<UnitConversion> updateUnitConversion({
    required String id,
    required double factor,
  }) async {
    try {
      final dto = await _repository.updateUnitConversion(
        id,
        UpdateUnitConversionRequest(conversionFactor: _formatDecimal(factor)),
      );
      return UnitConversionMapper.fromDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<List<ItemImageModel>> fetchItemImages(String itemId) async {
    try {
      final dtos = await _repository.getItemImages(itemId);
      return dtos.map(ItemImageMapper.fromDto).toList();
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<ItemImageModel> addItemImage(
    String itemId, {
    required String imageUrl,
    bool isPrimary = false,
  }) async {
    try {
      final dto = await _repository.createItemImage(
        itemId,
        CreateItemImageRequest(imageUrl: imageUrl.trim(), isPrimary: isPrimary),
      );
      return ItemImageMapper.fromDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<ItemImageModel> updateItemImage(
    String itemId,
    String imageId, {
    String? imageUrl,
    bool? isPrimary,
  }) async {
    try {
      final dto = await _repository.updateItemImage(
        itemId,
        imageId,
        UpdateItemImageRequest(
          imageUrl: imageUrl?.trim(),
          isPrimary: isPrimary,
        ),
      );
      return ItemImageMapper.fromDto(dto);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> deleteItemImage(String itemId, String imageId) async {
    try {
      if (_media != null) {
        await _media.deleteItemImage(itemId, imageId);
        return;
      }
      await _repository.deleteItemImage(itemId, imageId);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<ItemImageModel> uploadItemImage(
    String itemId, {
    required Uint8List bytes,
    required String mimeType,
    bool isPrimary = false,
    String? replacesImageId,
  }) async {
    final media = _media;
    if (media == null) {
      throw const InventoryException('Media upload is not configured.');
    }

    try {
      final result = await media.uploadItemImage(
        itemId: itemId,
        bytes: bytes,
        mimeType: mimeType,
        isPrimary: isPrimary,
        replacesImageId: replacesImageId,
      );
      return ItemImageMapper.fromUploadResult(result);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> setPrimaryItemImage(String itemId, String imageId) async {
    final media = _media;
    if (media == null) {
      throw const InventoryException('Media upload is not configured.');
    }

    try {
      await media.setPrimaryItemImage(itemId, imageId);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> reorderItemImages(
    String itemId,
    List<String> imageIds,
  ) async {
    final media = _media;
    if (media == null) {
      throw const InventoryException('Media upload is not configured.');
    }

    try {
      await media.reorderItemImages(itemId, imageIds);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<String> uploadRackPhoto({
    required String locationId,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final media = _media;
    if (media == null) {
      throw const InventoryException('Media upload is not configured.');
    }

    try {
      final result = await media.uploadRackPhoto(
        locationId: locationId,
        bytes: bytes,
        mimeType: mimeType,
      );
      final url = result['photo_url'] as String?;
      if (url == null || url.isEmpty) {
        throw const InventoryException('Rack photo upload returned no URL.');
      }
      return url;
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> deleteRackPhoto(String locationId) async {
    final media = _media;
    if (media == null) {
      throw const InventoryException('Media upload is not configured.');
    }

    try {
      await media.deleteRackPhoto(locationId);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<List<TierPriceModel>> upsertTierPrices(
    String itemId,
    List<CreateItemTierPriceRequest> tierPrices,
  ) async {
    try {
      final dtos = await _repository.upsertItemTierPrices(
        itemId,
        UpsertTierPricesRequest(tierPrices: tierPrices),
      );
      return dtos
          .map(
            (tier) => TierPriceModel(
              pricingTier: tier.pricingTier,
              price: double.tryParse(tier.price) ?? 0,
            ),
          )
          .toList();
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> deleteTierPrice(String itemId, String tier) async {
    try {
      await _repository.deleteItemTierPrice(itemId, tier);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<List<TierPriceModel>> fetchItemTierPrices(String itemId) async {
    try {
      final dtos = await _repository.getItemTierPrices(itemId);
      return dtos
          .map(
            (tier) => TierPriceModel(
              pricingTier: tier.pricingTier,
              price: double.tryParse(tier.price) ?? 0,
            ),
          )
          .toList();
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<List<ItemLocationModel>> fetchItemLocations(String itemId) async {
    try {
      final locations = await _fetchAllPages(
        fetchPage: (page) async {
          final response = await _repository.getItemLocations(
            page: page,
            itemId: itemId,
          );
          return (response.locations, response.meta.total);
        },
      );
      return locations.map(ItemLocationMapper.fromDto).toList();
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<ItemLocationModel> createItemLocation({
    required String itemId,
    required String godownId,
    String? rack,
    String? shelf,
  }) async {
    try {
      final dto = await _repository.createItemLocation(
        CreateItemLocationRecordRequest(
          itemId: itemId,
          godownId: godownId,
          rack: rack,
          shelf: shelf,
        ),
      );
      return ItemLocationMapper.fromDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<ItemLocationModel> updateItemLocation(
    String id, {
    String? rack,
    String? shelf,
  }) async {
    try {
      final dto = await _repository.updateItemLocation(
        id,
        UpdateItemLocationRecordRequest(rack: rack, shelf: shelf),
      );
      return ItemLocationMapper.fromDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> deleteItemLocation(String id) async {
    try {
      await _repository.deleteItemLocation(id);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<List<PriceHistoryModel>> fetchItemPriceHistory(String itemId) async {
    try {
      final records = await _fetchAllPages(
        fetchPage: (page) async {
          final response = await _repository.getItemPriceHistory(
            itemId,
            page: page,
          );
          return (response.records, response.meta.total);
        },
      );
      return records.map(PriceHistoryMapper.fromDto).toList();
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<List<StockLevelDto>> fetchItemStockLevels(String itemId) async {
    final local = await _repository.listLocalStockLevelsForItem(itemId);
    if (local.isNotEmpty) return local;

    try {
      return _fetchAllPages<StockLevelDto>(
        fetchPage: (page) async {
          final response = await _repository.getStockLevels(
            StockLevelListQuery(page: page, itemId: itemId),
          );
          return (response.stockLevels, response.meta.total);
        },
      );
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> createMovement(CreateMovementRequest request) async {
    await _repository.createMovement(request);
  }

  Future<List<InventoryItem>> fetchItems({
    String? searchQuery,
    ItemType? type,
    String? categoryId,
  }) async {
    try {
      final page = await fetchItemsPage(
        searchQuery: searchQuery,
        type: type,
        categoryId: categoryId,
      );
      if (!page.hasMore) {
        return page.items;
      }

      final all = List<InventoryItem>.from(page.items);
      var offset = all.length;
      while (offset < page.totalCount) {
        final next = await fetchItemsPage(
          offset: offset,
          searchQuery: searchQuery,
          type: type,
          categoryId: categoryId,
        );
        all.addAll(next.items);
        offset = all.length;
        if (!next.hasMore) break;
      }
      return all;
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<PaginatedInventoryItems> fetchItemsPage({
    int limit = inventoryPageSize,
    int offset = 0,
    String? searchQuery,
    ItemType? type,
    String? categoryId,
  }) async {
    try {
      final total = await _repository.countItemsPage(
        searchQuery: searchQuery,
        type: type,
        categoryId: CategoryMapper.toApiCategoryId(categoryId),
      );
      final itemDtos = await _repository.listItemsPage(
        limit: limit,
        offset: offset,
        searchQuery: searchQuery,
        type: type,
        categoryId: CategoryMapper.toApiCategoryId(categoryId),
      );
      final items = await _mapItemDtosToInventoryItems(itemDtos);
      return PaginatedInventoryItems(
        items: items,
        totalCount: total,
        hasMore: offset + items.length < total,
      );
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Stream<PaginatedInventoryItems> watchItemsPage({
    int limit = inventoryPageSize,
    int offset = 0,
    String? searchQuery,
    ItemType? type,
    String? categoryId,
  }) async* {
    final apiCategoryId = CategoryMapper.toApiCategoryId(categoryId);
    await for (final itemDtos in _repository.watchItemsPage(
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
      type: type,
      categoryId: apiCategoryId,
    )) {
      try {
        final total = await _repository.countItemsPage(
          searchQuery: searchQuery,
          type: type,
          categoryId: apiCategoryId,
        );
        final items = await _mapItemDtosToInventoryItems(itemDtos);
        yield PaginatedInventoryItems(
          items: items,
          totalCount: total,
          hasMore: offset + items.length < total,
        );
      } on DioException catch (error) {
        InventoryErrorMapper.mapAndThrow(error);
      }
    }
  }

  Future<List<InventoryItem>> _mapItemDtosToInventoryItems(
    List<ItemListDto> itemDtos,
  ) async {
    if (itemDtos.isEmpty) return const [];

    final stockByItem = await _repository.localStockQuantitiesForItems(
      itemDtos.map((dto) => dto.id),
    );

    return itemDtos.map((dto) {
      final stockQty = stockByItem[dto.id];
      return ItemMapper.fromListDto(
        dto,
        quantity: stockQty ?? _parseDecimal(dto.quantity),
        stockValue: stockQty == null ? null : 0,
        reservedQuantity: _parseDecimal(dto.reservedQuantity),
        availableForSale: _parseDecimal(dto.availableForSale),
      );
    }).toList();
  }

  Future<InventoryItem> getItem(String id) async {
    try {
      final dto = await fetchItemDetailDto(id);
      final localQty = await _repository.localStockQuantityForItem(id);

      try {
        final stockLevels = await _fetchAllPages<StockLevelDto>(
          fetchPage: (page) async {
            final response = await _repository.getStockLevels(
              StockLevelListQuery(page: page, itemId: id),
            );
            return (response.stockLevels, response.meta.total);
          },
        );
        final stock = StockLevelMapper.aggregateByItem(stockLevels)[id];
        final quantity = localQty != 0 ? localQty : (stock?.quantity ?? localQty);
        return ItemMapper.fromDetailDto(
          dto,
          quantity: quantity,
          stockValue: stock?.stockValue,
          reservedQuantity: _parseDecimal(dto.reservedQuantity),
          availableForSale: _parseDecimal(dto.availableForSale),
        );
      } on DioException {
        return ItemMapper.fromDetailDto(
          dto,
          quantity: localQty,
          reservedQuantity: _parseDecimal(dto.reservedQuantity),
          availableForSale: _parseDecimal(dto.availableForSale),
        );
      }
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<ItemDetailDto> fetchItemDetailDto(String id) async {
    try {
      return await _repository.getItem(id);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<Map<String, List<String>>> fetchAlternativesIndex() async {
    try {
      return await _repository.getAlternativesIndex();
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<InventoryItem> createItemFromForm(
    AddItemFormState form,
    List<InventoryUnit> units,
  ) async {
    final baseUnit =
        _resolveUnit(form.baseUnitId, units) ??
        (form.itemType == ItemType.service
            ? resolveDefaultServiceUnit(units)
            : null);
    if (baseUnit == null) {
      throw const InventoryException('Please select a base unit.');
    }

    final defaultGodown = form.godownId == null
        ? await getDefaultGodown()
        : null;
    final request = AddItemFormMapper.toCreateRequest(
      form,
      baseUnitShortName: baseUnit.shortName,
      openingGodownId: form.godownId ?? defaultGodown?.id,
      godownIdForLocation: form.godownId ?? defaultGodown?.id,
    );

    try {
      final dto = await _repository.createItem(request);
      return ItemMapper.fromDetailDto(dto);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) throw validation;
      InventoryErrorMapper.mapAndThrow(error);
    } on Object {
      rethrow;
    }
  }

  Future<InventoryItem> updateItemFromForm(
    String itemId,
    AddItemFormState form,
    List<InventoryUnit> units, {
    double? initialOpeningQty,
  }) async {
    final baseUnit =
        _resolveUnit(form.baseUnitId, units) ??
        (form.itemType == ItemType.service
            ? resolveDefaultServiceUnit(units)
            : null);
    if (baseUnit == null) {
      throw const InventoryException('Please select a base unit.');
    }

    final defaultGodown = form.godownId == null ? await getDefaultGodown() : null;
    final request = AddItemFormMapper.toUpdateRequest(
      form,
      baseUnitShortName: baseUnit.shortName,
      openingGodownId: form.godownId ?? defaultGodown?.id,
      godownIdForLocation: form.godownId ?? defaultGodown?.id,
      initialOpeningQty: initialOpeningQty,
    );

    try {
      final dto = await _repository.updateItem(itemId, request);
      return ItemMapper.fromDetailDto(
        dto,
        quantity: _parseDecimal(dto.quantity),
        reservedQuantity: _parseDecimal(dto.reservedQuantity),
        availableForSale: _parseDecimal(dto.availableForSale),
      );
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) throw validation;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repository.deleteItem(id);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> moveItemsToCategory({
    required List<String> itemIds,
    required String categoryId,
    required bool removeFromExistingCategory,
  }) async {
    final apiCategoryId = CategoryMapper.toApiCategoryId(categoryId);
    try {
      for (final itemId in itemIds) {
        final item = await getItem(itemId);
        final hasExistingCategory =
            item.categoryId != null &&
            item.categoryId != uncategorizedCategoryId;
        if (!removeFromExistingCategory && hasExistingCategory) {
          continue;
        }

        await _repository.updateItem(
          itemId,
          UpdateItemRequest(
            categoryId: apiCategoryId,
            clearCategory: apiCategoryId == null,
          ),
        );
      }
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<List<ProductTransaction>> fetchProductTransactions(
    String itemId,
  ) async {
    final movements = await _repository.listLocalMovementsForItem(itemId);
    return movements.map(MovementMapper.toProductTransaction).toList();
  }

  List<InventoryCategory> withUncategorizedCategory({
    required List<InventoryCategory> categories,
    required List<InventoryItem> items,
  }) {
    return CategoryMapper.withSyncedItemCounts(
      categories: categories,
      items: items,
    );
  }

  InventoryUnit? _resolveUnit(String? unitId, List<InventoryUnit> units) {
    if (unitId == null) return null;
    for (final unit in units) {
      if (unit.id == unitId) return unit;
    }
    return null;
  }

  double? _parseDecimal(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  String _formatDecimal(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(4);
  }

  Future<List<T>> _fetchAllPages<T>({
    required Future<(List<T>, int)> Function(int page) fetchPage,
  }) async {
    final all = <T>[];
    var page = 1;
    var total = 0;

    do {
      final (batch, batchTotal) = await fetchPage(page);
      all.addAll(batch);
      total = batchTotal;
      page++;
    } while (all.length < total);

    return all;
  }
}
