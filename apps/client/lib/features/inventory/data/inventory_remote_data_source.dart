import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/inventory/models/dto/brand_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/category_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/godown_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/item_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/item_location_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/item_summary_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/movement_dto.dart';
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
import 'package:dio/dio.dart';

class InventoryRemoteDataSource {
  InventoryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedCategoriesDto> listCategories(CategoryListQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryCategories,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(response, PaginatedCategoriesDto.fromJson);
  }

  Future<CategoryDto> getCategory(String id) async {
    return _parseSingle(
      response: await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.inventoryCategory(id),
      ),
      parser: CategoryDto.fromJson,
    );
  }

  Future<CategoryDto> createCategory(CreateCategoryRequest request) async {
    return _parseSingle(
      response: await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.inventoryCategories,
        data: request.toJson(),
      ),
      parser: CategoryDto.fromJson,
    );
  }

  Future<CategoryDto> updateCategory(
    String id,
    UpdateCategoryRequest request,
  ) async {
    return _parseSingle(
      response: await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.inventoryCategory(id),
        data: request.toJson(),
      ),
      parser: CategoryDto.fromJson,
    );
  }

  Future<void> deleteCategory(String id) async {
    await _dio.delete<void>(ApiEndpoints.inventoryCategory(id));
  }

  Future<PaginatedBrandsDto> listBrands(BrandListQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryBrands,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(response, PaginatedBrandsDto.fromJson);
  }

  Future<BrandDto> getBrand(String id) async {
    return _parseSingle(
      response: await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.inventoryBrand(id),
      ),
      parser: BrandDto.fromJson,
    );
  }

  Future<BrandDto> createBrand(CreateBrandRequest request) async {
    return _parseSingle(
      response: await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.inventoryBrands,
        data: request.toJson(),
      ),
      parser: BrandDto.fromJson,
    );
  }

  Future<BrandDto> updateBrand(String id, UpdateBrandRequest request) async {
    return _parseSingle(
      response: await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.inventoryBrand(id),
        data: request.toJson(),
      ),
      parser: BrandDto.fromJson,
    );
  }

  Future<void> deleteBrand(String id) async {
    await _dio.delete<void>(ApiEndpoints.inventoryBrand(id));
  }

  Future<PaginatedUnitsDto> listUnits(UnitListQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryUnits,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(response, PaginatedUnitsDto.fromJson);
  }

  Future<UnitDetailDto> getUnit(String id) async {
    return _parseSingle(
      response: await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.inventoryUnit(id),
      ),
      parser: UnitDetailDto.fromJson,
    );
  }

  Future<UnitDetailDto> createUnit(CreateUnitRequest request) async {
    return _parseSingle(
      response: await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.inventoryUnits,
        data: request.toJson(),
      ),
      parser: UnitDetailDto.fromJson,
    );
  }

  Future<UnitDetailDto> updateUnit(String id, UpdateUnitRequest request) async {
    return _parseSingle(
      response: await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.inventoryUnit(id),
        data: request.toJson(),
      ),
      parser: UnitDetailDto.fromJson,
    );
  }

  Future<void> deleteUnit(String id) async {
    await _dio.delete<void>(ApiEndpoints.inventoryUnit(id));
  }

  Future<PaginatedUnitConversionsDto> listUnitConversions(
    UnitConversionListQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryUnitConversions,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(response, PaginatedUnitConversionsDto.fromJson);
  }

  Future<UnitConversionDto> createUnitConversion(
    CreateUnitConversionRequest request,
  ) async {
    return _parseSingle(
      response: await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.inventoryUnitConversions,
        data: request.toJson(),
      ),
      parser: UnitConversionDto.fromJson,
    );
  }

  Future<UnitConversionDto> updateUnitConversion(
    String id,
    UpdateUnitConversionRequest request,
  ) async {
    return _parseSingle(
      response: await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.inventoryUnitConversion(id),
        data: request.toJson(),
      ),
      parser: UnitConversionDto.fromJson,
    );
  }

  Future<void> deleteUnitConversion(String id) async {
    await _dio.delete<void>(ApiEndpoints.inventoryUnitConversion(id));
  }

  Future<PaginatedGodownsDto> listGodowns(GodownListQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryGodowns,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(response, PaginatedGodownsDto.fromJson);
  }

  Future<GodownDto> getGodown(String id) async {
    return _parseSingle(
      response: await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.inventoryGodown(id),
      ),
      parser: GodownDto.fromJson,
    );
  }

  Future<GodownDto> createGodown(CreateGodownRequest request) async {
    return _parseSingle(
      response: await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.inventoryGodowns,
        data: request.toJson(),
      ),
      parser: GodownDto.fromJson,
    );
  }

  Future<GodownDto> updateGodown(String id, UpdateGodownRequest request) async {
    return _parseSingle(
      response: await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.inventoryGodown(id),
        data: request.toJson(),
      ),
      parser: GodownDto.fromJson,
    );
  }

  Future<void> deleteGodown(String id) async {
    await _dio.delete<void>(ApiEndpoints.inventoryGodown(id));
  }

  Future<PaginatedItemsDto> listItems(ItemListQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryItems,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(response, PaginatedItemsDto.fromJson);
  }

  Future<ItemDetailDto> getItem(String id) async {
    return _parseSingle(
      response: await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.inventoryItem(id),
      ),
      parser: ItemDetailDto.fromJson,
    );
  }

  Future<Map<String, List<String>>> getAlternativesIndex() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryItemsAlternativesIndex,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) return const {};

    final index = <String, List<String>>{};
    for (final entry in data.entries) {
      final value = entry.value;
      if (value is List) {
        index[entry.key] = value.whereType<String>().toList(growable: false);
      }
    }
    return index;
  }

  Future<ItemDetailDto> createItem(CreateItemRequest request) async {
    return _parseSingle(
      response: await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.inventoryItems,
        data: request.toJson(),
      ),
      parser: ItemDetailDto.fromJson,
    );
  }

  Future<ItemDetailDto> updateItem(String id, UpdateItemRequest request) async {
    return _parseSingle(
      response: await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.inventoryItem(id),
        data: request.toJson(),
      ),
      parser: ItemDetailDto.fromJson,
    );
  }

  Future<void> deleteItem(String id) async {
    await _dio.delete<void>(ApiEndpoints.inventoryItem(id));
  }

  Future<List<ItemImageDto>> listItemImages(String itemId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryItemImages(itemId),
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ItemImageDto.fromJson)
        .toList();
  }

  Future<ItemImageDto> createItemImage(
    String itemId,
    CreateItemImageRequest request,
  ) async {
    return _parseSingle(
      response: await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.inventoryItemImages(itemId),
        data: request.toJson(),
      ),
      parser: ItemImageDto.fromJson,
    );
  }

  Future<ItemImageDto> updateItemImage(
    String itemId,
    String imageId,
    UpdateItemImageRequest request,
  ) async {
    return _parseSingle(
      response: await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.inventoryItemImage(itemId, imageId),
        data: request.toJson(),
      ),
      parser: ItemImageDto.fromJson,
    );
  }

  Future<void> deleteItemImage(String itemId, String imageId) async {
    await _dio.delete<void>(ApiEndpoints.inventoryItemImage(itemId, imageId));
  }

  Future<List<TierPriceDto>> getItemTierPrices(String itemId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryItemTierPrices(itemId),
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(TierPriceDto.fromJson)
        .toList();
  }

  Future<List<TierPriceDto>> upsertItemTierPrices(
    String itemId,
    UpsertTierPricesRequest request,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.inventoryItemTierPrices(itemId),
      data: request.toJson(),
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(TierPriceDto.fromJson)
        .toList();
  }

  Future<void> deleteItemTierPrice(String itemId, String tier) async {
    await _dio.delete<void>(ApiEndpoints.inventoryItemTierPrice(itemId, tier));
  }

  Future<PaginatedItemLocationsDto> listItemLocations({
    int page = 1,
    int limit = 100,
    String? itemId,
    String? godownId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryItemLocations,
      queryParameters: {
        'page': page,
        'limit': limit,
        'item_id': ?itemId,
        'godown_id': ?godownId,
        'sort': 'created_at',
        'order': 'desc',
      },
    );
    return _parsePaginated(response, PaginatedItemLocationsDto.fromJson);
  }

  Future<ItemLocationDto> createItemLocation(
    CreateItemLocationRecordRequest request,
  ) async {
    return _parseSingle(
      response: await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.inventoryItemLocations,
        data: request.toJson(),
      ),
      parser: ItemLocationDto.fromJson,
    );
  }

  Future<ItemLocationDto> updateItemLocation(
    String id,
    UpdateItemLocationRecordRequest request,
  ) async {
    return _parseSingle(
      response: await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.inventoryItemLocation(id),
        data: request.toJson(),
      ),
      parser: ItemLocationDto.fromJson,
    );
  }

  Future<void> deleteItemLocation(String id) async {
    await _dio.delete<void>(ApiEndpoints.inventoryItemLocation(id));
  }

  Future<PaginatedStockLevelsDto> listStockLevels(
    StockLevelListQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryStockLevels,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(response, PaginatedStockLevelsDto.fromJson);
  }

  Future<StockLevelDto> getStockLevel(String id) async {
    return _parseSingle(
      response: await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.inventoryStockLevel(id),
      ),
      parser: StockLevelDto.fromJson,
    );
  }

  Future<PaginatedMovementsDto> listMovements(MovementListQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryMovements,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(response, PaginatedMovementsDto.fromJson);
  }

  Future<MovementDto> getMovement(String id) async {
    return _parseSingle(
      response: await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.inventoryMovement(id),
      ),
      parser: MovementDto.fromJson,
    );
  }

  Future<MovementDto> createMovement(CreateMovementRequest request) async {
    return _parseSingle(
      response: await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.inventoryMovements,
        data: request.toJson(),
      ),
      parser: MovementDto.fromJson,
    );
  }

  Future<PaginatedPriceHistoryDto> getItemPriceHistory(
    String itemId, {
    int page = 1,
    int limit = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryItemPriceHistory(itemId),
      queryParameters: {
        'page': page,
        'limit': limit,
        'sort': 'created_at',
        'order': 'desc',
      },
    );
    return _parsePaginated(response, PaginatedPriceHistoryDto.fromJson);
  }

  Future<PaginatedPriceHistoryDto> listPriceHistory(
    PriceHistoryListQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.inventoryPriceHistory,
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginated(response, PaginatedPriceHistoryDto.fromJson);
  }

  Future<PriceHistoryDto> getPriceHistoryRecord(String id) async {
    return _parseSingle(
      response: await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.inventoryPriceHistoryRecord(id),
      ),
      parser: PriceHistoryDto.fromJson,
    );
  }

  Future<Map<String, dynamic>> geminiBarcodeLookup(String barcode) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.barcodeGeminiLookup,
      data: {'barcode': barcode},
    );
    return response.data?['data'] as Map<String, dynamic>;
  }

  T _parsePaginated<T>(
    Response<Map<String, dynamic>> response,
    T Function(Map<String, dynamic>) parser,
  ) {
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid paginated response',
      );
    }
    return parser(data);
  }

  T _parseSingle<T>({
    required Response<Map<String, dynamic>> response,
    required T Function(Map<String, dynamic>) parser,
  }) {
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid single resource response',
      );
    }
    return parser(data);
  }
}
