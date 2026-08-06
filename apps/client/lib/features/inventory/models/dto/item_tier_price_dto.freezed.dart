// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_tier_price_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemTierPriceDto {

 String get id;@JsonKey(name: 'item_id') String get itemId;@JsonKey(name: 'pricing_tier') String get pricingTier; double get price;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of ItemTierPriceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemTierPriceDtoCopyWith<ItemTierPriceDto> get copyWith => _$ItemTierPriceDtoCopyWithImpl<ItemTierPriceDto>(this as ItemTierPriceDto, _$identity);

  /// Serializes this ItemTierPriceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemTierPriceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.pricingTier, pricingTier) || other.pricingTier == pricingTier)&&(identical(other.price, price) || other.price == price)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,pricingTier,price,createdAt,updatedAt);

@override
String toString() {
  return 'ItemTierPriceDto(id: $id, itemId: $itemId, pricingTier: $pricingTier, price: $price, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ItemTierPriceDtoCopyWith<$Res>  {
  factory $ItemTierPriceDtoCopyWith(ItemTierPriceDto value, $Res Function(ItemTierPriceDto) _then) = _$ItemTierPriceDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'pricing_tier') String pricingTier, double price,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$ItemTierPriceDtoCopyWithImpl<$Res>
    implements $ItemTierPriceDtoCopyWith<$Res> {
  _$ItemTierPriceDtoCopyWithImpl(this._self, this._then);

  final ItemTierPriceDto _self;
  final $Res Function(ItemTierPriceDto) _then;

/// Create a copy of ItemTierPriceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? pricingTier = null,Object? price = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,pricingTier: null == pricingTier ? _self.pricingTier : pricingTier // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemTierPriceDto].
extension ItemTierPriceDtoPatterns on ItemTierPriceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemTierPriceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemTierPriceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemTierPriceDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemTierPriceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemTierPriceDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemTierPriceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'pricing_tier')  String pricingTier,  double price, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemTierPriceDto() when $default != null:
return $default(_that.id,_that.itemId,_that.pricingTier,_that.price,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'pricing_tier')  String pricingTier,  double price, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ItemTierPriceDto():
return $default(_that.id,_that.itemId,_that.pricingTier,_that.price,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'pricing_tier')  String pricingTier,  double price, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ItemTierPriceDto() when $default != null:
return $default(_that.id,_that.itemId,_that.pricingTier,_that.price,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemTierPriceDto implements ItemTierPriceDto {
  const _ItemTierPriceDto({required this.id, @JsonKey(name: 'item_id') required this.itemId, @JsonKey(name: 'pricing_tier') required this.pricingTier, required this.price, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _ItemTierPriceDto.fromJson(Map<String, dynamic> json) => _$ItemTierPriceDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'item_id') final  String itemId;
@override@JsonKey(name: 'pricing_tier') final  String pricingTier;
@override final  double price;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of ItemTierPriceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemTierPriceDtoCopyWith<_ItemTierPriceDto> get copyWith => __$ItemTierPriceDtoCopyWithImpl<_ItemTierPriceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemTierPriceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemTierPriceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.pricingTier, pricingTier) || other.pricingTier == pricingTier)&&(identical(other.price, price) || other.price == price)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,pricingTier,price,createdAt,updatedAt);

@override
String toString() {
  return 'ItemTierPriceDto(id: $id, itemId: $itemId, pricingTier: $pricingTier, price: $price, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ItemTierPriceDtoCopyWith<$Res> implements $ItemTierPriceDtoCopyWith<$Res> {
  factory _$ItemTierPriceDtoCopyWith(_ItemTierPriceDto value, $Res Function(_ItemTierPriceDto) _then) = __$ItemTierPriceDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'pricing_tier') String pricingTier, double price,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$ItemTierPriceDtoCopyWithImpl<$Res>
    implements _$ItemTierPriceDtoCopyWith<$Res> {
  __$ItemTierPriceDtoCopyWithImpl(this._self, this._then);

  final _ItemTierPriceDto _self;
  final $Res Function(_ItemTierPriceDto) _then;

/// Create a copy of ItemTierPriceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? pricingTier = null,Object? price = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ItemTierPriceDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,pricingTier: null == pricingTier ? _self.pricingTier : pricingTier // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
