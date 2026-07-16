import 'package:billing_baba/features/inventory/data/inventory_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
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

class InventoryRepository {
  InventoryRepository({
    required this._remote,
    this._local,
  });

  final InventoryRemoteDataSource _remote;
  // ignore: unused_field
  final InventoryLocalDataSource? _local;

  Future<PaginatedCategoriesDto> getCategories(CategoryListQuery query) =>
      _remote.listCategories(query);

  Future<CategoryDto> getCategory(String id) => _remote.getCategory(id);

  Future<CategoryDto> createCategory(CreateCategoryRequest request) =>
      _remote.createCategory(request);

  Future<CategoryDto> updateCategory(
    String id,
    UpdateCategoryRequest request,
  ) => _remote.updateCategory(id, request);

  Future<void> deleteCategory(String id) => _remote.deleteCategory(id);

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
