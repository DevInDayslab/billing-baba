// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_bom_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemBomRawItemDto {

 String get id; String get name;@JsonKey(name: 'base_unit') String get baseUnit;@JsonKey(name: 'purchase_price') String get purchasePrice;
/// Create a copy of ItemBomRawItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemBomRawItemDtoCopyWith<ItemBomRawItemDto> get copyWith => _$ItemBomRawItemDtoCopyWithImpl<ItemBomRawItemDto>(this as ItemBomRawItemDto, _$identity);

  /// Serializes this ItemBomRawItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemBomRawItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUnit, baseUnit) || other.baseUnit == baseUnit)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseUnit,purchasePrice);

@override
String toString() {
  return 'ItemBomRawItemDto(id: $id, name: $name, baseUnit: $baseUnit, purchasePrice: $purchasePrice)';
}


}

/// @nodoc
abstract mixin class $ItemBomRawItemDtoCopyWith<$Res>  {
  factory $ItemBomRawItemDtoCopyWith(ItemBomRawItemDto value, $Res Function(ItemBomRawItemDto) _then) = _$ItemBomRawItemDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'base_unit') String baseUnit,@JsonKey(name: 'purchase_price') String purchasePrice
});




}
/// @nodoc
class _$ItemBomRawItemDtoCopyWithImpl<$Res>
    implements $ItemBomRawItemDtoCopyWith<$Res> {
  _$ItemBomRawItemDtoCopyWithImpl(this._self, this._then);

  final ItemBomRawItemDto _self;
  final $Res Function(ItemBomRawItemDto) _then;

/// Create a copy of ItemBomRawItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? baseUnit = null,Object? purchasePrice = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUnit: null == baseUnit ? _self.baseUnit : baseUnit // ignore: cast_nullable_to_non_nullable
as String,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemBomRawItemDto].
extension ItemBomRawItemDtoPatterns on ItemBomRawItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemBomRawItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemBomRawItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemBomRawItemDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemBomRawItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemBomRawItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemBomRawItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'base_unit')  String baseUnit, @JsonKey(name: 'purchase_price')  String purchasePrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemBomRawItemDto() when $default != null:
return $default(_that.id,_that.name,_that.baseUnit,_that.purchasePrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'base_unit')  String baseUnit, @JsonKey(name: 'purchase_price')  String purchasePrice)  $default,) {final _that = this;
switch (_that) {
case _ItemBomRawItemDto():
return $default(_that.id,_that.name,_that.baseUnit,_that.purchasePrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'base_unit')  String baseUnit, @JsonKey(name: 'purchase_price')  String purchasePrice)?  $default,) {final _that = this;
switch (_that) {
case _ItemBomRawItemDto() when $default != null:
return $default(_that.id,_that.name,_that.baseUnit,_that.purchasePrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemBomRawItemDto implements ItemBomRawItemDto {
  const _ItemBomRawItemDto({required this.id, required this.name, @JsonKey(name: 'base_unit') required this.baseUnit, @JsonKey(name: 'purchase_price') this.purchasePrice = '0'});
  factory _ItemBomRawItemDto.fromJson(Map<String, dynamic> json) => _$ItemBomRawItemDtoFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'base_unit') final  String baseUnit;
@override@JsonKey(name: 'purchase_price') final  String purchasePrice;

/// Create a copy of ItemBomRawItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemBomRawItemDtoCopyWith<_ItemBomRawItemDto> get copyWith => __$ItemBomRawItemDtoCopyWithImpl<_ItemBomRawItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemBomRawItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemBomRawItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseUnit, baseUnit) || other.baseUnit == baseUnit)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,baseUnit,purchasePrice);

@override
String toString() {
  return 'ItemBomRawItemDto(id: $id, name: $name, baseUnit: $baseUnit, purchasePrice: $purchasePrice)';
}


}

/// @nodoc
abstract mixin class _$ItemBomRawItemDtoCopyWith<$Res> implements $ItemBomRawItemDtoCopyWith<$Res> {
  factory _$ItemBomRawItemDtoCopyWith(_ItemBomRawItemDto value, $Res Function(_ItemBomRawItemDto) _then) = __$ItemBomRawItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'base_unit') String baseUnit,@JsonKey(name: 'purchase_price') String purchasePrice
});




}
/// @nodoc
class __$ItemBomRawItemDtoCopyWithImpl<$Res>
    implements _$ItemBomRawItemDtoCopyWith<$Res> {
  __$ItemBomRawItemDtoCopyWithImpl(this._self, this._then);

  final _ItemBomRawItemDto _self;
  final $Res Function(_ItemBomRawItemDto) _then;

/// Create a copy of ItemBomRawItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? baseUnit = null,Object? purchasePrice = null,}) {
  return _then(_ItemBomRawItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseUnit: null == baseUnit ? _self.baseUnit : baseUnit // ignore: cast_nullable_to_non_nullable
as String,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ItemBomMaterialDto {

 String get id;@JsonKey(name: 'item_id') String get itemId;@JsonKey(name: 'raw_item_id') String get rawItemId; String get qty;@JsonKey(name: 'unit_id') String get unitId;@JsonKey(name: 'purchase_price') String get purchasePrice;@JsonKey(name: 'sort_order') int get sortOrder;@JsonKey(name: 'raw_item') ItemBomRawItemDto? get rawItem;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of ItemBomMaterialDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemBomMaterialDtoCopyWith<ItemBomMaterialDto> get copyWith => _$ItemBomMaterialDtoCopyWithImpl<ItemBomMaterialDto>(this as ItemBomMaterialDto, _$identity);

  /// Serializes this ItemBomMaterialDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemBomMaterialDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.rawItemId, rawItemId) || other.rawItemId == rawItemId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.rawItem, rawItem) || other.rawItem == rawItem)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,rawItemId,qty,unitId,purchasePrice,sortOrder,rawItem,createdAt,updatedAt);

@override
String toString() {
  return 'ItemBomMaterialDto(id: $id, itemId: $itemId, rawItemId: $rawItemId, qty: $qty, unitId: $unitId, purchasePrice: $purchasePrice, sortOrder: $sortOrder, rawItem: $rawItem, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ItemBomMaterialDtoCopyWith<$Res>  {
  factory $ItemBomMaterialDtoCopyWith(ItemBomMaterialDto value, $Res Function(ItemBomMaterialDto) _then) = _$ItemBomMaterialDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'raw_item_id') String rawItemId, String qty,@JsonKey(name: 'unit_id') String unitId,@JsonKey(name: 'purchase_price') String purchasePrice,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'raw_item') ItemBomRawItemDto? rawItem,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});


