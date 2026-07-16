import 'package:billing_baba/features/inventory/models/item_model.dart';

class ItemListQuery {
  const ItemListQuery({
    this.page = 1,
    this.limit = 20,
    this.q,
    this.type,
    this.categoryId,
    this.brandId,
    this.hsn,
    this.barcode,
    this.sort = 'name',
    this.order = 'asc',
  });

  final int page;
  final int limit;
  final String? q;
  final ItemType? type;
  final String? categoryId;
  final String? brandId;
  final String? hsn;
  final String? barcode;
  final String sort;
  final String order;

  ItemListQuery copyWith({
    int? page,
    int? limit,
    String? q,
    ItemType? type,
    String? categoryId,
    String? brandId,
  }) {
    return ItemListQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      q: q ?? this.q,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      hsn: hsn,
      barcode: barcode,
      sort: sort,
      order: order,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (q != null && q!.isNotEmpty) 'q': q,
    if (type != null) 'type': type == ItemType.product ? 'product' : 'service',
    if (categoryId != null) 'category_id': categoryId,
    if (brandId != null) 'brand_id': brandId,
    if (hsn != null && hsn!.isNotEmpty) 'hsn': hsn,
    if (barcode != null && barcode!.isNotEmpty) 'barcode': barcode,
    'sort': sort,
    'order': order,
  };
}

class CreateItemLocationRequest {
  const CreateItemLocationRequest({
    required this.godownId,
    this.rack,
    this.shelf,
  });

  final String godownId;
  final String? rack;
  final String? shelf;

  Map<String, dynamic> toJson() => {
    'godown_id': godownId,
    if (rack != null && rack!.isNotEmpty) 'rack': rack,
    if (shelf != null && shelf!.isNotEmpty) 'shelf': shelf,
  };
}

class CreateItemTierPriceRequest {
  const CreateItemTierPriceRequest({
    required this.pricingTier,
    required this.price,
  });

  final String pricingTier;
  final String price;

  Map<String, dynamic> toJson() => {
    'pricing_tier': pricingTier,
    'price': price,
  };
}

class CreateItemRequest {
  const CreateItemRequest({
    required this.name,
    required this.baseUnit,
    this.description,
    this.itemType = 'product',
    this.hsnCode,
    this.barcode,
    this.categoryId,
    this.brandId,
    this.salePrice = '0',
    this.purchasePrice = '0',
    this.mrp,
    this.marketPrice,
    this.reorderLevel,
    this.hasStockTracking = true,
    this.tierPrices = const [],
    this.primaryImageUrl,
    this.openingQuantity,
    this.openingCostPerUnit,
    this.openingGodownId,
    this.location,
  });

  final String name;
  final String? description;
  final String itemType;
  final String? hsnCode;
  final String? barcode;
  final String? categoryId;
  final String? brandId;
  final String baseUnit;
  final String salePrice;
  final String purchasePrice;
  final String? mrp;
  final String? marketPrice;
  final String? reorderLevel;
  final bool hasStockTracking;
  final List<CreateItemTierPriceRequest> tierPrices;
  final String? primaryImageUrl;
  final String? openingQuantity;
  final String? openingCostPerUnit;
  final String? openingGodownId;
  final CreateItemLocationRequest? location;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty)
        'description': description,
      'item_type': itemType,
      if (hsnCode != null && hsnCode!.isNotEmpty) 'hsn_code': hsnCode,
      if (barcode != null && barcode!.isNotEmpty) 'barcode': barcode,
      if (categoryId != null) 'category_id': categoryId,
      if (brandId != null) 'brand_id': brandId,
      'base_unit': baseUnit,
      'sale_price': salePrice,
      'purchase_price': purchasePrice,
      if (mrp != null) 'mrp': mrp,
      if (marketPrice != null) 'market_price': marketPrice,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      'has_stock_tracking': hasStockTracking,
      if (tierPrices.isNotEmpty)
        'tier_prices': tierPrices.map((t) => t.toJson()).toList(),
      if (primaryImageUrl != null) 'primary_image_url': primaryImageUrl,
      if (openingQuantity != null) 'opening_quantity': openingQuantity,
      if (openingCostPerUnit != null)
        'opening_cost_per_unit': openingCostPerUnit,
      if (openingGodownId != null) 'opening_godown_id': openingGodownId,
      if (location != null) 'location': location!.toJson(),
    };
  }
}

class UpdateItemRequest {
  const UpdateItemRequest({
    this.name,
    this.description,
    this.itemType,
    this.hsnCode,
    this.barcode,
    this.categoryId,
    this.clearCategory = false,
    this.brandId,
    this.clearBrand = false,
    this.baseUnit,
    this.salePrice,
    this.purchasePrice,
    this.mrp,
    this.marketPrice,
    this.reorderLevel,
    this.hasStockTracking,
    this.primaryImageUrl,
  });

