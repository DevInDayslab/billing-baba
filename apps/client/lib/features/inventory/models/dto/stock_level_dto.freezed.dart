// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_level_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StockLevelDto {

 String get id;@JsonKey(name: 'item_id') String get itemId;@JsonKey(name: 'item_name') String get itemName;@JsonKey(name: 'godown_id') String get godownId;@JsonKey(name: 'godown_name') String get godownName; String get quantity;@JsonKey(name: 'average_cost') String get averageCost;@JsonKey(name: 'is_low_stock') bool get isLowStock;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;@JsonKey(name: 'reorder_level') String? get reorderLevel;
/// Create a copy of StockLevelDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockLevelDtoCopyWith<StockLevelDto> get copyWith => _$StockLevelDtoCopyWithImpl<StockLevelDto>(this as StockLevelDto, _$identity);

  /// Serializes this StockLevelDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockLevelDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.godownId, godownId) || other.godownId == godownId)&&(identical(other.godownName, godownName) || other.godownName == godownName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.averageCost, averageCost) || other.averageCost == averageCost)&&(identical(other.isLowStock, isLowStock) || other.isLowStock == isLowStock)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.reorderLevel, reorderLevel) || other.reorderLevel == reorderLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,itemName,godownId,godownName,quantity,averageCost,isLowStock,createdAt,updatedAt,reorderLevel);

@override
String toString() {
  return 'StockLevelDto(id: $id, itemId: $itemId, itemName: $itemName, godownId: $godownId, godownName: $godownName, quantity: $quantity, averageCost: $averageCost, isLowStock: $isLowStock, createdAt: $createdAt, updatedAt: $updatedAt, reorderLevel: $reorderLevel)';
}


}