$ItemBomRawItemDtoCopyWith<$Res>? get rawItem;

}
/// @nodoc
class _$ItemBomMaterialDtoCopyWithImpl<$Res>
    implements $ItemBomMaterialDtoCopyWith<$Res> {
  _$ItemBomMaterialDtoCopyWithImpl(this._self, this._then);

  final ItemBomMaterialDto _self;
  final $Res Function(ItemBomMaterialDto) _then;

/// Create a copy of ItemBomMaterialDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? rawItemId = null,Object? qty = null,Object? unitId = null,Object? purchasePrice = null,Object? sortOrder = null,Object? rawItem = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,rawItemId: null == rawItemId ? _self.rawItemId : rawItemId // ignore: cast_nullable_to_non_nullable
as String,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,rawItem: freezed == rawItem ? _self.rawItem : rawItem // ignore: cast_nullable_to_non_nullable
as ItemBomRawItemDto?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ItemBomMaterialDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemBomRawItemDtoCopyWith<$Res>? get rawItem {
    if (_self.rawItem == null) {
    return null;
  }

  return $ItemBomRawItemDtoCopyWith<$Res>(_self.rawItem!, (value) {
    return _then(_self.copyWith(rawItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [ItemBomMaterialDto].
extension ItemBomMaterialDtoPatterns on ItemBomMaterialDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemBomMaterialDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemBomMaterialDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemBomMaterialDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemBomMaterialDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemBomMaterialDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemBomMaterialDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'raw_item_id')  String rawItemId,  String qty, @JsonKey(name: 'unit_id')  String unitId, @JsonKey(name: 'purchase_price')  String purchasePrice, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'raw_item')  ItemBomRawItemDto? rawItem, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemBomMaterialDto() when $default != null:
return $default(_that.id,_that.itemId,_that.rawItemId,_that.qty,_that.unitId,_that.purchasePrice,_that.sortOrder,_that.rawItem,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'raw_item_id')  String rawItemId,  String qty, @JsonKey(name: 'unit_id')  String unitId, @JsonKey(name: 'purchase_price')  String purchasePrice, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'raw_item')  ItemBomRawItemDto? rawItem, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ItemBomMaterialDto():
return $default(_that.id,_that.itemId,_that.rawItemId,_that.qty,_that.unitId,_that.purchasePrice,_that.sortOrder,_that.rawItem,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'raw_item_id')  String rawItemId,  String qty, @JsonKey(name: 'unit_id')  String unitId, @JsonKey(name: 'purchase_price')  String purchasePrice, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'raw_item')  ItemBomRawItemDto? rawItem, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ItemBomMaterialDto() when $default != null:
return $default(_that.id,_that.itemId,_that.rawItemId,_that.qty,_that.unitId,_that.purchasePrice,_that.sortOrder,_that.rawItem,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemBomMaterialDto implements ItemBomMaterialDto {
  const _ItemBomMaterialDto({required this.id, @JsonKey(name: 'item_id') required this.itemId, @JsonKey(name: 'raw_item_id') required this.rawItemId, required this.qty, @JsonKey(name: 'unit_id') required this.unitId, @JsonKey(name: 'purchase_price') this.purchasePrice = '0', @JsonKey(name: 'sort_order') this.sortOrder = 0, @JsonKey(name: 'raw_item') this.rawItem, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _ItemBomMaterialDto.fromJson(Map<String, dynamic> json) => _$ItemBomMaterialDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'item_id') final  String itemId;
@override@JsonKey(name: 'raw_item_id') final  String rawItemId;
@override final  String qty;
@override@JsonKey(name: 'unit_id') final  String unitId;
@override@JsonKey(name: 'purchase_price') final  String purchasePrice;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey(name: 'raw_item') final  ItemBomRawItemDto? rawItem;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of ItemBomMaterialDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemBomMaterialDtoCopyWith<_ItemBomMaterialDto> get copyWith => __$ItemBomMaterialDtoCopyWithImpl<_ItemBomMaterialDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemBomMaterialDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemBomMaterialDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.rawItemId, rawItemId) || other.rawItemId == rawItemId)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.rawItem, rawItem) || other.rawItem == rawItem)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,rawItemId,qty,unitId,purchasePrice,sortOrder,rawItem,createdAt,updatedAt);

