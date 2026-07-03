import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_repository.dart';
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
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'inventory_error_mapper.dart'
    show InventoryException, InventoryOfflineException;

part 'inventory_service.g.dart';

@Riverpod(keepAlive: true)
Future<InventoryService> inventoryService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return InventoryService(
    repository: InventoryRepository(
      remote: InventoryRemoteDataSource(api.dio),
    ),
  );
}

class InventoryService {
  InventoryService({required this._repository});

  final InventoryRepository _repository;

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
        UpdateItemImageRequest(imageUrl: imageUrl?.trim(), isPrimary: isPrimary),
      );
      return ItemImageMapper.fromDto(dto);
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<void> deleteItemImage(String itemId, String imageId) async {
    try {
      await _repository.deleteItemImage(itemId, imageId);
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
    try {
      await _repository.createMovement(request);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<List<InventoryItem>> fetchItems({
    String? searchQuery,
    ItemType? type,
    String? categoryId,
  }) async {
    try {
      final itemDtos = await _fetchAllPages<ItemListDto>(
        fetchPage: (page) async {
          final response = await _repository.listItems(
            ItemListQuery(
              page: page,
              limit: 100,
              q: searchQuery,
              type: type,
              categoryId: CategoryMapper.toApiCategoryId(categoryId),
            ),
          );
          return (response.items, response.meta.total);
        },
      );

      final stockLevels = await _fetchAllPages<StockLevelDto>(
        fetchPage: (page) async {
          final response = await _repository.getStockLevels(
            StockLevelListQuery(page: page),
          );
          return (response.stockLevels, response.meta.total);
        },
      );
      final stockByItem = StockLevelMapper.aggregateByItem(stockLevels);

      return itemDtos.map((dto) {
        final stock = stockByItem[dto.id];
        return ItemMapper.fromListDto(
          dto,
          quantity: stock?.quantity,
          stockValue: stock?.stockValue,
        );
      }).toList();
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<InventoryItem> getItem(String id) async {
    try {
      final dto = await _repository.getItem(id);
      final stockLevels = await _fetchAllPages<StockLevelDto>(
        fetchPage: (page) async {
          final response = await _repository.getStockLevels(
            StockLevelListQuery(page: page, itemId: id),
          );
          return (response.stockLevels, response.meta.total);
        },
      );
      final stock = StockLevelMapper.aggregateByItem(stockLevels)[id];
      return ItemMapper.fromDetailDto(
        dto,
        quantity: stock?.quantity,
        stockValue: stock?.stockValue,
      );
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<InventoryItem> createItemFromForm(
    AddItemFormState form,
    List<InventoryUnit> units,
  ) async {
    final baseUnit = _resolveUnit(form.baseUnitId, units);
    if (baseUnit == null) {
      throw const InventoryException('Please select a base unit.');
    }

    final defaultGodown = form.godownId == null ? await getDefaultGodown() : null;
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
      if (validation != null) rethrow;
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  Future<InventoryItem> updateItemFromForm(
    String itemId,
    AddItemFormState form,
    List<InventoryUnit> units,
  ) async {
    final baseUnit = _resolveUnit(form.baseUnitId, units);
    if (baseUnit == null) {
      throw const InventoryException('Please select a base unit.');
    }

    final request = AddItemFormMapper.toUpdateRequest(
      form,
      baseUnitShortName: baseUnit.shortName,
    );

    try {
      await _repository.updateItem(itemId, request);
      final tierPrices = AddItemFormMapper.tierPricesForUpsert(form);
      if (tierPrices.isNotEmpty) {
        await _repository.upsertItemTierPrices(
          itemId,
          UpsertTierPricesRequest(tierPrices: tierPrices),
        );
      }
      return getItem(itemId);
    } on DioException catch (error) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) rethrow;
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
    try {
      final movements = await _fetchAllPages(
        fetchPage: (page) async {
          final response = await _repository.getMovements(
            MovementListQuery(page: page, itemId: itemId),
          );
          return (response.movements, response.meta.total);
        },
      );
      return movements
          .map(MovementMapper.toProductTransaction)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } on DioException catch (error) {
      InventoryErrorMapper.mapAndThrow(error);
    }
  }

  List<InventoryCategory> withUncategorizedCategory({
    required List<InventoryCategory> categories,
    required List<InventoryItem> items,
  }) {
    final uncategorizedCount = items
        .where(
          (item) =>
              item.categoryId == null ||
              item.categoryId == uncategorizedCategoryId,
        )
        .length;

    return [
      CategoryMapper.uncategorized(itemCount: uncategorizedCount),
      ...categories.where((category) => !category.isUncategorized),
    ];
  }

  InventoryUnit? _resolveUnit(String? unitId, List<InventoryUnit> units) {
    if (unitId == null) return null;
    for (final unit in units) {
      if (unit.id == unitId) return unit;
    }
    return null;
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
