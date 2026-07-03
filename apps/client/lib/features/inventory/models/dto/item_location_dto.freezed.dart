// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_location_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemLocationDto {

 String get id;@JsonKey(name: 'item_id') String get itemId;@JsonKey(name: 'godown_id') String get godownId;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt; String? get rack; String? get shelf;@JsonKey(name: 'photo_url') String? get photoUrl;@JsonKey(name: 'photo_taken_at') String? get photoTakenAt;
/// Create a copy of ItemLocationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemLocationDtoCopyWith<ItemLocationDto> get copyWith => _$ItemLocationDtoCopyWithImpl<ItemLocationDto>(this as ItemLocationDto, _$identity);

  /// Serializes this ItemLocationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemLocationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.godownId, godownId) || other.godownId == godownId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.rack, rack) || other.rack == rack)&&(identical(other.shelf, shelf) || other.shelf == shelf)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.photoTakenAt, photoTakenAt) || other.photoTakenAt == photoTakenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,godownId,createdAt,updatedAt,rack,shelf,photoUrl,photoTakenAt);

@override
String toString() {
  return 'ItemLocationDto(id: $id, itemId: $itemId, godownId: $godownId, createdAt: $createdAt, updatedAt: $updatedAt, rack: $rack, shelf: $shelf, photoUrl: $photoUrl, photoTakenAt: $photoTakenAt)';
}


}

/// @nodoc
abstract mixin class $ItemLocationDtoCopyWith<$Res>  {
  factory $ItemLocationDtoCopyWith(ItemLocationDto value, $Res Function(ItemLocationDto) _then) = _$ItemLocationDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'godown_id') String godownId,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, String? rack, String? shelf,@JsonKey(name: 'photo_url') String? photoUrl,@JsonKey(name: 'photo_taken_at') String? photoTakenAt
});




}
/// @nodoc
class _$ItemLocationDtoCopyWithImpl<$Res>
    implements $ItemLocationDtoCopyWith<$Res> {
  _$ItemLocationDtoCopyWithImpl(this._self, this._then);

  final ItemLocationDto _self;
  final $Res Function(ItemLocationDto) _then;

/// Create a copy of ItemLocationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? godownId = null,Object? createdAt = null,Object? updatedAt = null,Object? rack = freezed,Object? shelf = freezed,Object? photoUrl = freezed,Object? photoTakenAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,godownId: null == godownId ? _self.godownId : godownId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,rack: freezed == rack ? _self.rack : rack // ignore: cast_nullable_to_non_nullable
as String?,shelf: freezed == shelf ? _self.shelf : shelf // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,photoTakenAt: freezed == photoTakenAt ? _self.photoTakenAt : photoTakenAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemLocationDto].
extension ItemLocationDtoPatterns on ItemLocationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemLocationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemLocationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemLocationDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemLocationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemLocationDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemLocationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'godown_id')  String godownId, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? rack,  String? shelf, @JsonKey(name: 'photo_url')  String? photoUrl, @JsonKey(name: 'photo_taken_at')  String? photoTakenAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemLocationDto() when $default != null:
return $default(_that.id,_that.itemId,_that.godownId,_that.createdAt,_that.updatedAt,_that.rack,_that.shelf,_that.photoUrl,_that.photoTakenAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'godown_id')  String godownId, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? rack,  String? shelf, @JsonKey(name: 'photo_url')  String? photoUrl, @JsonKey(name: 'photo_taken_at')  String? photoTakenAt)  $default,) {final _that = this;
switch (_that) {
case _ItemLocationDto():
return $default(_that.id,_that.itemId,_that.godownId,_that.createdAt,_that.updatedAt,_that.rack,_that.shelf,_that.photoUrl,_that.photoTakenAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'godown_id')  String godownId, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? rack,  String? shelf, @JsonKey(name: 'photo_url')  String? photoUrl, @JsonKey(name: 'photo_taken_at')  String? photoTakenAt)?  $default,) {final _that = this;
switch (_that) {
case _ItemLocationDto() when $default != null:
return $default(_that.id,_that.itemId,_that.godownId,_that.createdAt,_that.updatedAt,_that.rack,_that.shelf,_that.photoUrl,_that.photoTakenAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemLocationDto implements ItemLocationDto {
  const _ItemLocationDto({required this.id, @JsonKey(name: 'item_id') required this.itemId, @JsonKey(name: 'godown_id') required this.godownId, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.rack, this.shelf, @JsonKey(name: 'photo_url') this.photoUrl, @JsonKey(name: 'photo_taken_at') this.photoTakenAt});
  factory _ItemLocationDto.fromJson(Map<String, dynamic> json) => _$ItemLocationDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'item_id') final  String itemId;
@override@JsonKey(name: 'godown_id') final  String godownId;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override final  String? rack;
@override final  String? shelf;
@override@JsonKey(name: 'photo_url') final  String? photoUrl;
@override@JsonKey(name: 'photo_taken_at') final  String? photoTakenAt;

/// Create a copy of ItemLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemLocationDtoCopyWith<_ItemLocationDto> get copyWith => __$ItemLocationDtoCopyWithImpl<_ItemLocationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemLocationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemLocationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.godownId, godownId) || other.godownId == godownId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.rack, rack) || other.rack == rack)&&(identical(other.shelf, shelf) || other.shelf == shelf)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.photoTakenAt, photoTakenAt) || other.photoTakenAt == photoTakenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,godownId,createdAt,updatedAt,rack,shelf,photoUrl,photoTakenAt);

@override
String toString() {
  return 'ItemLocationDto(id: $id, itemId: $itemId, godownId: $godownId, createdAt: $createdAt, updatedAt: $updatedAt, rack: $rack, shelf: $shelf, photoUrl: $photoUrl, photoTakenAt: $photoTakenAt)';
}


}

/// @nodoc
abstract mixin class _$ItemLocationDtoCopyWith<$Res> implements $ItemLocationDtoCopyWith<$Res> {
  factory _$ItemLocationDtoCopyWith(_ItemLocationDto value, $Res Function(_ItemLocationDto) _then) = __$ItemLocationDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'godown_id') String godownId,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, String? rack, String? shelf,@JsonKey(name: 'photo_url') String? photoUrl,@JsonKey(name: 'photo_taken_at') String? photoTakenAt
});




}
/// @nodoc
class __$ItemLocationDtoCopyWithImpl<$Res>
    implements _$ItemLocationDtoCopyWith<$Res> {
  __$ItemLocationDtoCopyWithImpl(this._self, this._then);

  final _ItemLocationDto _self;
  final $Res Function(_ItemLocationDto) _then;

/// Create a copy of ItemLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? godownId = null,Object? createdAt = null,Object? updatedAt = null,Object? rack = freezed,Object? shelf = freezed,Object? photoUrl = freezed,Object? photoTakenAt = freezed,}) {
  return _then(_ItemLocationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,godownId: null == godownId ? _self.godownId : godownId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,rack: freezed == rack ? _self.rack : rack // ignore: cast_nullable_to_non_nullable
as String?,shelf: freezed == shelf ? _self.shelf : shelf // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,photoTakenAt: freezed == photoTakenAt ? _self.photoTakenAt : photoTakenAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
