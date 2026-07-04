// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_history_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PriceHistoryDto {

 String get id;@JsonKey(name: 'item_id') String get itemId;@JsonKey(name: 'item_name') String get itemName; String get price;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'pricing_tier') String? get pricingTier;@JsonKey(name: 'changed_by') String? get changedBy;
/// Create a copy of PriceHistoryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceHistoryDtoCopyWith<PriceHistoryDto> get copyWith => _$PriceHistoryDtoCopyWithImpl<PriceHistoryDto>(this as PriceHistoryDto, _$identity);

  /// Serializes this PriceHistoryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceHistoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.price, price) || other.price == price)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.pricingTier, pricingTier) || other.pricingTier == pricingTier)&&(identical(other.changedBy, changedBy) || other.changedBy == changedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,itemName,price,createdAt,pricingTier,changedBy);

@override
String toString() {
  return 'PriceHistoryDto(id: $id, itemId: $itemId, itemName: $itemName, price: $price, createdAt: $createdAt, pricingTier: $pricingTier, changedBy: $changedBy)';
}


}

/// @nodoc
abstract mixin class $PriceHistoryDtoCopyWith<$Res>  {
  factory $PriceHistoryDtoCopyWith(PriceHistoryDto value, $Res Function(PriceHistoryDto) _then) = _$PriceHistoryDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'item_name') String itemName, String price,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'pricing_tier') String? pricingTier,@JsonKey(name: 'changed_by') String? changedBy
});




}
/// @nodoc
class _$PriceHistoryDtoCopyWithImpl<$Res>
    implements $PriceHistoryDtoCopyWith<$Res> {
  _$PriceHistoryDtoCopyWithImpl(this._self, this._then);

  final PriceHistoryDto _self;
  final $Res Function(PriceHistoryDto) _then;

/// Create a copy of PriceHistoryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? itemName = null,Object? price = null,Object? createdAt = null,Object? pricingTier = freezed,Object? changedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,pricingTier: freezed == pricingTier ? _self.pricingTier : pricingTier // ignore: cast_nullable_to_non_nullable
as String?,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceHistoryDto].
extension PriceHistoryDtoPatterns on PriceHistoryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceHistoryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceHistoryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceHistoryDto value)  $default,){
final _that = this;
switch (_that) {
case _PriceHistoryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceHistoryDto value)?  $default,){
final _that = this;
switch (_that) {
case _PriceHistoryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'item_name')  String itemName,  String price, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'pricing_tier')  String? pricingTier, @JsonKey(name: 'changed_by')  String? changedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceHistoryDto() when $default != null:
return $default(_that.id,_that.itemId,_that.itemName,_that.price,_that.createdAt,_that.pricingTier,_that.changedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'item_name')  String itemName,  String price, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'pricing_tier')  String? pricingTier, @JsonKey(name: 'changed_by')  String? changedBy)  $default,) {final _that = this;
switch (_that) {
case _PriceHistoryDto():
return $default(_that.id,_that.itemId,_that.itemName,_that.price,_that.createdAt,_that.pricingTier,_that.changedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'item_name')  String itemName,  String price, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'pricing_tier')  String? pricingTier, @JsonKey(name: 'changed_by')  String? changedBy)?  $default,) {final _that = this;
switch (_that) {
case _PriceHistoryDto() when $default != null:
return $default(_that.id,_that.itemId,_that.itemName,_that.price,_that.createdAt,_that.pricingTier,_that.changedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceHistoryDto implements PriceHistoryDto {
  const _PriceHistoryDto({required this.id, @JsonKey(name: 'item_id') required this.itemId, @JsonKey(name: 'item_name') required this.itemName, required this.price, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'pricing_tier') this.pricingTier, @JsonKey(name: 'changed_by') this.changedBy});
  factory _PriceHistoryDto.fromJson(Map<String, dynamic> json) => _$PriceHistoryDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'item_id') final  String itemId;
@override@JsonKey(name: 'item_name') final  String itemName;
@override final  String price;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'pricing_tier') final  String? pricingTier;
@override@JsonKey(name: 'changed_by') final  String? changedBy;

/// Create a copy of PriceHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceHistoryDtoCopyWith<_PriceHistoryDto> get copyWith => __$PriceHistoryDtoCopyWithImpl<_PriceHistoryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceHistoryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceHistoryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.price, price) || other.price == price)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.pricingTier, pricingTier) || other.pricingTier == pricingTier)&&(identical(other.changedBy, changedBy) || other.changedBy == changedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,itemName,price,createdAt,pricingTier,changedBy);

@override
String toString() {
  return 'PriceHistoryDto(id: $id, itemId: $itemId, itemName: $itemName, price: $price, createdAt: $createdAt, pricingTier: $pricingTier, changedBy: $changedBy)';
}


}

/// @nodoc
abstract mixin class _$PriceHistoryDtoCopyWith<$Res> implements $PriceHistoryDtoCopyWith<$Res> {
  factory _$PriceHistoryDtoCopyWith(_PriceHistoryDto value, $Res Function(_PriceHistoryDto) _then) = __$PriceHistoryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'item_name') String itemName, String price,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'pricing_tier') String? pricingTier,@JsonKey(name: 'changed_by') String? changedBy
});




}
/// @nodoc
class __$PriceHistoryDtoCopyWithImpl<$Res>
    implements _$PriceHistoryDtoCopyWith<$Res> {
  __$PriceHistoryDtoCopyWithImpl(this._self, this._then);

  final _PriceHistoryDto _self;
  final $Res Function(_PriceHistoryDto) _then;

/// Create a copy of PriceHistoryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? itemName = null,Object? price = null,Object? createdAt = null,Object? pricingTier = freezed,Object? changedBy = freezed,}) {
  return _then(_PriceHistoryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,pricingTier: freezed == pricingTier ? _self.pricingTier : pricingTier // ignore: cast_nullable_to_non_nullable
as String?,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
