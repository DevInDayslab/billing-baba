import 'package:billing_baba/features/inventory/data/models/item_alternative_dto.dart';

class RecommendedItemDto {
  const RecommendedItemDto({
    required this.id,
    required this.name,
    required this.salePrice,
    required this.stockQuantity,
    this.barcode,
    this.brandName,
    this.categoryName,
  });

  factory RecommendedItemDto.fromJson(Map<String, dynamic> json) {
    return RecommendedItemDto(
      id: json['id'] as String,
      name: json['name'] as String,
      barcode: json['barcode'] as String?,
      brandName: json['brand_name'] as String?,
      categoryName: json['category_name'] as String?,
      salePrice: _parseDouble(json['sale_price']),
      stockQuantity: _parseDouble(json['stock_quantity']),
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

class ItemRecommendationsDto {
  const ItemRecommendationsDto({
    required this.manuallyConfigured,
    required this.sameBrandCategory,
    required this.sameCategory,
  });

  factory ItemRecommendationsDto.fromJson(Map<String, dynamic> json) {
    return ItemRecommendationsDto(
      manuallyConfigured: _parseAlternativeList(json['manually_configured']),
      sameBrandCategory: _parseRecommendedList(json['same_brand_category']),
      sameCategory: _parseRecommendedList(json['same_category']),
    );
  }

  final List<ItemAlternativeDto> manuallyConfigured;
  final List<RecommendedItemDto> sameBrandCategory;
  final List<RecommendedItemDto> sameCategory;

  Map<String, dynamic> toJson() => {
    'manually_configured': manuallyConfigured
        .map((item) => item.toJson())
        .toList(),
    'same_brand_category': sameBrandCategory
        .map((item) => item.toJson())
        .toList(),
    'same_category': sameCategory.map((item) => item.toJson()).toList(),
  };
}

List<ItemAlternativeDto> _parseAlternativeList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(ItemAlternativeDto.fromJson)
      .toList();
}

List<RecommendedItemDto> _parseRecommendedList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(RecommendedItemDto.fromJson)
      .toList();
}

double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
