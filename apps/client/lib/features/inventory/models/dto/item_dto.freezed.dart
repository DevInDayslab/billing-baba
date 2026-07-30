// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemListDto {

 String get id; String get name;@JsonKey(name: 'item_type') String get itemType;@JsonKey(name: 'has_stock_tracking') bool get hasStockTracking;@JsonKey(name: 'base_unit') String get baseUnit;@JsonKey(name: 'sale_price') String get salePrice;@JsonKey(name: 'purchase_price') String get purchasePrice;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;@JsonKey(name: 'short_name') String? get shortName; String? get alias;@JsonKey(name: 'search_keywords') List<String> get searchKeywords;@JsonKey(name: 'default_tax_rate') String? get defaultTaxRate;@JsonKey(name: 'alternative_item_ids') List<String> get alternativeItemIds; String? get description;@JsonKey(name: 'category_id') String? get categoryId; CategorySummaryDto? get category;@JsonKey(name: 'brand_id') String? get brandId; BrandSummaryDto? get brand;@JsonKey(name: 'hsn_code') String? get hsnCode; String? get barcode;@JsonKey(name: 'base_unit_detail') BaseUnitSummaryDto? get baseUnitDetail; String? get mrp;@JsonKey(name: 'market_price') String? get marketPrice;@JsonKey(name: 'reorder_level') String? get reorderLevel;@JsonKey(name: 'primary_image_url') String? get primaryImageUrl; String? get quantity;@JsonKey(name: 'reserved_quantity') String? get reservedQuantity;@JsonKey(name: 'available_for_sale') String? get availableForSale;
/// Create a copy of ItemListDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemListDtoCopyWith<ItemListDto> get copyWith => _$ItemListDtoCopyWithImpl<ItemListDto>(this as ItemListDto, _$identity);

  /// Serializes this ItemListDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemListDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.hasStockTracking, hasStockTracking) || other.hasStockTracking == hasStockTracking)&&(identical(other.baseUnit, baseUnit) || other.baseUnit == baseUnit)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.alias, alias) || other.alias == alias)&&const DeepCollectionEquality().equals(other.searchKeywords, searchKeywords)&&(identical(other.defaultTaxRate, defaultTaxRate) || other.defaultTaxRate == defaultTaxRate)&&const DeepCollectionEquality().equals(other.alternativeItemIds, alternativeItemIds)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.hsnCode, hsnCode) || other.hsnCode == hsnCode)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.baseUnitDetail, baseUnitDetail) || other.baseUnitDetail == baseUnitDetail)&&(identical(other.mrp, mrp) || other.mrp == mrp)&&(identical(other.marketPrice, marketPrice) || other.marketPrice == marketPrice)&&(identical(other.reorderLevel, reorderLevel) || other.reorderLevel == reorderLevel)&&(identical(other.primaryImageUrl, primaryImageUrl) || other.primaryImageUrl == primaryImageUrl)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.reservedQuantity, reservedQuantity) || other.reservedQuantity == reservedQuantity)&&(identical(other.availableForSale, availableForSale) || other.availableForSale == availableForSale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,itemType,hasStockTracking,baseUnit,salePrice,purchasePrice,createdAt,updatedAt,shortName,alias,const DeepCollectionEquality().hash(searchKeywords),defaultTaxRate,const DeepCollectionEquality().hash(alternativeItemIds),description,categoryId,category,brandId,brand,hsnCode,barcode,baseUnitDetail,mrp,marketPrice,reorderLevel,primaryImageUrl,quantity,reservedQuantity,availableForSale]);

@override
String toString() {
  return 'ItemListDto(id: $id, name: $name, itemType: $itemType, hasStockTracking: $hasStockTracking, baseUnit: $baseUnit, salePrice: $salePrice, purchasePrice: $purchasePrice, createdAt: $createdAt, updatedAt: $updatedAt, shortName: $shortName, alias: $alias, searchKeywords: $searchKeywords, defaultTaxRate: $defaultTaxRate, alternativeItemIds: $alternativeItemIds, description: $description, categoryId: $categoryId, category: $category, brandId: $brandId, brand: $brand, hsnCode: $hsnCode, barcode: $barcode, baseUnitDetail: $baseUnitDetail, mrp: $mrp, marketPrice: $marketPrice, reorderLevel: $reorderLevel, primaryImageUrl: $primaryImageUrl, quantity: $quantity, reservedQuantity: $reservedQuantity, availableForSale: $availableForSale)';
}


}

/// @nodoc
abstract mixin class $ItemListDtoCopyWith<$Res>  {
  factory $ItemListDtoCopyWith(ItemListDto value, $Res Function(ItemListDto) _then) = _$ItemListDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'item_type') String itemType,@JsonKey(name: 'has_stock_tracking') bool hasStockTracking,@JsonKey(name: 'base_unit') String baseUnit,@JsonKey(name: 'sale_price') String salePrice,@JsonKey(name: 'purchase_price') String purchasePrice,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt,@JsonKey(name: 'short_name') String? shortName, String? alias,@JsonKey(name: 'search_keywords') List<String> searchKeywords,@JsonKey(name: 'default_tax_rate') String? defaultTaxRate,@JsonKey(name: 'alternative_item_ids') List<String> alternativeItemIds, String? description,@JsonKey(name: 'category_id') String? categoryId, CategorySummaryDto? category,@JsonKey(name: 'brand_id') String? brandId, BrandSummaryDto? brand,@JsonKey(name: 'hsn_code') String? hsnCode, String? barcode,@JsonKey(name: 'base_unit_detail') BaseUnitSummaryDto? baseUnitDetail, String? mrp,@JsonKey(name: 'market_price') String? marketPrice,@JsonKey(name: 'reorder_level') String? reorderLevel,@JsonKey(name: 'primary_image_url') String? primaryImageUrl, String? quantity,@JsonKey(name: 'reserved_quantity') String? reservedQuantity,@JsonKey(name: 'available_for_sale') String? availableForSale
});