/// @nodoc
abstract mixin class $StockLevelDtoCopyWith<$Res>  {
  factory $StockLevelDtoCopyWith(StockLevelDto value, $Res Function(StockLevelDto) _then) = _$StockLevelDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'item_name') String itemName,@JsonKey(name: 'godown_id') String godownId,@JsonKey(name: 'godown_name') String godownName, String quantity,@JsonKey(name: 'average_cost') String averageCost,@JsonKey(name: 'is_low_stock') bool isLowStock,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt,@JsonKey(name: 'reorder_level') String? reorderLevel
});




}
/// @nodoc
class _$StockLevelDtoCopyWithImpl<$Res>
    implements $StockLevelDtoCopyWith<$Res> {
  _$StockLevelDtoCopyWithImpl(this._self, this._then);

  final StockLevelDto _self;
  final $Res Function(StockLevelDto) _then;

/// Create a copy of StockLevelDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? itemName = null,Object? godownId = null,Object? godownName = null,Object? quantity = null,Object? averageCost = null,Object? isLowStock = null,Object? createdAt = null,Object? updatedAt = null,Object? reorderLevel = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,godownId: null == godownId ? _self.godownId : godownId // ignore: cast_nullable_to_non_nullable
as String,godownName: null == godownName ? _self.godownName : godownName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,averageCost: null == averageCost ? _self.averageCost : averageCost // ignore: cast_nullable_to_non_nullable
as String,isLowStock: null == isLowStock ? _self.isLowStock : isLowStock // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,reorderLevel: freezed == reorderLevel ? _self.reorderLevel : reorderLevel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StockLevelDto].
extension StockLevelDtoPatterns on StockLevelDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockLevelDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockLevelDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockLevelDto value)  $default,){
final _that = this;
switch (_that) {
case _StockLevelDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockLevelDto value)?  $default,){
final _that = this;
switch (_that) {
case _StockLevelDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'item_name')  String itemName, @JsonKey(name: 'godown_id')  String godownId, @JsonKey(name: 'godown_name')  String godownName,  String quantity, @JsonKey(name: 'average_cost')  String averageCost, @JsonKey(name: 'is_low_stock')  bool isLowStock, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'reorder_level')  String? reorderLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockLevelDto() when $default != null:
return $default(_that.id,_that.itemId,_that.itemName,_that.godownId,_that.godownName,_that.quantity,_that.averageCost,_that.isLowStock,_that.createdAt,_that.updatedAt,_that.reorderLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'item_name')  String itemName, @JsonKey(name: 'godown_id')  String godownId, @JsonKey(name: 'godown_name')  String godownName,  String quantity, @JsonKey(name: 'average_cost')  String averageCost, @JsonKey(name: 'is_low_stock')  bool isLowStock, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'reorder_level')  String? reorderLevel)  $default,) {final _that = this;
switch (_that) {
case _StockLevelDto():
return $default(_that.id,_that.itemId,_that.itemName,_that.godownId,_that.godownName,_that.quantity,_that.averageCost,_that.isLowStock,_that.createdAt,_that.updatedAt,_that.reorderLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'item_name')  String itemName, @JsonKey(name: 'godown_id')  String godownId, @JsonKey(name: 'godown_name')  String godownName,  String quantity, @JsonKey(name: 'average_cost')  String averageCost, @JsonKey(name: 'is_low_stock')  bool isLowStock, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'reorder_level')  String? reorderLevel)?  $default,) {final _that = this;
switch (_that) {
case _StockLevelDto() when $default != null:
return $default(_that.id,_that.itemId,_that.itemName,_that.godownId,_that.godownName,_that.quantity,_that.averageCost,_that.isLowStock,_that.createdAt,_that.updatedAt,_that.reorderLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockLevelDto implements StockLevelDto {
  const _StockLevelDto({required this.id, @JsonKey(name: 'item_id') required this.itemId, @JsonKey(name: 'item_name') required this.itemName, @JsonKey(name: 'godown_id') required this.godownId, @JsonKey(name: 'godown_name') required this.godownName, required this.quantity, @JsonKey(name: 'average_cost') required this.averageCost, @JsonKey(name: 'is_low_stock') required this.isLowStock, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'reorder_level') this.reorderLevel});
  factory _StockLevelDto.fromJson(Map<String, dynamic> json) => _$StockLevelDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'item_id') final  String itemId;
@override@JsonKey(name: 'item_name') final  String itemName;
@override@JsonKey(name: 'godown_id') final  String godownId;
@override@JsonKey(name: 'godown_name') final  String godownName;
@override final  String quantity;
@override@JsonKey(name: 'average_cost') final  String averageCost;
@override@JsonKey(name: 'is_low_stock') final  bool isLowStock;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override@JsonKey(name: 'reorder_level') final  String? reorderLevel;

/// Create a copy of StockLevelDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockLevelDtoCopyWith<_StockLevelDto> get copyWith => __$StockLevelDtoCopyWithImpl<_StockLevelDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockLevelDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockLevelDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.godownId, godownId) || other.godownId == godownId)&&(identical(other.godownName, godownName) || other.godownName == godownName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.averageCost, averageCost) || other.averageCost == averageCost)&&(identical(other.isLowStock, isLowStock) || other.isLowStock == isLowStock)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.reorderLevel, reorderLevel) || other.reorderLevel == reorderLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,itemName,godownId,godownName,quantity,averageCost,isLowStock,createdAt,updatedAt,reorderLevel);

@override
String toString() {
  return 'StockLevelDto(id: $id, itemId: $itemId, itemName: $itemName, godownId: $godownId, godownName: $godownName, quantity: $quantity, averageCost: $averageCost, isLowStock: $isLowStock, createdAt: $createdAt, updatedAt: $updatedAt, reorderLevel: $reorderLevel)';
}


}

/// @nodoc
abstract mixin class _$StockLevelDtoCopyWith<$Res> implements $StockLevelDtoCopyWith<$Res> {
  factory _$StockLevelDtoCopyWith(_StockLevelDto value, $Res Function(_StockLevelDto) _then) = __$StockLevelDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'item_name') String itemName,@JsonKey(name: 'godown_id') String godownId,@JsonKey(name: 'godown_name') String godownName, String quantity,@JsonKey(name: 'average_cost') String averageCost,@JsonKey(name: 'is_low_stock') bool isLowStock,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt,@JsonKey(name: 'reorder_level') String? reorderLevel
});




}
/// @nodoc
class __$StockLevelDtoCopyWithImpl<$Res>
    implements _$StockLevelDtoCopyWith<$Res> {
  __$StockLevelDtoCopyWithImpl(this._self, this._then);

  final _StockLevelDto _self;
  final $Res Function(_StockLevelDto) _then;

/// Create a copy of StockLevelDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? itemName = null,Object? godownId = null,Object? godownName = null,Object? quantity = null,Object? averageCost = null,Object? isLowStock = null,Object? createdAt = null,Object? updatedAt = null,Object? reorderLevel = freezed,}) {
  return _then(_StockLevelDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,godownId: null == godownId ? _self.godownId : godownId // ignore: cast_nullable_to_non_nullable
as String,godownName: null == godownName ? _self.godownName : godownName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,averageCost: null == averageCost ? _self.averageCost : averageCost // ignore: cast_nullable_to_non_nullable
as String,isLowStock: null == isLowStock ? _self.isLowStock : isLowStock // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,reorderLevel: freezed == reorderLevel ? _self.reorderLevel : reorderLevel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
