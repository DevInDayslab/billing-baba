import 'package:billing_baba/features/inventory/models/dto/item_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/stock_level_dto.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/models/item_location_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/mappers/category_mapper.dart';
import 'package:billing_baba/features/inventory/models/tier_price_model.dart';

abstract final class ItemMapper {
  static InventoryItem fromListDto(
    ItemListDto dto, {
    double? quantity,
    double? stockValue,
    double? reservedQuantity,
    double? availableForSale,
  }) {
    final parsedQuantity = _parseMoney(dto.quantity) ?? quantity;
    final parsedReserved = _parseMoney(dto.reservedQuantity) ?? reservedQuantity;
    final parsedAvailable =
        _parseMoney(dto.availableForSale) ?? availableForSale;

    return InventoryItem(
      id: dto.id,
      name: dto.name,
      type: dto.itemType == 'service' ? ItemType.service : ItemType.product,
      quantity: parsedQuantity,
      salePrice: _parseMoney(dto.salePrice),
      stockValue: stockValue,
      categoryId: CategoryMapper.fromApiCategoryId(dto.categoryId),
      availableForSale: parsedAvailable ??
          (parsedQuantity != null && parsedReserved != null
              ? parsedQuantity - parsedReserved
              : parsedQuantity),
      reservedQuantity: parsedReserved,
      description: dto.description,
      hsnCode: dto.hsnCode,
      barcode: dto.barcode,
      brandId: dto.brandId,
      baseUnitShortName: dto.baseUnit,
      purchasePrice: _parseMoney(dto.purchasePrice),
      mrp: _parseMoney(dto.mrp),
      reorderLevel: _parseMoney(dto.reorderLevel),
      primaryImageUrl: dto.primaryImageUrl,
      isRawMaterial: dto.itemType == 'raw_material',
      shortName: dto.shortName,
      alias: dto.alias,
      searchKeywords: dto.searchKeywords,
      defaultTaxRate: _parseMoney(dto.defaultTaxRate),
      alternativeItemIds: dto.alternativeItemIds,
    );
  }

  static InventoryItem fromDetailDto(
    ItemDetailDto dto, {
    double? quantity,
    double? stockValue,
    double? reservedQuantity,
    double? availableForSale,
  }) {
    final _ = double.tryParse(dto.openingStock?.totalQuantity ?? '');
    return fromListDto(
      ItemListDto(
        id: dto.id,
        name: dto.name,
        description: dto.description,
        itemType: dto.itemType,
        hasStockTracking: dto.hasStockTracking,
        categoryId: dto.categoryId,
        category: dto.category,
        brandId: dto.brandId,
        brand: dto.brand,
        hsnCode: dto.hsnCode,
        barcode: dto.barcode,
        baseUnit: dto.baseUnit,
        baseUnitDetail: dto.baseUnitDetail,
        salePrice: dto.salePrice,
        purchasePrice: dto.purchasePrice,
        mrp: dto.mrp,
        marketPrice: dto.marketPrice,
        reorderLevel: dto.reorderLevel,
        primaryImageUrl: dto.primaryImageUrl,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
        quantity: dto.quantity,
        reservedQuantity: dto.reservedQuantity,
        availableForSale: dto.availableForSale,
        shortName: dto.shortName,
        alias: dto.alias,
        searchKeywords: dto.searchKeywords,
        defaultTaxRate: dto.defaultTaxRate,
        alternativeItemIds: dto.alternativeItemIds,
      ),
      quantity: quantity ?? _parseMoney(dto.quantity),
      stockValue: stockValue,
      reservedQuantity: _parseMoney(dto.reservedQuantity),
      availableForSale: _parseMoney(dto.availableForSale),
    );
  }

  static List<TierPriceModel> tierPricesFromDetail(ItemDetailDto dto) {
    return dto.tierPrices
        .map(
          (tier) => TierPriceModel(
            pricingTier: tier.pricingTier,
            price: _parseMoney(tier.price) ?? 0,
          ),
        )
        .toList();
  }

  static List<ItemImageModel> imagesFromDetail(ItemDetailDto dto) {
    return dto.images
        .map(
          (image) => ItemImageModel(
            id: image.id,
            imageUrl: image.imageUrl,
            sortOrder: image.sortOrder,
            isPrimary: image.isPrimary,
          ),
        )
        .toList();
  }

  static List<ItemLocationModel> locationsFromDetail(ItemDetailDto dto) {
    return dto.locations
        .map(
          (location) => ItemLocationModel(
            id: location.id,
            itemId: dto.id,
            godownId: location.godownId,
            rack: location.rack,
            shelf: location.shelf,
          ),
        )
        .toList();
  }

  static double? _parseMoney(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }
}

abstract final class StockLevelMapper {
  static Map<String, ({double quantity, double stockValue})> aggregateByItem(
    List<StockLevelDto> levels,
  ) {
    final totals = <String, ({double quantity, double stockValue})>{};

    for (final level in levels) {
      final qty = double.tryParse(level.quantity) ?? 0;
      final cost = double.tryParse(level.averageCost) ?? 0;
      final existing = totals[level.itemId];
      final nextQty = (existing?.quantity ?? 0) + qty;
      final nextValue = (existing?.stockValue ?? 0) + (qty * cost);
      totals[level.itemId] = (quantity: nextQty, stockValue: nextValue);
    }

    return totals;
  }
}