$CategorySummaryDtoCopyWith<$Res>? get category;$BrandSummaryDtoCopyWith<$Res>? get brand;$BaseUnitSummaryDtoCopyWith<$Res>? get baseUnitDetail;

}
/// @nodoc
class _$ItemListDtoCopyWithImpl<$Res>
    implements $ItemListDtoCopyWith<$Res> {
  _$ItemListDtoCopyWithImpl(this._self, this._then);

  final ItemListDto _self;
  final $Res Function(ItemListDto) _then;

/// Create a copy of ItemListDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? itemType = null,Object? hasStockTracking = null,Object? baseUnit = null,Object? salePrice = null,Object? purchasePrice = null,Object? createdAt = null,Object? updatedAt = null,Object? shortName = freezed,Object? alias = freezed,Object? searchKeywords = null,Object? defaultTaxRate = freezed,Object? alternativeItemIds = null,Object? description = freezed,Object? categoryId = freezed,Object? category = freezed,Object? brandId = freezed,Object? brand = freezed,Object? hsnCode = freezed,Object? barcode = freezed,Object? baseUnitDetail = freezed,Object? mrp = freezed,Object? marketPrice = freezed,Object? reorderLevel = freezed,Object? primaryImageUrl = freezed,Object? quantity = freezed,Object? reservedQuantity = freezed,Object? availableForSale = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,hasStockTracking: null == hasStockTracking ? _self.hasStockTracking : hasStockTracking // ignore: cast_nullable_to_non_nullable
as bool,baseUnit: null == baseUnit ? _self.baseUnit : baseUnit // ignore: cast_nullable_to_non_nullable
as String,salePrice: null == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as String,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,searchKeywords: null == searchKeywords ? _self.searchKeywords : searchKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,defaultTaxRate: freezed == defaultTaxRate ? _self.defaultTaxRate : defaultTaxRate // ignore: cast_nullable_to_non_nullable
as String?,alternativeItemIds: null == alternativeItemIds ? _self.alternativeItemIds : alternativeItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategorySummaryDto?,brandId: freezed == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as BrandSummaryDto?,hsnCode: freezed == hsnCode ? _self.hsnCode : hsnCode // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,baseUnitDetail: freezed == baseUnitDetail ? _self.baseUnitDetail : baseUnitDetail // ignore: cast_nullable_to_non_nullable
as BaseUnitSummaryDto?,mrp: freezed == mrp ? _self.mrp : mrp // ignore: cast_nullable_to_non_nullable
as String?,marketPrice: freezed == marketPrice ? _self.marketPrice : marketPrice // ignore: cast_nullable_to_non_nullable
as String?,reorderLevel: freezed == reorderLevel ? _self.reorderLevel : reorderLevel // ignore: cast_nullable_to_non_nullable
as String?,primaryImageUrl: freezed == primaryImageUrl ? _self.primaryImageUrl : primaryImageUrl // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String?,reservedQuantity: freezed == reservedQuantity ? _self.reservedQuantity : reservedQuantity // ignore: cast_nullable_to_non_nullable
as String?,availableForSale: freezed == availableForSale ? _self.availableForSale : availableForSale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ItemListDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategorySummaryDtoCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategorySummaryDtoCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of ItemListDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BrandSummaryDtoCopyWith<$Res>? get brand {
    if (_self.brand == null) {
    return null;
  }

  return $BrandSummaryDtoCopyWith<$Res>(_self.brand!, (value) {
    return _then(_self.copyWith(brand: value));
  });
}/// Create a copy of ItemListDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BaseUnitSummaryDtoCopyWith<$Res>? get baseUnitDetail {
    if (_self.baseUnitDetail == null) {
    return null;
  }

  return $BaseUnitSummaryDtoCopyWith<$Res>(_self.baseUnitDetail!, (value) {
    return _then(_self.copyWith(baseUnitDetail: value));
  });
}
}


/// Adds pattern-matching-related methods to [ItemListDto].
extension ItemListDtoPatterns on ItemListDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemListDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemListDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemListDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemListDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemListDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemListDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'item_type')  String itemType, @JsonKey(name: 'has_stock_tracking')  bool hasStockTracking, @JsonKey(name: 'base_unit')  String baseUnit, @JsonKey(name: 'sale_price')  String salePrice, @JsonKey(name: 'purchase_price')  String purchasePrice, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'short_name')  String? shortName,  String? alias, @JsonKey(name: 'search_keywords')  List<String> searchKeywords, @JsonKey(name: 'default_tax_rate')  String? defaultTaxRate, @JsonKey(name: 'alternative_item_ids')  List<String> alternativeItemIds,  String? description, @JsonKey(name: 'category_id')  String? categoryId,  CategorySummaryDto? category, @JsonKey(name: 'brand_id')  String? brandId,  BrandSummaryDto? brand, @JsonKey(name: 'hsn_code')  String? hsnCode,  String? barcode, @JsonKey(name: 'base_unit_detail')  BaseUnitSummaryDto? baseUnitDetail,  String? mrp, @JsonKey(name: 'market_price')  String? marketPrice, @JsonKey(name: 'reorder_level')  String? reorderLevel, @JsonKey(name: 'primary_image_url')  String? primaryImageUrl,  String? quantity, @JsonKey(name: 'reserved_quantity')  String? reservedQuantity, @JsonKey(name: 'available_for_sale')  String? availableForSale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemListDto() when $default != null:
return $default(_that.id,_that.name,_that.itemType,_that.hasStockTracking,_that.baseUnit,_that.salePrice,_that.purchasePrice,_that.createdAt,_that.updatedAt,_that.shortName,_that.alias,_that.searchKeywords,_that.defaultTaxRate,_that.alternativeItemIds,_that.description,_that.categoryId,_that.category,_that.brandId,_that.brand,_that.hsnCode,_that.barcode,_that.baseUnitDetail,_that.mrp,_that.marketPrice,_that.reorderLevel,_that.primaryImageUrl,_that.quantity,_that.reservedQuantity,_that.availableForSale);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'item_type')  String itemType, @JsonKey(name: 'has_stock_tracking')  bool hasStockTracking, @JsonKey(name: 'base_unit')  String baseUnit, @JsonKey(name: 'sale_price')  String salePrice, @JsonKey(name: 'purchase_price')  String purchasePrice, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'short_name')  String? shortName,  String? alias, @JsonKey(name: 'search_keywords')  List<String> searchKeywords, @JsonKey(name: 'default_tax_rate')  String? defaultTaxRate, @JsonKey(name: 'alternative_item_ids')  List<String> alternativeItemIds,  String? description, @JsonKey(name: 'category_id')  String? categoryId,  CategorySummaryDto? category, @JsonKey(name: 'brand_id')  String? brandId,  BrandSummaryDto? brand, @JsonKey(name: 'hsn_code')  String? hsnCode,  String? barcode, @JsonKey(name: 'base_unit_detail')  BaseUnitSummaryDto? baseUnitDetail,  String? mrp, @JsonKey(name: 'market_price')  String? marketPrice, @JsonKey(name: 'reorder_level')  String? reorderLevel, @JsonKey(name: 'primary_image_url')  String? primaryImageUrl,  String? quantity, @JsonKey(name: 'reserved_quantity')  String? reservedQuantity, @JsonKey(name: 'available_for_sale')  String? availableForSale)  $default,) {final _that = this;
switch (_that) {
case _ItemListDto():
return $default(_that.id,_that.name,_that.itemType,_that.hasStockTracking,_that.baseUnit,_that.salePrice,_that.purchasePrice,_that.createdAt,_that.updatedAt,_that.shortName,_that.alias,_that.searchKeywords,_that.defaultTaxRate,_that.alternativeItemIds,_that.description,_that.categoryId,_that.category,_that.brandId,_that.brand,_that.hsnCode,_that.barcode,_that.baseUnitDetail,_that.mrp,_that.marketPrice,_that.reorderLevel,_that.primaryImageUrl,_that.quantity,_that.reservedQuantity,_that.availableForSale);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'item_type')  String itemType, @JsonKey(name: 'has_stock_tracking')  bool hasStockTracking, @JsonKey(name: 'base_unit')  String baseUnit, @JsonKey(name: 'sale_price')  String salePrice, @JsonKey(name: 'purchase_price')  String purchasePrice, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'short_name')  String? shortName,  String? alias, @JsonKey(name: 'search_keywords')  List<String> searchKeywords, @JsonKey(name: 'default_tax_rate')  String? defaultTaxRate, @JsonKey(name: 'alternative_item_ids')  List<String> alternativeItemIds,  String? description, @JsonKey(name: 'category_id')  String? categoryId,  CategorySummaryDto? category, @JsonKey(name: 'brand_id')  String? brandId,  BrandSummaryDto? brand, @JsonKey(name: 'hsn_code')  String? hsnCode,  String? barcode, @JsonKey(name: 'base_unit_detail')  BaseUnitSummaryDto? baseUnitDetail,  String? mrp, @JsonKey(name: 'market_price')  String? marketPrice, @JsonKey(name: 'reorder_level')  String? reorderLevel, @JsonKey(name: 'primary_image_url')  String? primaryImageUrl,  String? quantity, @JsonKey(name: 'reserved_quantity')  String? reservedQuantity, @JsonKey(name: 'available_for_sale')  String? availableForSale)?  $default,) {final _that = this;
switch (_that) {
case _ItemListDto() when $default != null:
return $default(_that.id,_that.name,_that.itemType,_that.hasStockTracking,_that.baseUnit,_that.salePrice,_that.purchasePrice,_that.createdAt,_that.updatedAt,_that.shortName,_that.alias,_that.searchKeywords,_that.defaultTaxRate,_that.alternativeItemIds,_that.description,_that.categoryId,_that.category,_that.brandId,_that.brand,_that.hsnCode,_that.barcode,_that.baseUnitDetail,_that.mrp,_that.marketPrice,_that.reorderLevel,_that.primaryImageUrl,_that.quantity,_that.reservedQuantity,_that.availableForSale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemListDto implements ItemListDto {
  const _ItemListDto({required this.id, required this.name, @JsonKey(name: 'item_type') required this.itemType, @JsonKey(name: 'has_stock_tracking') required this.hasStockTracking, @JsonKey(name: 'base_unit') required this.baseUnit, @JsonKey(name: 'sale_price') required this.salePrice, @JsonKey(name: 'purchase_price') required this.purchasePrice, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'short_name') this.shortName, this.alias, @JsonKey(name: 'search_keywords') final  List<String> searchKeywords = const [], @JsonKey(name: 'default_tax_rate') this.defaultTaxRate, @JsonKey(name: 'alternative_item_ids') final  List<String> alternativeItemIds = const [], this.description, @JsonKey(name: 'category_id') this.categoryId, this.category, @JsonKey(name: 'brand_id') this.brandId, this.brand, @JsonKey(name: 'hsn_code') this.hsnCode, this.barcode, @JsonKey(name: 'base_unit_detail') this.baseUnitDetail, this.mrp, @JsonKey(name: 'market_price') this.marketPrice, @JsonKey(name: 'reorder_level') this.reorderLevel, @JsonKey(name: 'primary_image_url') this.primaryImageUrl, this.quantity, @JsonKey(name: 'reserved_quantity') this.reservedQuantity, @JsonKey(name: 'available_for_sale') this.availableForSale}): _searchKeywords = searchKeywords,_alternativeItemIds = alternativeItemIds;
  factory _ItemListDto.fromJson(Map<String, dynamic> json) => _$ItemListDtoFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'item_type') final  String itemType;
@override@JsonKey(name: 'has_stock_tracking') final  bool hasStockTracking;
@override@JsonKey(name: 'base_unit') final  String baseUnit;
@override@JsonKey(name: 'sale_price') final  String salePrice;
@override@JsonKey(name: 'purchase_price') final  String purchasePrice;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override@JsonKey(name: 'short_name') final  String? shortName;
@override final  String? alias;
 final  List<String> _searchKeywords;
@override@JsonKey(name: 'search_keywords') List<String> get searchKeywords {
  if (_searchKeywords is EqualUnmodifiableListView) return _searchKeywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_searchKeywords);
}

@override@JsonKey(name: 'default_tax_rate') final  String? defaultTaxRate;
 final  List<String> _alternativeItemIds;
@override@JsonKey(name: 'alternative_item_ids') List<String> get alternativeItemIds {
  if (_alternativeItemIds is EqualUnmodifiableListView) return _alternativeItemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alternativeItemIds);
}