@override
String toString() {
  return 'ItemBomMaterialDto(id: $id, itemId: $itemId, rawItemId: $rawItemId, qty: $qty, unitId: $unitId, purchasePrice: $purchasePrice, sortOrder: $sortOrder, rawItem: $rawItem, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ItemBomMaterialDtoCopyWith<$Res> implements $ItemBomMaterialDtoCopyWith<$Res> {
  factory _$ItemBomMaterialDtoCopyWith(_ItemBomMaterialDto value, $Res Function(_ItemBomMaterialDto) _then) = __$ItemBomMaterialDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'raw_item_id') String rawItemId, String qty,@JsonKey(name: 'unit_id') String unitId,@JsonKey(name: 'purchase_price') String purchasePrice,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'raw_item') ItemBomRawItemDto? rawItem,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});


@override $ItemBomRawItemDtoCopyWith<$Res>? get rawItem;

}
/// @nodoc
class __$ItemBomMaterialDtoCopyWithImpl<$Res>
    implements _$ItemBomMaterialDtoCopyWith<$Res> {
  __$ItemBomMaterialDtoCopyWithImpl(this._self, this._then);

  final _ItemBomMaterialDto _self;
  final $Res Function(_ItemBomMaterialDto) _then;

/// Create a copy of ItemBomMaterialDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? rawItemId = null,Object? qty = null,Object? unitId = null,Object? purchasePrice = null,Object? sortOrder = null,Object? rawItem = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ItemBomMaterialDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,rawItemId: null == rawItemId ? _self.rawItemId : rawItemId // ignore: cast_nullable_to_non_nullable
as String,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,rawItem: freezed == rawItem ? _self.rawItem : rawItem // ignore: cast_nullable_to_non_nullable
as ItemBomRawItemDto?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ItemBomMaterialDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemBomRawItemDtoCopyWith<$Res>? get rawItem {
    if (_self.rawItem == null) {
    return null;
  }

  return $ItemBomRawItemDtoCopyWith<$Res>(_self.rawItem!, (value) {
    return _then(_self.copyWith(rawItem: value));
  });
}
}


