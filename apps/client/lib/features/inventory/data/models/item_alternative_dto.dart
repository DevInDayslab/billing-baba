class AlternativeItemDto {
  const AlternativeItemDto({
    required this.id,
    required this.name,
    required this.salePrice,
    required this.stockQuantity,
    this.barcode,
    this.brandName,
    this.categoryName,
  });

  factory AlternativeItemDto.fromJson(Map<String, dynamic> json) {
    return AlternativeItemDto(
      id: json['id'] as String,
      name: json['name'] as String,
      barcode: json['barcode'] as String?,
      brandName: json['brandName'] as String?,
      categoryName: json['categoryName'] as String?,
      salePrice: _parseDouble(json['salePrice']),
      stockQuantity: _parseDouble(json['stockQuantity']),
    );
  }

  final String id;
  final String name;
  final String? barcode;
  final String? brandName;
  final String? categoryName;
  final double salePrice;
  final double stockQuantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (barcode != null) 'barcode': barcode,
    if (brandName != null) 'brand_name': brandName,
    if (categoryName != null) 'category_name': categoryName,
    'sale_price': salePrice,
    'stock_quantity': stockQuantity,
  };
}

class ItemAlternativeDto {
  const ItemAlternativeDto({
    required this.id,
    required this.itemId,
    required this.alternativeItemId,
    required this.sortOrder,
    required this.alternativeItem,
  });

  factory ItemAlternativeDto.fromJson(Map<String, dynamic> json) {
    return ItemAlternativeDto(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      alternativeItemId: json['alternativeItemId'] as String,
      sortOrder: json['sortOrder'] as int,
      alternativeItem: AlternativeItemDto.fromJson(
        json['alternativeItem'] as Map<String, dynamic>,
      ),
    );
  }

  final String id;
  final String itemId;
  final String alternativeItemId;
  final int sortOrder;
  final AlternativeItemDto alternativeItem;

  Map<String, dynamic> toJson() => {
    'id': id,
    'item_id': itemId,
    'alternative_item_id': alternativeItemId,
    'sort_order': sortOrder,
    'alternative_item': alternativeItem.toJson(),
  };
}

double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