@override final  String? description;
@override@JsonKey(name: 'category_id') final  String? categoryId;
@override final  CategorySummaryDto? category;
@override@JsonKey(name: 'brand_id') final  String? brandId;
@override final  BrandSummaryDto? brand;
@override@JsonKey(name: 'hsn_code') final  String? hsnCode;
@override final  String? barcode;
@override@JsonKey(name: 'base_unit_detail') final  BaseUnitSummaryDto? baseUnitDetail;
@override final  String? mrp;
@override@JsonKey(name: 'market_price') final  String? marketPrice;
@override@JsonKey(name: 'reorder_level') final  String? reorderLevel;
@override@JsonKey(name: 'primary_image_url') final  String? primaryImageUrl;
@override final  String? quantity;
@override@JsonKey(name: 'reserved_quantity') final  String? reservedQuantity;
@override@JsonKey(name: 'available_for_sale') final  String? availableForSale;

/// Create a copy of ItemListDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemListDtoCopyWith<_ItemListDto> get copyWith => __$ItemListDtoCopyWithImpl<_ItemListDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemListDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemListDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.hasStockTracking, hasStockTracking) || other.hasStockTracking == hasStockTracking)&&(identical(other.baseUnit, baseUnit) || other.baseUnit == baseUnit)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.alias, alias) || other.alias == alias)&&const DeepCollectionEquality().equals(other._searchKeywords, _searchKeywords)&&(identical(other.defaultTaxRate, defaultTaxRate) || other.defaultTaxRate == defaultTaxRate)&&const DeepCollectionEquality().equals(other._alternativeItemIds, _alternativeItemIds)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.hsnCode, hsnCode) || other.hsnCode == hsnCode)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.baseUnitDetail, baseUnitDetail) || other.baseUnitDetail == baseUnitDetail)&&(identical(other.mrp, mrp) || other.mrp == mrp)&&(identical(other.marketPrice, marketPrice) || other.marketPrice == marketPrice)&&(identical(other.reorderLevel, reorderLevel) || other.reorderLevel == reorderLevel)&&(identical(other.primaryImageUrl, primaryImageUrl) || other.primaryImageUrl == primaryImageUrl)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.reservedQuantity, reservedQuantity) || other.reservedQuantity == reservedQuantity)&&(identical(other.availableForSale, availableForSale) || other.availableForSale == availableForSale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,itemType,hasStockTracking,baseUnit,salePrice,purchasePrice,createdAt,updatedAt,shortName,alias,const DeepCollectionEquality().hash(_searchKeywords),defaultTaxRate,const DeepCollectionEquality().hash(_alternativeItemIds),description,categoryId,category,brandId,brand,hsnCode,barcode,baseUnitDetail,mrp,marketPrice,reorderLevel,primaryImageUrl,quantity,reservedQuantity,availableForSale]);

@override
String toString() {
  return 'ItemListDto(id: $id, name: $name, itemType: $itemType, hasStockTracking: $hasStockTracking, baseUnit: $baseUnit, salePrice: $salePrice, purchasePrice: $purchasePrice, createdAt: $createdAt, updatedAt: $updatedAt, shortName: $shortName, alias: $alias, searchKeywords: $searchKeywords, defaultTaxRate: $defaultTaxRate, alternativeItemIds: $alternativeItemIds, description: $description, categoryId: $categoryId, category: $category, brandId: $brandId, brand: $brand, hsnCode: $hsnCode, barcode: $barcode, baseUnitDetail: $baseUnitDetail, mrp: $mrp, marketPrice: $marketPrice, reorderLevel: $reorderLevel, primaryImageUrl: $primaryImageUrl, quantity: $quantity, reservedQuantity: $reservedQuantity, availableForSale: $availableForSale)';
}


}

