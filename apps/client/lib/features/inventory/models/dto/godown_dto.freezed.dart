// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'godown_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GodownDto {

 String get id; String get name;@JsonKey(name: 'is_default') bool get isDefault;@JsonKey(name: 'stock_item_count') int get stockItemCount;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt; String? get address;
/// Create a copy of GodownDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GodownDtoCopyWith<GodownDto> get copyWith => _$GodownDtoCopyWithImpl<GodownDto>(this as GodownDto, _$identity);

  /// Serializes this GodownDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GodownDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.stockItemCount, stockItemCount) || other.stockItemCount == stockItemCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isDefault,stockItemCount,createdAt,updatedAt,address);

@override
String toString() {
  return 'GodownDto(id: $id, name: $name, isDefault: $isDefault, stockItemCount: $stockItemCount, createdAt: $createdAt, updatedAt: $updatedAt, address: $address)';
}


}

/// @nodoc
abstract mixin class $GodownDtoCopyWith<$Res>  {
  factory $GodownDtoCopyWith(GodownDto value, $Res Function(GodownDto) _then) = _$GodownDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'is_default') bool isDefault,@JsonKey(name: 'stock_item_count') int stockItemCount,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, String? address
});




}
/// @nodoc
class _$GodownDtoCopyWithImpl<$Res>
    implements $GodownDtoCopyWith<$Res> {
  _$GodownDtoCopyWithImpl(this._self, this._then);

  final GodownDto _self;
  final $Res Function(GodownDto) _then;

/// Create a copy of GodownDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isDefault = null,Object? stockItemCount = null,Object? createdAt = null,Object? updatedAt = null,Object? address = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,stockItemCount: null == stockItemCount ? _self.stockItemCount : stockItemCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GodownDto].
extension GodownDtoPatterns on GodownDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GodownDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GodownDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GodownDto value)  $default,){
final _that = this;
switch (_that) {
case _GodownDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GodownDto value)?  $default,){
final _that = this;
switch (_that) {
case _GodownDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'stock_item_count')  int stockItemCount, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GodownDto() when $default != null:
return $default(_that.id,_that.name,_that.isDefault,_that.stockItemCount,_that.createdAt,_that.updatedAt,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'stock_item_count')  int stockItemCount, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? address)  $default,) {final _that = this;
switch (_that) {
case _GodownDto():
return $default(_that.id,_that.name,_that.isDefault,_that.stockItemCount,_that.createdAt,_that.updatedAt,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'is_default')  bool isDefault, @JsonKey(name: 'stock_item_count')  int stockItemCount, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? address)?  $default,) {final _that = this;
switch (_that) {
case _GodownDto() when $default != null:
return $default(_that.id,_that.name,_that.isDefault,_that.stockItemCount,_that.createdAt,_that.updatedAt,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GodownDto implements GodownDto {
  const _GodownDto({required this.id, required this.name, @JsonKey(name: 'is_default') required this.isDefault, @JsonKey(name: 'stock_item_count') required this.stockItemCount, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.address});
  factory _GodownDto.fromJson(Map<String, dynamic> json) => _$GodownDtoFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'is_default') final  bool isDefault;
@override@JsonKey(name: 'stock_item_count') final  int stockItemCount;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override final  String? address;

/// Create a copy of GodownDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GodownDtoCopyWith<_GodownDto> get copyWith => __$GodownDtoCopyWithImpl<_GodownDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GodownDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GodownDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.stockItemCount, stockItemCount) || other.stockItemCount == stockItemCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isDefault,stockItemCount,createdAt,updatedAt,address);

@override
String toString() {
  return 'GodownDto(id: $id, name: $name, isDefault: $isDefault, stockItemCount: $stockItemCount, createdAt: $createdAt, updatedAt: $updatedAt, address: $address)';
}


}

/// @nodoc
abstract mixin class _$GodownDtoCopyWith<$Res> implements $GodownDtoCopyWith<$Res> {
  factory _$GodownDtoCopyWith(_GodownDto value, $Res Function(_GodownDto) _then) = __$GodownDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'is_default') bool isDefault,@JsonKey(name: 'stock_item_count') int stockItemCount,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, String? address
});




}
/// @nodoc
class __$GodownDtoCopyWithImpl<$Res>
    implements _$GodownDtoCopyWith<$Res> {
  __$GodownDtoCopyWithImpl(this._self, this._then);

  final _GodownDto _self;
  final $Res Function(_GodownDto) _then;

/// Create a copy of GodownDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isDefault = null,Object? stockItemCount = null,Object? createdAt = null,Object? updatedAt = null,Object? address = freezed,}) {
  return _then(_GodownDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,stockItemCount: null == stockItemCount ? _self.stockItemCount : stockItemCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
