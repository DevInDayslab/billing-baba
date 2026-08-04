// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_supplier_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemSupplierDto {

 String get id;@JsonKey(name: 'item_id') String get itemId;@JsonKey(name: 'party_id') String get partyId;@JsonKey(name: 'is_default') bool get isDefault;@JsonKey(name: 'sort_order') int get sortOrder;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of ItemSupplierDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemSupplierDtoCopyWith<ItemSupplierDto> get copyWith => _$ItemSupplierDtoCopyWithImpl<ItemSupplierDto>(this as ItemSupplierDto, _$identity);

  /// Serializes this ItemSupplierDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemSupplierDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.partyId, partyId) || other.partyId == partyId)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,partyId,isDefault,sortOrder,createdAt,updatedAt);

@override
String toString() {
  return 'ItemSupplierDto(id: $id, itemId: $itemId, partyId: $partyId, isDefault: $isDefault, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ItemSupplierDtoCopyWith<$Res>  {
  factory $ItemSupplierDtoCopyWith(ItemSupplierDto value, $Res Function(ItemSupplierDto) _then) = _$ItemSupplierDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'party_id') String partyId,@JsonKey(name: 'is_default') bool isDefault,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$ItemSupplierDtoCopyWithImpl<$Res>
    implements $ItemSupplierDtoCopyWith<$Res> {
  _$ItemSupplierDtoCopyWithImpl(this._self, this._then);

  final ItemSupplierDto _self;
  final $Res Function(ItemSupplierDto) _then;

/// Create a copy of ItemSupplierDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? partyId = null,Object? isDefault = null,Object? sortOrder = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,partyId: null == partyId ? _self.partyId : partyId // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemSupplierDto].
extension ItemSupplierDtoPatterns on ItemSupplierDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemSupplierDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemSupplierDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemSupplierDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemSupplierDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemSupplierDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemSupplierDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'party_id')  String partyId, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemSupplierDto() when $default != null:
return $default(_that.id,_that.itemId,_that.partyId,_that.isDefault,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'party_id')  String partyId, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ItemSupplierDto():
return $default(_that.id,_that.itemId,_that.partyId,_that.isDefault,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'party_id')  String partyId, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ItemSupplierDto() when $default != null:
return $default(_that.id,_that.itemId,_that.partyId,_that.isDefault,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemSupplierDto implements ItemSupplierDto {
  const _ItemSupplierDto({required this.id, @JsonKey(name: 'item_id') required this.itemId, @JsonKey(name: 'party_id') required this.partyId, @JsonKey(name: 'is_default') this.isDefault = false, @JsonKey(name: 'sort_order') this.sortOrder = 0, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _ItemSupplierDto.fromJson(Map<String, dynamic> json) => _$ItemSupplierDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'item_id') final  String itemId;
@override@JsonKey(name: 'party_id') final  String partyId;
@override@JsonKey(name: 'is_default') final  bool isDefault;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of ItemSupplierDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemSupplierDtoCopyWith<_ItemSupplierDto> get copyWith => __$ItemSupplierDtoCopyWithImpl<_ItemSupplierDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemSupplierDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemSupplierDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.partyId, partyId) || other.partyId == partyId)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,partyId,isDefault,sortOrder,createdAt,updatedAt);

@override
String toString() {
  return 'ItemSupplierDto(id: $id, itemId: $itemId, partyId: $partyId, isDefault: $isDefault, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ItemSupplierDtoCopyWith<$Res> implements $ItemSupplierDtoCopyWith<$Res> {
  factory _$ItemSupplierDtoCopyWith(_ItemSupplierDto value, $Res Function(_ItemSupplierDto) _then) = __$ItemSupplierDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'party_id') String partyId,@JsonKey(name: 'is_default') bool isDefault,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$ItemSupplierDtoCopyWithImpl<$Res>
    implements _$ItemSupplierDtoCopyWith<$Res> {
  __$ItemSupplierDtoCopyWithImpl(this._self, this._then);

  final _ItemSupplierDto _self;
  final $Res Function(_ItemSupplierDto) _then;

/// Create a copy of ItemSupplierDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? partyId = null,Object? isDefault = null,Object? sortOrder = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ItemSupplierDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,partyId: null == partyId ? _self.partyId : partyId // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