/// @nodoc
abstract mixin class _$ItemListDtoCopyWith<$Res> implements $ItemListDtoCopyWith<$Res> {
  factory _$ItemListDtoCopyWith(_ItemListDto value, $Res Function(_ItemListDto) _then) = __$ItemListDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'item_type') String itemType,@JsonKey(name: 'has_stock_tracking') bool hasStockTracking,@JsonKey(name: 'base_unit') String baseUnit,@JsonKey(name: 'sale_price') String salePrice,@JsonKey(name: 'purchase_price') String purchasePrice,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt,@JsonKey(name: 'short_name') String? shortName, String? alias,@JsonKey(name: 'search_keywords') List<String> searchKeywords,@JsonKey(name: 'default_tax_rate') String? defaultTaxRate,@JsonKey(name: 'alternative_item_ids') List<String> alternativeItemIds, String? description,@JsonKey(name: 'category_id') String? categoryId, CategorySummaryDto? category,@JsonKey(name: 'brand_id') String? brandId, BrandSummaryDto? brand,@JsonKey(name: 'hsn_code') String? hsnCode, String? barcode,@JsonKey(name: 'base_unit_detail') BaseUnitSummaryDto? baseUnitDetail, String? mrp,@JsonKey(name: 'market_price') String? marketPrice,@JsonKey(name: 'reorder_level') String? reorderLevel,@JsonKey(name: 'primary_image_url') String? primaryImageUrl, String? quantity,@JsonKey(name: 'reserved_quantity') String? reservedQuantity,@JsonKey(name: 'available_for_sale') String? availableForSale
});


@override $CategorySummaryDtoCopyWith<$Res>? get category;@override $BrandSummaryDtoCopyWith<$Res>? get brand;@override $BaseUnitSummaryDtoCopyWith<$Res>? get baseUnitDetail;

}
/// @nodoc
class __$ItemListDtoCopyWithImpl<$Res>
    implements _$ItemListDtoCopyWith<$Res> {
  __$ItemListDtoCopyWithImpl(this._self, this._then);

  final _ItemListDto _self;
  final $Res Function(_ItemListDto) _then;

/// Create a copy of ItemListDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? itemType = null,Object? hasStockTracking = null,Object? baseUnit = null,Object? salePrice = null,Object? purchasePrice = null,Object? createdAt = null,Object? updatedAt = null,Object? shortName = freezed,Object? alias = freezed,Object? searchKeywords = null,Object? defaultTaxRate = freezed,Object? alternativeItemIds = null,Object? description = freezed,Object? categoryId = freezed,Object? category = freezed,Object? brandId = freezed,Object? brand = freezed,Object? hsnCode = freezed,Object? barcode = freezed,Object? baseUnitDetail = freezed,Object? mrp = freezed,Object? marketPrice = freezed,Object? reorderLevel = freezed,Object? primaryImageUrl = freezed,Object? quantity = freezed,Object? reservedQuantity = freezed,Object? availableForSale = freezed,}) {
  return _then(_ItemListDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,hasStockTracking: null == hasStockTracking ? _self.hasStockTracking : hasStockTracking // ignore: cast_nullable_to_non_nullable
as bool,baseUnit: null == baseUnit ? _self.baseUnit : baseUnit // ignore: cast_nullable_to_non_nullable
as String,salePrice: null == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as String,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,searchKeywords: null == searchKeywords ? _self._searchKeywords : searchKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,defaultTaxRate: freezed == defaultTaxRate ? _self.defaultTaxRate : defaultTaxRate // ignore: cast_nullable_to_non_nullable
as String?,alternativeItemIds: null == alternativeItemIds ? _self._alternativeItemIds : alternativeItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategorySummaryDto?,brandId: freezed == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as BrandSummaryDto?,hsnCode: freezed == hsnCode ? _self.hsnCode : hsnCode // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,baseUnitDetail: freezed == baseUnitDetail ? _self.baseUnitDetail : baseUnitDetail // ignore: cast_nullable_to_non_nullable
as BaseUnitSummaryDto?,mrp: freezed == mrp ? _self.mrp : mrp // ignore: cast_nullable_to_non_nullable
as String?,marketPrice: freezed == marketPrice ? _self.marketPrice : marketPrice // ignore: cast_nullable_to_non_nullable
as String?,reorderLevel: freezed == reorderLevel ? _self.reorderLevel : reorderLevel // ignore: cast_nullable_to_non_nullable
as String?,primaryImageUrl: freezed == primaryImageUrl ? _self.primaryImageUrl : primaryImageUrl // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String?,reservedQuantity: freezed == reservedQuantity ? _self.reservedQuantity : reservedQuantity // ignore: cast_nullable_to_non_nullable
as String?,availableForSale: freezed == availableForSale ? _self.availableForSale : availableForSale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ItemListDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategorySummaryDtoCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategorySummaryDtoCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of ItemListDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BrandSummaryDtoCopyWith<$Res>? get brand {
    if (_self.brand == null) {
    return null;
  }

  return $BrandSummaryDtoCopyWith<$Res>(_self.brand!, (value) {
    return _then(_self.copyWith(brand: value));
  });
}/// Create a copy of ItemListDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BaseUnitSummaryDtoCopyWith<$Res>? get baseUnitDetail {
    if (_self.baseUnitDetail == null) {
    return null;
  }

  return $BaseUnitSummaryDtoCopyWith<$Res>(_self.baseUnitDetail!, (value) {
    return _then(_self.copyWith(baseUnitDetail: value));
  });
}
}


/// @nodoc
mixin _$ItemDetailDto {

 String get id; String get name;@JsonKey(name: 'item_type') String get itemType;@JsonKey(name: 'has_stock_tracking') bool get hasStockTracking;@JsonKey(name: 'base_unit') String get baseUnit;@JsonKey(name: 'sale_price') String get salePrice;@JsonKey(name: 'purchase_price') String get purchasePrice;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;@JsonKey(name: 'short_name') String? get shortName; String? get alias;@JsonKey(name: 'search_keywords') List<String> get searchKeywords;@JsonKey(name: 'default_tax_rate') String? get defaultTaxRate;@JsonKey(name: 'alternative_item_ids') List<String> get alternativeItemIds; String? get description;@JsonKey(name: 'category_id') String? get categoryId; CategorySummaryDto? get category;@JsonKey(name: 'brand_id') String? get brandId; BrandSummaryDto? get brand;@JsonKey(name: 'hsn_code') String? get hsnCode; String? get barcode;@JsonKey(name: 'base_unit_detail') BaseUnitSummaryDto? get baseUnitDetail; String? get mrp;@JsonKey(name: 'market_price') String? get marketPrice;@JsonKey(name: 'reorder_level') String? get reorderLevel;@JsonKey(name: 'primary_image_url') String? get primaryImageUrl; String? get quantity;@JsonKey(name: 'reserved_quantity') String? get reservedQuantity;@JsonKey(name: 'available_for_sale') String? get availableForSale;@JsonKey(name: 'tier_prices') List<TierPriceDto> get tierPrices; List<ItemImageDto> get images; List<ItemLocationSummaryDto> get locations;@JsonKey(name: 'opening_stock') OpeningStockDto? get openingStock;
/// Create a copy of ItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemDetailDtoCopyWith<ItemDetailDto> get copyWith => _$ItemDetailDtoCopyWithImpl<ItemDetailDto>(this as ItemDetailDto, _$identity);

  /// Serializes this ItemDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.hasStockTracking, hasStockTracking) || other.hasStockTracking == hasStockTracking)&&(identical(other.baseUnit, baseUnit) || other.baseUnit == baseUnit)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.alias, alias) || other.alias == alias)&&const DeepCollectionEquality().equals(other.searchKeywords, searchKeywords)&&(identical(other.defaultTaxRate, defaultTaxRate) || other.defaultTaxRate == defaultTaxRate)&&const DeepCollectionEquality().equals(other.alternativeItemIds, alternativeItemIds)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.hsnCode, hsnCode) || other.hsnCode == hsnCode)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.baseUnitDetail, baseUnitDetail) || other.baseUnitDetail == baseUnitDetail)&&(identical(other.mrp, mrp) || other.mrp == mrp)&&(identical(other.marketPrice, marketPrice) || other.marketPrice == marketPrice)&&(identical(other.reorderLevel, reorderLevel) || other.reorderLevel == reorderLevel)&&(identical(other.primaryImageUrl, primaryImageUrl) || other.primaryImageUrl == primaryImageUrl)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.reservedQuantity, reservedQuantity) || other.reservedQuantity == reservedQuantity)&&(identical(other.availableForSale, availableForSale) || other.availableForSale == availableForSale)&&const DeepCollectionEquality().equals(other.tierPrices, tierPrices)&&const DeepCollectionEquality().equals(other.images, images)&&const DeepCollectionEquality().equals(other.locations, locations)&&(identical(other.openingStock, openingStock) || other.openingStock == openingStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,itemType,hasStockTracking,baseUnit,salePrice,purchasePrice,createdAt,updatedAt,shortName,alias,const DeepCollectionEquality().hash(searchKeywords),defaultTaxRate,const DeepCollectionEquality().hash(alternativeItemIds),description,categoryId,category,brandId,brand,hsnCode,barcode,baseUnitDetail,mrp,marketPrice,reorderLevel,primaryImageUrl,quantity,reservedQuantity,availableForSale,const DeepCollectionEquality().hash(tierPrices),const DeepCollectionEquality().hash(images),const DeepCollectionEquality().hash(locations),openingStock]);

@override
String toString() {
  return 'ItemDetailDto(id: $id, name: $name, itemType: $itemType, hasStockTracking: $hasStockTracking, baseUnit: $baseUnit, salePrice: $salePrice, purchasePrice: $purchasePrice, createdAt: $createdAt, updatedAt: $updatedAt, shortName: $shortName, alias: $alias, searchKeywords: $searchKeywords, defaultTaxRate: $defaultTaxRate, alternativeItemIds: $alternativeItemIds, description: $description, categoryId: $categoryId, category: $category, brandId: $brandId, brand: $brand, hsnCode: $hsnCode, barcode: $barcode, baseUnitDetail: $baseUnitDetail, mrp: $mrp, marketPrice: $marketPrice, reorderLevel: $reorderLevel, primaryImageUrl: $primaryImageUrl, quantity: $quantity, reservedQuantity: $reservedQuantity, availableForSale: $availableForSale, tierPrices: $tierPrices, images: $images, locations: $locations, openingStock: $openingStock)';
}


}