/// @nodoc
mixin _$ItemBomCostDto {

 String get id;@JsonKey(name: 'item_id') String get itemId; String get description; String get amount;@JsonKey(name: 'sort_order') int get sortOrder;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of ItemBomCostDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemBomCostDtoCopyWith<ItemBomCostDto> get copyWith => _$ItemBomCostDtoCopyWithImpl<ItemBomCostDto>(this as ItemBomCostDto, _$identity);

  /// Serializes this ItemBomCostDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemBomCostDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,description,amount,sortOrder,createdAt,updatedAt);

@override
String toString() {
  return 'ItemBomCostDto(id: $id, itemId: $itemId, description: $description, amount: $amount, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ItemBomCostDtoCopyWith<$Res>  {
  factory $ItemBomCostDtoCopyWith(ItemBomCostDto value, $Res Function(ItemBomCostDto) _then) = _$ItemBomCostDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId, String description, String amount,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$ItemBomCostDtoCopyWithImpl<$Res>
    implements $ItemBomCostDtoCopyWith<$Res> {
  _$ItemBomCostDtoCopyWithImpl(this._self, this._then);

  final ItemBomCostDto _self;
  final $Res Function(ItemBomCostDto) _then;

/// Create a copy of ItemBomCostDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? description = null,Object? amount = null,Object? sortOrder = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemBomCostDto].
extension ItemBomCostDtoPatterns on ItemBomCostDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemBomCostDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemBomCostDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemBomCostDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemBomCostDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemBomCostDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemBomCostDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId,  String description,  String amount, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemBomCostDto() when $default != null:
return $default(_that.id,_that.itemId,_that.description,_that.amount,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId,  String description,  String amount, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ItemBomCostDto():
return $default(_that.id,_that.itemId,_that.description,_that.amount,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'item_id')  String itemId,  String description,  String amount, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ItemBomCostDto() when $default != null:
return $default(_that.id,_that.itemId,_that.description,_that.amount,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemBomCostDto implements ItemBomCostDto {
  const _ItemBomCostDto({required this.id, @JsonKey(name: 'item_id') required this.itemId, required this.description, this.amount = '0', @JsonKey(name: 'sort_order') this.sortOrder = 0, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _ItemBomCostDto.fromJson(Map<String, dynamic> json) => _$ItemBomCostDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'item_id') final  String itemId;
@override final  String description;
@override@JsonKey() final  String amount;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of ItemBomCostDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemBomCostDtoCopyWith<_ItemBomCostDto> get copyWith => __$ItemBomCostDtoCopyWithImpl<_ItemBomCostDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemBomCostDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemBomCostDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,description,amount,sortOrder,createdAt,updatedAt);

@override
String toString() {
  return 'ItemBomCostDto(id: $id, itemId: $itemId, description: $description, amount: $amount, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ItemBomCostDtoCopyWith<$Res> implements $ItemBomCostDtoCopyWith<$Res> {
  factory _$ItemBomCostDtoCopyWith(_ItemBomCostDto value, $Res Function(_ItemBomCostDto) _then) = __$ItemBomCostDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId, String description, String amount,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$ItemBomCostDtoCopyWithImpl<$Res>
    implements _$ItemBomCostDtoCopyWith<$Res> {
  __$ItemBomCostDtoCopyWithImpl(this._self, this._then);

  final _ItemBomCostDto _self;
  final $Res Function(_ItemBomCostDto) _then;

/// Create a copy of ItemBomCostDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? description = null,Object? amount = null,Object? sortOrder = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ItemBomCostDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ItemBomDto {

 List<ItemBomMaterialDto> get materials; List<ItemBomCostDto> get costs;
/// Create a copy of ItemBomDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemBomDtoCopyWith<ItemBomDto> get copyWith => _$ItemBomDtoCopyWithImpl<ItemBomDto>(this as ItemBomDto, _$identity);

  /// Serializes this ItemBomDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemBomDto&&const DeepCollectionEquality().equals(other.materials, materials)&&const DeepCollectionEquality().equals(other.costs, costs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(materials),const DeepCollectionEquality().hash(costs));

@override
String toString() {
  return 'ItemBomDto(materials: $materials, costs: $costs)';
}


}

/// @nodoc
abstract mixin class $ItemBomDtoCopyWith<$Res>  {
  factory $ItemBomDtoCopyWith(ItemBomDto value, $Res Function(ItemBomDto) _then) = _$ItemBomDtoCopyWithImpl;
@useResult
$Res call({
 List<ItemBomMaterialDto> materials, List<ItemBomCostDto> costs
});




}
/// @nodoc
class _$ItemBomDtoCopyWithImpl<$Res>
    implements $ItemBomDtoCopyWith<$Res> {
  _$ItemBomDtoCopyWithImpl(this._self, this._then);

  final ItemBomDto _self;
  final $Res Function(ItemBomDto) _then;

/// Create a copy of ItemBomDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? materials = null,Object? costs = null,}) {
  return _then(_self.copyWith(
materials: null == materials ? _self.materials : materials // ignore: cast_nullable_to_non_nullable
as List<ItemBomMaterialDto>,costs: null == costs ? _self.costs : costs // ignore: cast_nullable_to_non_nullable
as List<ItemBomCostDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemBomDto].
extension ItemBomDtoPatterns on ItemBomDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemBomDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemBomDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemBomDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemBomDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemBomDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemBomDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ItemBomMaterialDto> materials,  List<ItemBomCostDto> costs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemBomDto() when $default != null:
return $default(_that.materials,_that.costs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ItemBomMaterialDto> materials,  List<ItemBomCostDto> costs)  $default,) {final _that = this;
switch (_that) {
case _ItemBomDto():
return $default(_that.materials,_that.costs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ItemBomMaterialDto> materials,  List<ItemBomCostDto> costs)?  $default,) {final _that = this;
switch (_that) {
case _ItemBomDto() when $default != null:
return $default(_that.materials,_that.costs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemBomDto implements ItemBomDto {
  const _ItemBomDto({final  List<ItemBomMaterialDto> materials = const [], final  List<ItemBomCostDto> costs = const []}): _materials = materials,_costs = costs;
  factory _ItemBomDto.fromJson(Map<String, dynamic> json) => _$ItemBomDtoFromJson(json);

 final  List<ItemBomMaterialDto> _materials;
@override@JsonKey() List<ItemBomMaterialDto> get materials {
  if (_materials is EqualUnmodifiableListView) return _materials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_materials);
}

 final  List<ItemBomCostDto> _costs;
@override@JsonKey() List<ItemBomCostDto> get costs {
  if (_costs is EqualUnmodifiableListView) return _costs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_costs);
}


/// Create a copy of ItemBomDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemBomDtoCopyWith<_ItemBomDto> get copyWith => __$ItemBomDtoCopyWithImpl<_ItemBomDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemBomDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemBomDto&&const DeepCollectionEquality().equals(other._materials, _materials)&&const DeepCollectionEquality().equals(other._costs, _costs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_materials),const DeepCollectionEquality().hash(_costs));

@override
String toString() {
  return 'ItemBomDto(materials: $materials, costs: $costs)';
}


}

/// @nodoc
abstract mixin class _$ItemBomDtoCopyWith<$Res> implements $ItemBomDtoCopyWith<$Res> {
  factory _$ItemBomDtoCopyWith(_ItemBomDto value, $Res Function(_ItemBomDto) _then) = __$ItemBomDtoCopyWithImpl;
@override @useResult
$Res call({
 List<ItemBomMaterialDto> materials, List<ItemBomCostDto> costs
});




}
/// @nodoc
class __$ItemBomDtoCopyWithImpl<$Res>
    implements _$ItemBomDtoCopyWith<$Res> {
  __$ItemBomDtoCopyWithImpl(this._self, this._then);

  final _ItemBomDto _self;
  final $Res Function(_ItemBomDto) _then;

/// Create a copy of ItemBomDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? materials = null,Object? costs = null,}) {
  return _then(_ItemBomDto(
materials: null == materials ? _self._materials : materials // ignore: cast_nullable_to_non_nullable
as List<ItemBomMaterialDto>,costs: null == costs ? _self._costs : costs // ignore: cast_nullable_to_non_nullable
as List<ItemBomCostDto>,
  ));
}


}

// dart format on