  final String? name;
  final String? description;
  final String? itemType;
  final String? hsnCode;
  final String? barcode;
  final String? categoryId;
  final bool clearCategory;
  final String? brandId;
  final bool clearBrand;
  final String? baseUnit;
  final String? salePrice;
  final String? purchasePrice;
  final String? mrp;
  final String? marketPrice;
  final String? reorderLevel;
  final bool? hasStockTracking;
  final String? primaryImageUrl;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (itemType != null) json['item_type'] = itemType;
    if (hsnCode != null) json['hsn_code'] = hsnCode;
    if (barcode != null) json['barcode'] = barcode;
    if (clearCategory) {
      json['category_id'] = null;
    } else if (categoryId != null) {
      json['category_id'] = categoryId;
    }
    if (clearBrand) {
      json['brand_id'] = null;
    } else if (brandId != null) {
      json['brand_id'] = brandId;
    }
    if (baseUnit != null) json['base_unit'] = baseUnit;
    if (salePrice != null) json['sale_price'] = salePrice;
    if (purchasePrice != null) json['purchase_price'] = purchasePrice;
    if (mrp != null) json['mrp'] = mrp;
    if (marketPrice != null) json['market_price'] = marketPrice;
    if (reorderLevel != null) json['reorder_level'] = reorderLevel;
    if (hasStockTracking != null) {
      json['has_stock_tracking'] = hasStockTracking;
    }
    if (primaryImageUrl != null) json['primary_image_url'] = primaryImageUrl;
    return json;
  }
}

class StockLevelListQuery {
  const StockLevelListQuery({
    this.page = 1,
    this.limit = 100,
    this.itemId,
    this.godownId,
    this.lowStock,
    this.q,
    this.sort = 'created_at',
    this.order = 'desc',
  });

  final int page;
  final int limit;
  final String? itemId;
  final String? godownId;
  final bool? lowStock;
  final String? q;
  final String sort;
  final String order;

  StockLevelListQuery copyWith({int? page, int? limit, String? itemId}) {
    return StockLevelListQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      itemId: itemId ?? this.itemId,
      godownId: godownId,
      lowStock: lowStock,
      q: q,
      sort: sort,
      order: order,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (itemId != null) 'item_id': itemId,
    if (godownId != null) 'godown_id': godownId,
    if (lowStock != null) 'low_stock': lowStock,
    if (q != null && q!.isNotEmpty) 'q': q,
    'sort': sort,
    'order': order,
  };
}

class MovementListQuery {
  const MovementListQuery({
    this.page = 1,
    this.limit = 100,
    this.itemId,
    this.godownId,
    this.movementType,
    this.sort = 'created_at',
    this.order = 'desc',
  });

  final int page;
  final int limit;
  final String? itemId;
  final String? godownId;
  final String? movementType;
  final String sort;
  final String order;

  MovementListQuery copyWith({int? page, int? limit, String? itemId}) {
    return MovementListQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      itemId: itemId ?? this.itemId,
      godownId: godownId,
      movementType: movementType,
      sort: sort,
      order: order,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (itemId != null) 'item_id': itemId,
    if (godownId != null) 'godown_id': godownId,
    if (movementType != null) 'movement_type': movementType,
    'sort': sort,
    'order': order,
  };
}

class PriceHistoryListQuery {
  const PriceHistoryListQuery({
    this.page = 1,
    this.limit = 100,
    this.itemId,
  });

  final int page;
  final int limit;
  final String? itemId;

  PriceHistoryListQuery copyWith({int? page, int? limit, String? itemId}) {
    return PriceHistoryListQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      itemId: itemId ?? this.itemId,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (itemId != null) 'item_id': itemId,
  };
}

class CreateItemLocationRecordRequest {
  const CreateItemLocationRecordRequest({
    required this.itemId,
    required this.godownId,
    this.rack,
    this.shelf,
    this.photoUrl,
  });

  final String itemId;
  final String godownId;
  final String? rack;
  final String? shelf;
  final String? photoUrl;

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'godown_id': godownId,
    if (rack != null) 'rack': rack,
    if (shelf != null) 'shelf': shelf,
    if (photoUrl != null) 'photo_url': photoUrl,
  };
}

class UpdateItemLocationRecordRequest {
  const UpdateItemLocationRecordRequest({
    this.godownId,
    this.rack,
    this.shelf,
    this.photoUrl,
  });

  final String? godownId;
  final String? rack;
  final String? shelf;
  final String? photoUrl;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (godownId != null) json['godown_id'] = godownId;
    if (rack != null) json['rack'] = rack;
    if (shelf != null) json['shelf'] = shelf;
    if (photoUrl != null) json['photo_url'] = photoUrl;
    return json;
  }
}

class CreateItemImageRequest {
  const CreateItemImageRequest({
    required this.imageUrl,
    this.sortOrder = 0,
    this.isPrimary = false,
  });

  final String imageUrl;
  final int sortOrder;
  final bool isPrimary;

  Map<String, dynamic> toJson() => {
    'image_url': imageUrl,
    'sort_order': sortOrder,
    'is_primary': isPrimary,
  };
}

class UpdateItemImageRequest {
  const UpdateItemImageRequest({
    this.imageUrl,
    this.sortOrder,
    this.isPrimary,
  });

  final String? imageUrl;
  final int? sortOrder;
  final bool? isPrimary;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (imageUrl != null) json['image_url'] = imageUrl;
    if (sortOrder != null) json['sort_order'] = sortOrder;
    if (isPrimary != null) json['is_primary'] = isPrimary;
    return json;
  }
}

class UpsertTierPricesRequest {
  const UpsertTierPricesRequest({required this.tierPrices});
  final List<CreateItemTierPriceRequest> tierPrices;

  Map<String, dynamic> toJson() => {
    'tier_prices': tierPrices.map((t) => t.toJson()).toList(),
  };
}