/// @nodoc
abstract mixin class $ItemDetailDtoCopyWith<$Res>  {
  factory $ItemDetailDtoCopyWith(ItemDetailDto value, $Res Function(ItemDetailDto) _then) = _$ItemDetailDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'item_type') String itemType,@JsonKey(name: 'has_stock_tracking') bool hasStockTracking,@JsonKey(name: 'base_unit') String baseUnit,@JsonKey(name: 'sale_price') String salePrice,@JsonKey(name: 'purchase_price') String purchasePrice,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt,@JsonKey(name: 'short_name') String? shortName, String? alias,@JsonKey(name: 'search_keywords') List<String> searchKeywords,@JsonKey(name: 'default_tax_rate') String? defaultTaxRate,@JsonKey(name: 'alternative_item_ids') List<String> alternativeItemIds, String? description,@JsonKey(name: 'category_id') String? categoryId, CategorySummaryDto? category,@JsonKey(name: 'brand_id') String? brandId, BrandSummaryDto? brand,@JsonKey(name: 'hsn_code') String? hsnCode, String? barcode,@JsonKey(name: 'base_unit_detail') BaseUnitSummaryDto? baseUnitDetail, String? mrp,@JsonKey(name: 'market_price') String? marketPrice,@JsonKey(name: 'reorder_level') String? reorderLevel,@JsonKey(name: 'primary_image_url') String? primaryImageUrl, String? quantity,@JsonKey(name: 'reserved_quantity') String? reservedQuantity,@JsonKey(name: 'available_for_sale') String? availableForSale,@JsonKey(name: 'tier_prices') List<TierPriceDto> tierPrices, List<ItemImageDto> images, List<ItemLocationSummaryDto> locations,@JsonKey(name: 'opening_stock') OpeningStockDto? openingStock
});


$CategorySummaryDtoCopyWith<$Res>? get category;$BrandSummaryDtoCopyWith<$Res>? get brand;$BaseUnitSummaryDtoCopyWith<$Res>? get baseUnitDetail;$OpeningStockDtoCopyWith<$Res>? get openingStock;

}
/// @nodoc
class _$ItemDetailDtoCopyWithImpl<$Res>
    implements $ItemDetailDtoCopyWith<$Res> {
  _$ItemDetailDtoCopyWithImpl(this._self, this._then);

  final ItemDetailDto _self;
  final $Res Function(ItemDetailDto) _then;

/// Create a copy of ItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? itemType = null,Object? hasStockTracking = null,Object? baseUnit = null,Object? salePrice = null,Object? purchasePrice = null,Object? createdAt = null,Object? updatedAt = null,Object? shortName = freezed,Object? alias = freezed,Object? searchKeywords = null,Object? defaultTaxRate = freezed,Object? alternativeItemIds = null,Object? description = freezed,Object? categoryId = freezed,Object? category = freezed,Object? brandId = freezed,Object? brand = freezed,Object? hsnCode = freezed,Object? barcode = freezed,Object? baseUnitDetail = freezed,Object? mrp = freezed,Object? marketPrice = freezed,Object? reorderLevel = freezed,Object? primaryImageUrl = freezed,Object? quantity = freezed,Object? reservedQuantity = freezed,Object? availableForSale = freezed,Object? tierPrices = null,Object? images = null,Object? locations = null,Object? openingStock = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,hasStockTracking: null == hasStockTracking ? _self.hasStockTracking : hasStockTracking // ignore: cast_nullable_to_non_nullable
as bool,baseUnit: null == baseUnit ? _self.baseUnit : baseUnit // ignore: cast_nullable_to_non_nullable
as String,salePrice: null == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as String,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,searchKeywords: null == searchKeywords ? _self.searchKeywords : searchKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,defaultTaxRate: freezed == defaultTaxRate ? _self.defaultTaxRate : defaultTaxRate // ignore: cast_nullable_to_non_nullable
as String?,alternativeItemIds: null == alternativeItemIds ? _self.alternativeItemIds : alternativeItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategorySummaryDto?,brandId: freezed == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as BrandSummaryDto?,hsnCode: freezed == hsnCode ? _self.hsnCode : hsnCode // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,baseUnitDetail: freezed == baseUnitDetail ? _self.baseUnitDetail : baseUnitDetail // ignore: cast_nullable_to_non_nullable
as BaseUnitSummaryDto?,mrp: freezed == mrp ? _self.mrp : mrp // ignore: cast_nullable_to_non_nullable
as String?,marketPrice: freezed == marketPrice ? _self.marketPrice : marketPrice // ignore: cast_nullable_to_non_nullable
as String?,reorderLevel: freezed == reorderLevel ? _self.reorderLevel : reorderLevel // ignore: cast_nullable_to_non_nullable
as String?,primaryImageUrl: freezed == primaryImageUrl ? _self.primaryImageUrl : primaryImageUrl // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String?,reservedQuantity: freezed == reservedQuantity ? _self.reservedQuantity : reservedQuantity // ignore: cast_nullable_to_non_nullable
as String?,availableForSale: freezed == availableForSale ? _self.availableForSale : availableForSale // ignore: cast_nullable_to_non_nullable
as String?,tierPrices: null == tierPrices ? _self.tierPrices : tierPrices // ignore: cast_nullable_to_non_nullable
as List<TierPriceDto>,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ItemImageDto>,locations: null == locations ? _self.locations : locations // ignore: cast_nullable_to_non_nullable
as List<ItemLocationSummaryDto>,openingStock: freezed == openingStock ? _self.openingStock : openingStock // ignore: cast_nullable_to_non_nullable
as OpeningStockDto?,
  ));
}
/// Create a copy of ItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategorySummaryDtoCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategorySummaryDtoCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of ItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BrandSummaryDtoCopyWith<$Res>? get brand {
    if (_self.brand == null) {
    return null;
  }

  return $BrandSummaryDtoCopyWith<$Res>(_self.brand!, (value) {
    return _then(_self.copyWith(brand: value));
  });
}/// Create a copy of ItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BaseUnitSummaryDtoCopyWith<$Res>? get baseUnitDetail {
    if (_self.baseUnitDetail == null) {
    return null;
  }

  return $BaseUnitSummaryDtoCopyWith<$Res>(_self.baseUnitDetail!, (value) {
    return _then(_self.copyWith(baseUnitDetail: value));
  });
}/// Create a copy of ItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpeningStockDtoCopyWith<$Res>? get openingStock {
    if (_self.openingStock == null) {
    return null;
  }

  return $OpeningStockDtoCopyWith<$Res>(_self.openingStock!, (value) {
    return _then(_self.copyWith(openingStock: value));
  });
}
}


/// Adds pattern-matching-related methods to [ItemDetailDto].
extension ItemDetailDtoPatterns on ItemDetailDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemDetailDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemDetailDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemDetailDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'item_type')  String itemType, @JsonKey(name: 'has_stock_tracking')  bool hasStockTracking, @JsonKey(name: 'base_unit')  String baseUnit, @JsonKey(name: 'sale_price')  String salePrice, @JsonKey(name: 'purchase_price')  String purchasePrice, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'short_name')  String? shortName,  String? alias, @JsonKey(name: 'search_keywords')  List<String> searchKeywords, @JsonKey(name: 'default_tax_rate')  String? defaultTaxRate, @JsonKey(name: 'alternative_item_ids')  List<String> alternativeItemIds,  String? description, @JsonKey(name: 'category_id')  String? categoryId,  CategorySummaryDto? category, @JsonKey(name: 'brand_id')  String? brandId,  BrandSummaryDto? brand, @JsonKey(name: 'hsn_code')  String? hsnCode,  String? barcode, @JsonKey(name: 'base_unit_detail')  BaseUnitSummaryDto? baseUnitDetail,  String? mrp, @JsonKey(name: 'market_price')  String? marketPrice, @JsonKey(name: 'reorder_level')  String? reorderLevel, @JsonKey(name: 'primary_image_url')  String? primaryImageUrl,  String? quantity, @JsonKey(name: 'reserved_quantity')  String? reservedQuantity, @JsonKey(name: 'available_for_sale')  String? availableForSale, @JsonKey(name: 'tier_prices')  List<TierPriceDto> tierPrices,  List<ItemImageDto> images,  List<ItemLocationSummaryDto> locations, @JsonKey(name: 'opening_stock')  OpeningStockDto? openingStock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemDetailDto() when $default != null:
return $default(_that.id,_that.name,_that.itemType,_that.hasStockTracking,_that.baseUnit,_that.salePrice,_that.purchasePrice,_that.createdAt,_that.updatedAt,_that.shortName,_that.alias,_that.searchKeywords,_that.defaultTaxRate,_that.alternativeItemIds,_that.description,_that.categoryId,_that.category,_that.brandId,_that.brand,_that.hsnCode,_that.barcode,_that.baseUnitDetail,_that.mrp,_that.marketPrice,_that.reorderLevel,_that.primaryImageUrl,_that.quantity,_that.reservedQuantity,_that.availableForSale,_that.tierPrices,_that.images,_that.locations,_that.openingStock);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'item_type')  String itemType, @JsonKey(name: 'has_stock_tracking')  bool hasStockTracking, @JsonKey(name: 'base_unit')  String baseUnit, @JsonKey(name: 'sale_price')  String salePrice, @JsonKey(name: 'purchase_price')  String purchasePrice, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'short_name')  String? shortName,  String? alias, @JsonKey(name: 'search_keywords')  List<String> searchKeywords, @JsonKey(name: 'default_tax_rate')  String? defaultTaxRate, @JsonKey(name: 'alternative_item_ids')  List<String> alternativeItemIds,  String? description, @JsonKey(name: 'category_id')  String? categoryId,  CategorySummaryDto? category, @JsonKey(name: 'brand_id')  String? brandId,  BrandSummaryDto? brand, @JsonKey(name: 'hsn_code')  String? hsnCode,  String? barcode, @JsonKey(name: 'base_unit_detail')  BaseUnitSummaryDto? baseUnitDetail,  String? mrp, @JsonKey(name: 'market_price')  String? marketPrice, @JsonKey(name: 'reorder_level')  String? reorderLevel, @JsonKey(name: 'primary_image_url')  String? primaryImageUrl,  String? quantity, @JsonKey(name: 'reserved_quantity')  String? reservedQuantity, @JsonKey(name: 'available_for_sale')  String? availableForSale, @JsonKey(name: 'tier_prices')  List<TierPriceDto> tierPrices,  List<ItemImageDto> images,  List<ItemLocationSummaryDto> locations, @JsonKey(name: 'opening_stock')  OpeningStockDto? openingStock)  $default,) {final _that = this;
switch (_that) {
case _ItemDetailDto():
return $default(_that.id,_that.name,_that.itemType,_that.hasStockTracking,_that.baseUnit,_that.salePrice,_that.purchasePrice,_that.createdAt,_that.updatedAt,_that.shortName,_that.alias,_that.searchKeywords,_that.defaultTaxRate,_that.alternativeItemIds,_that.description,_that.categoryId,_that.category,_that.brandId,_that.brand,_that.hsnCode,_that.barcode,_that.baseUnitDetail,_that.mrp,_that.marketPrice,_that.reorderLevel,_that.primaryImageUrl,_that.quantity,_that.reservedQuantity,_that.availableForSale,_that.tierPrices,_that.images,_that.locations,_that.openingStock);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'item_type')  String itemType, @JsonKey(name: 'has_stock_tracking')  bool hasStockTracking, @JsonKey(name: 'base_unit')  String baseUnit, @JsonKey(name: 'sale_price')  String salePrice, @JsonKey(name: 'purchase_price')  String purchasePrice, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'short_name')  String? shortName,  String? alias, @JsonKey(name: 'search_keywords')  List<String> searchKeywords, @JsonKey(name: 'default_tax_rate')  String? defaultTaxRate, @JsonKey(name: 'alternative_item_ids')  List<String> alternativeItemIds,  String? description, @JsonKey(name: 'category_id')  String? categoryId,  CategorySummaryDto? category, @JsonKey(name: 'brand_id')  String? brandId,  BrandSummaryDto? brand, @JsonKey(name: 'hsn_code')  String? hsnCode,  String? barcode, @JsonKey(name: 'base_unit_detail')  BaseUnitSummaryDto? baseUnitDetail,  String? mrp, @JsonKey(name: 'market_price')  String? marketPrice, @JsonKey(name: 'reorder_level')  String? reorderLevel, @JsonKey(name: 'primary_image_url')  String? primaryImageUrl,  String? quantity, @JsonKey(name: 'reserved_quantity')  String? reservedQuantity, @JsonKey(name: 'available_for_sale')  String? availableForSale, @JsonKey(name: 'tier_prices')  List<TierPriceDto> tierPrices,  List<ItemImageDto> images,  List<ItemLocationSummaryDto> locations, @JsonKey(name: 'opening_stock')  OpeningStockDto? openingStock)?  $default,) {final _that = this;
switch (_that) {
case _ItemDetailDto() when $default != null:
return $default(_that.id,_that.name,_that.itemType,_that.hasStockTracking,_that.baseUnit,_that.salePrice,_that.purchasePrice,_that.createdAt,_that.updatedAt,_that.shortName,_that.alias,_that.searchKeywords,_that.defaultTaxRate,_that.alternativeItemIds,_that.description,_that.categoryId,_that.category,_that.brandId,_that.brand,_that.hsnCode,_that.barcode,_that.baseUnitDetail,_that.mrp,_that.marketPrice,_that.reorderLevel,_that.primaryImageUrl,_that.quantity,_that.reservedQuantity,_that.availableForSale,_that.tierPrices,_that.images,_that.locations,_that.openingStock);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemDetailDto implements ItemDetailDto {
  const _ItemDetailDto({required this.id, required this.name, @JsonKey(name: 'item_type') required this.itemType, @JsonKey(name: 'has_stock_tracking') required this.hasStockTracking, @JsonKey(name: 'base_unit') required this.baseUnit, @JsonKey(name: 'sale_price') required this.salePrice, @JsonKey(name: 'purchase_price') required this.purchasePrice, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'short_name') this.shortName, this.alias, @JsonKey(name: 'search_keywords') final  List<String> searchKeywords = const [], @JsonKey(name: 'default_tax_rate') this.defaultTaxRate, @JsonKey(name: 'alternative_item_ids') final  List<String> alternativeItemIds = const [], this.description, @JsonKey(name: 'category_id') this.categoryId, this.category, @JsonKey(name: 'brand_id') this.brandId, this.brand, @JsonKey(name: 'hsn_code') this.hsnCode, this.barcode, @JsonKey(name: 'base_unit_detail') this.baseUnitDetail, this.mrp, @JsonKey(name: 'market_price') this.marketPrice, @JsonKey(name: 'reorder_level') this.reorderLevel, @JsonKey(name: 'primary_image_url') this.primaryImageUrl, this.quantity, @JsonKey(name: 'reserved_quantity') this.reservedQuantity, @JsonKey(name: 'available_for_sale') this.availableForSale, @JsonKey(name: 'tier_prices') final  List<TierPriceDto> tierPrices = const [], final  List<ItemImageDto> images = const [], final  List<ItemLocationSummaryDto> locations = const [], @JsonKey(name: 'opening_stock') this.openingStock}): _searchKeywords = searchKeywords,_alternativeItemIds = alternativeItemIds,_tierPrices = tierPrices,_images = images,_locations = locations;
  factory _ItemDetailDto.fromJson(Map<String, dynamic> json) => _$ItemDetailDtoFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'item_type') final  String itemType;
@override@JsonKey(name: 'has_stock_tracking') final  bool hasStockTracking;
@override@JsonKey(name: 'base_unit') final  String baseUnit;
@override@JsonKey(name: 'sale_price') final  String salePrice;
@override@JsonKey(name: 'purchase_price') final  String purchasePrice;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override@JsonKey(name: 'short_name') final  String? shortName;
@override final  String? alias;
 final  List<String> _searchKeywords;
@override@JsonKey(name: 'search_keywords') List<String> get searchKeywords {
  if (_searchKeywords is EqualUnmodifiableListView) return _searchKeywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_searchKeywords);
}

@override@JsonKey(name: 'default_tax_rate') final  String? defaultTaxRate;
 final  List<String> _alternativeItemIds;
@override@JsonKey(name: 'alternative_item_ids') List<String> get alternativeItemIds {
  if (_alternativeItemIds is EqualUnmodifiableListView) return _alternativeItemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alternativeItemIds);
}

@override final  String? description;
@override@JsonKey(name: 'category_id') final  String? categoryId;
@override final  CategorySummaryDto? category;
@override@JsonKey(name: 'brand_id') final  String? brandId;
@override final  BrandSummaryDto? brand;
@override@JsonKey(name: 'hsn_code') final  String? hsnCode;
@override final  String? barcode;
@override@JsonKey(name: 'base_unit_detail') final  BaseUnitSummaryDto? baseUnitDetail;
@override final  String? mrp;
@override@JsonKey(name: 'market_price') final  String? marketPrice;
@override@JsonKey(name: 'reorder_level') final  String? reorderLevel;
@override@JsonKey(name: 'primary_image_url') final  String? primaryImageUrl;
@override final  String? quantity;
@override@JsonKey(name: 'reserved_quantity') final  String? reservedQuantity;
@override@JsonKey(name: 'available_for_sale') final  String? availableForSale;
 final  List<TierPriceDto> _tierPrices;
@override@JsonKey(name: 'tier_prices') List<TierPriceDto> get tierPrices {
  if (_tierPrices is EqualUnmodifiableListView) return _tierPrices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tierPrices);
}

 final  List<ItemImageDto> _images;
@override@JsonKey() List<ItemImageDto> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

 final  List<ItemLocationSummaryDto> _locations;
@override@JsonKey() List<ItemLocationSummaryDto> get locations {
  if (_locations is EqualUnmodifiableListView) return _locations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locations);
}

@override@JsonKey(name: 'opening_stock') final  OpeningStockDto? openingStock;

/// Create a copy of ItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemDetailDtoCopyWith<_ItemDetailDto> get copyWith => __$ItemDetailDtoCopyWithImpl<_ItemDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.hasStockTracking, hasStockTracking) || other.hasStockTracking == hasStockTracking)&&(identical(other.baseUnit, baseUnit) || other.baseUnit == baseUnit)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.alias, alias) || other.alias == alias)&&const DeepCollectionEquality().equals(other._searchKeywords, _searchKeywords)&&(identical(other.defaultTaxRate, defaultTaxRate) || other.defaultTaxRate == defaultTaxRate)&&const DeepCollectionEquality().equals(other._alternativeItemIds, _alternativeItemIds)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.hsnCode, hsnCode) || other.hsnCode == hsnCode)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.baseUnitDetail, baseUnitDetail) || other.baseUnitDetail == baseUnitDetail)&&(identical(other.mrp, mrp) || other.mrp == mrp)&&(identical(other.marketPrice, marketPrice) || other.marketPrice == marketPrice)&&(identical(other.reorderLevel, reorderLevel) || other.reorderLevel == reorderLevel)&&(identical(other.primaryImageUrl, primaryImageUrl) || other.primaryImageUrl == primaryImageUrl)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.reservedQuantity, reservedQuantity) || other.reservedQuantity == reservedQuantity)&&(identical(other.availableForSale, availableForSale) || other.availableForSale == availableForSale)&&const DeepCollectionEquality().equals(other._tierPrices, _tierPrices)&&const DeepCollectionEquality().equals(other._images, _images)&&const DeepCollectionEquality().equals(other._locations, _locations)&&(identical(other.openingStock, openingStock) || other.openingStock == openingStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,itemType,hasStockTracking,baseUnit,salePrice,purchasePrice,createdAt,updatedAt,shortName,alias,const DeepCollectionEquality().hash(_searchKeywords),defaultTaxRate,const DeepCollectionEquality().hash(_alternativeItemIds),description,categoryId,category,brandId,brand,hsnCode,barcode,baseUnitDetail,mrp,marketPrice,reorderLevel,primaryImageUrl,quantity,reservedQuantity,availableForSale,const DeepCollectionEquality().hash(_tierPrices),const DeepCollectionEquality().hash(_images),const DeepCollectionEquality().hash(_locations),openingStock]);

@override
String toString() {
  return 'ItemDetailDto(id: $id, name: $name, itemType: $itemType, hasStockTracking: $hasStockTracking, baseUnit: $baseUnit, salePrice: $salePrice, purchasePrice: $purchasePrice, createdAt: $createdAt, updatedAt: $updatedAt, shortName: $shortName, alias: $alias, searchKeywords: $searchKeywords, defaultTaxRate: $defaultTaxRate, alternativeItemIds: $alternativeItemIds, description: $description, categoryId: $categoryId, category: $category, brandId: $brandId, brand: $brand, hsnCode: $hsnCode, barcode: $barcode, baseUnitDetail: $baseUnitDetail, mrp: $mrp, marketPrice: $marketPrice, reorderLevel: $reorderLevel, primaryImageUrl: $primaryImageUrl, quantity: $quantity, reservedQuantity: $reservedQuantity, availableForSale: $availableForSale, tierPrices: $tierPrices, images: $images, locations: $locations, openingStock: $openingStock)';
}


}

/// @nodoc
abstract mixin class _$ItemDetailDtoCopyWith<$Res> implements $ItemDetailDtoCopyWith<$Res> {
  factory _$ItemDetailDtoCopyWith(_ItemDetailDto value, $Res Function(_ItemDetailDto) _then) = __$ItemDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'item_type') String itemType,@JsonKey(name: 'has_stock_tracking') bool hasStockTracking,@JsonKey(name: 'base_unit') String baseUnit,@JsonKey(name: 'sale_price') String salePrice,@JsonKey(name: 'purchase_price') String purchasePrice,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt,@JsonKey(name: 'short_name') String? shortName, String? alias,@JsonKey(name: 'search_keywords') List<String> searchKeywords,@JsonKey(name: 'default_tax_rate') String? defaultTaxRate,@JsonKey(name: 'alternative_item_ids') List<String> alternativeItemIds, String? description,@JsonKey(name: 'category_id') String? categoryId, CategorySummaryDto? category,@JsonKey(name: 'brand_id') String? brandId, BrandSummaryDto? brand,@JsonKey(name: 'hsn_code') String? hsnCode, String? barcode,@JsonKey(name: 'base_unit_detail') BaseUnitSummaryDto? baseUnitDetail, String? mrp,@JsonKey(name: 'market_price') String? marketPrice,@JsonKey(name: 'reorder_level') String? reorderLevel,@JsonKey(name: 'primary_image_url') String? primaryImageUrl, String? quantity,@JsonKey(name: 'reserved_quantity') String? reservedQuantity,@JsonKey(name: 'available_for_sale') String? availableForSale,@JsonKey(name: 'tier_prices') List<TierPriceDto> tierPrices, List<ItemImageDto> images, List<ItemLocationSummaryDto> locations,@JsonKey(name: 'opening_stock') OpeningStockDto? openingStock
});


@override $CategorySummaryDtoCopyWith<$Res>? get category;@override $BrandSummaryDtoCopyWith<$Res>? get brand;@override $BaseUnitSummaryDtoCopyWith<$Res>? get baseUnitDetail;@override $OpeningStockDtoCopyWith<$Res>? get openingStock;

}
/// @nodoc
class __$ItemDetailDtoCopyWithImpl<$Res>
    implements _$ItemDetailDtoCopyWith<$Res> {
  __$ItemDetailDtoCopyWithImpl(this._self, this._then);

  final _ItemDetailDto _self;
  final $Res Function(_ItemDetailDto) _then;

/// Create a copy of ItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? itemType = null,Object? hasStockTracking = null,Object? baseUnit = null,Object? salePrice = null,Object? purchasePrice = null,Object? createdAt = null,Object? updatedAt = null,Object? shortName = freezed,Object? alias = freezed,Object? searchKeywords = null,Object? defaultTaxRate = freezed,Object? alternativeItemIds = null,Object? description = freezed,Object? categoryId = freezed,Object? category = freezed,Object? brandId = freezed,Object? brand = freezed,Object? hsnCode = freezed,Object? barcode = freezed,Object? baseUnitDetail = freezed,Object? mrp = freezed,Object? marketPrice = freezed,Object? reorderLevel = freezed,Object? primaryImageUrl = freezed,Object? quantity = freezed,Object? reservedQuantity = freezed,Object? availableForSale = freezed,Object? tierPrices = null,Object? images = null,Object? locations = null,Object? openingStock = freezed,}) {
  return _then(_ItemDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as String,hasStockTracking: null == hasStockTracking ? _self.hasStockTracking : hasStockTracking // ignore: cast_nullable_to_non_nullable
as bool,baseUnit: null == baseUnit ? _self.baseUnit : baseUnit // ignore: cast_nullable_to_non_nullable
as String,salePrice: null == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as String,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,searchKeywords: null == searchKeywords ? _self._searchKeywords : searchKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,defaultTaxRate: freezed == defaultTaxRate ? _self.defaultTaxRate : defaultTaxRate // ignore: cast_nullable_to_non_nullable
as String?,alternativeItemIds: null == alternativeItemIds ? _self._alternativeItemIds : alternativeItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategorySummaryDto?,brandId: freezed == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as BrandSummaryDto?,hsnCode: freezed == hsnCode ? _self.hsnCode : hsnCode // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,baseUnitDetail: freezed == baseUnitDetail ? _self.baseUnitDetail : baseUnitDetail // ignore: cast_nullable_to_non_nullable
as BaseUnitSummaryDto?,mrp: freezed == mrp ? _self.mrp : mrp // ignore: cast_nullable_to_non_nullable
as String?,marketPrice: freezed == marketPrice ? _self.marketPrice : marketPrice // ignore: cast_nullable_to_non_nullable
as String?,reorderLevel: freezed == reorderLevel ? _self.reorderLevel : reorderLevel // ignore: cast_nullable_to_non_nullable
as String?,primaryImageUrl: freezed == primaryImageUrl ? _self.primaryImageUrl : primaryImageUrl // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String?,reservedQuantity: freezed == reservedQuantity ? _self.reservedQuantity : reservedQuantity // ignore: cast_nullable_to_non_nullable
as String?,availableForSale: freezed == availableForSale ? _self.availableForSale : availableForSale // ignore: cast_nullable_to_non_nullable
as String?,tierPrices: null == tierPrices ? _self._tierPrices : tierPrices // ignore: cast_nullable_to_non_nullable
as List<TierPriceDto>,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ItemImageDto>,locations: null == locations ? _self._locations : locations // ignore: cast_nullable_to_non_nullable
as List<ItemLocationSummaryDto>,openingStock: freezed == openingStock ? _self.openingStock : openingStock // ignore: cast_nullable_to_non_nullable
as OpeningStockDto?,
  ));
}

/// Create a copy of ItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategorySummaryDtoCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategorySummaryDtoCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of ItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BrandSummaryDtoCopyWith<$Res>? get brand {
    if (_self.brand == null) {
    return null;
  }

  return $BrandSummaryDtoCopyWith<$Res>(_self.brand!, (value) {
    return _then(_self.copyWith(brand: value));
  });
}/// Create a copy of ItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BaseUnitSummaryDtoCopyWith<$Res>? get baseUnitDetail {
    if (_self.baseUnitDetail == null) {
    return null;
  }

  return $BaseUnitSummaryDtoCopyWith<$Res>(_self.baseUnitDetail!, (value) {
    return _then(_self.copyWith(baseUnitDetail: value));
  });
}/// Create a copy of ItemDetailDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpeningStockDtoCopyWith<$Res>? get openingStock {
    if (_self.openingStock == null) {
    return null;
  }

  return $OpeningStockDtoCopyWith<$Res>(_self.openingStock!, (value) {
    return _then(_self.copyWith(openingStock: value));
  });
}
}

// dart format on
