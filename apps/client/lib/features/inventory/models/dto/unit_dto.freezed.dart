// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unit_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UnitListDto {

 String get id; String get name;@JsonKey(name: 'short_name') String get shortName;@JsonKey(name: 'decimal_places') int get decimalPlaces;@JsonKey(name: 'is_system') bool get isSystem;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'conversion_count') int get conversionCount;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt; String? get symbol;
/// Create a copy of UnitListDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitListDtoCopyWith<UnitListDto> get copyWith => _$UnitListDtoCopyWithImpl<UnitListDto>(this as UnitListDto, _$identity);

  /// Serializes this UnitListDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnitListDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.decimalPlaces, decimalPlaces) || other.decimalPlaces == decimalPlaces)&&(identical(other.isSystem, isSystem) || other.isSystem == isSystem)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.conversionCount, conversionCount) || other.conversionCount == conversionCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.symbol, symbol) || other.symbol == symbol));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,shortName,decimalPlaces,isSystem,isActive,conversionCount,createdAt,updatedAt,symbol);

@override
String toString() {
  return 'UnitListDto(id: $id, name: $name, shortName: $shortName, decimalPlaces: $decimalPlaces, isSystem: $isSystem, isActive: $isActive, conversionCount: $conversionCount, createdAt: $createdAt, updatedAt: $updatedAt, symbol: $symbol)';
}


}

/// @nodoc
abstract mixin class $UnitListDtoCopyWith<$Res>  {
  factory $UnitListDtoCopyWith(UnitListDto value, $Res Function(UnitListDto) _then) = _$UnitListDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'short_name') String shortName,@JsonKey(name: 'decimal_places') int decimalPlaces,@JsonKey(name: 'is_system') bool isSystem,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'conversion_count') int conversionCount,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, String? symbol
});




}
/// @nodoc
class _$UnitListDtoCopyWithImpl<$Res>
    implements $UnitListDtoCopyWith<$Res> {
  _$UnitListDtoCopyWithImpl(this._self, this._then);

  final UnitListDto _self;
  final $Res Function(UnitListDto) _then;

/// Create a copy of UnitListDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? shortName = null,Object? decimalPlaces = null,Object? isSystem = null,Object? isActive = null,Object? conversionCount = null,Object? createdAt = null,Object? updatedAt = null,Object? symbol = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,decimalPlaces: null == decimalPlaces ? _self.decimalPlaces : decimalPlaces // ignore: cast_nullable_to_non_nullable
as int,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,conversionCount: null == conversionCount ? _self.conversionCount : conversionCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UnitListDto].
extension UnitListDtoPatterns on UnitListDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnitListDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnitListDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnitListDto value)  $default,){
final _that = this;
switch (_that) {
case _UnitListDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnitListDto value)?  $default,){
final _that = this;
switch (_that) {
case _UnitListDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'short_name')  String shortName, @JsonKey(name: 'decimal_places')  int decimalPlaces, @JsonKey(name: 'is_system')  bool isSystem, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'conversion_count')  int conversionCount, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? symbol)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnitListDto() when $default != null:
return $default(_that.id,_that.name,_that.shortName,_that.decimalPlaces,_that.isSystem,_that.isActive,_that.conversionCount,_that.createdAt,_that.updatedAt,_that.symbol);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'short_name')  String shortName, @JsonKey(name: 'decimal_places')  int decimalPlaces, @JsonKey(name: 'is_system')  bool isSystem, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'conversion_count')  int conversionCount, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? symbol)  $default,) {final _that = this;
switch (_that) {
case _UnitListDto():
return $default(_that.id,_that.name,_that.shortName,_that.decimalPlaces,_that.isSystem,_that.isActive,_that.conversionCount,_that.createdAt,_that.updatedAt,_that.symbol);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'short_name')  String shortName, @JsonKey(name: 'decimal_places')  int decimalPlaces, @JsonKey(name: 'is_system')  bool isSystem, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'conversion_count')  int conversionCount, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? symbol)?  $default,) {final _that = this;
switch (_that) {
case _UnitListDto() when $default != null:
return $default(_that.id,_that.name,_that.shortName,_that.decimalPlaces,_that.isSystem,_that.isActive,_that.conversionCount,_that.createdAt,_that.updatedAt,_that.symbol);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnitListDto implements UnitListDto {
  const _UnitListDto({required this.id, required this.name, @JsonKey(name: 'short_name') required this.shortName, @JsonKey(name: 'decimal_places') required this.decimalPlaces, @JsonKey(name: 'is_system') required this.isSystem, @JsonKey(name: 'is_active') required this.isActive, @JsonKey(name: 'conversion_count') required this.conversionCount, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.symbol});
  factory _UnitListDto.fromJson(Map<String, dynamic> json) => _$UnitListDtoFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'short_name') final  String shortName;
@override@JsonKey(name: 'decimal_places') final  int decimalPlaces;
@override@JsonKey(name: 'is_system') final  bool isSystem;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'conversion_count') final  int conversionCount;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override final  String? symbol;

/// Create a copy of UnitListDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnitListDtoCopyWith<_UnitListDto> get copyWith => __$UnitListDtoCopyWithImpl<_UnitListDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnitListDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnitListDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.decimalPlaces, decimalPlaces) || other.decimalPlaces == decimalPlaces)&&(identical(other.isSystem, isSystem) || other.isSystem == isSystem)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.conversionCount, conversionCount) || other.conversionCount == conversionCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.symbol, symbol) || other.symbol == symbol));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,shortName,decimalPlaces,isSystem,isActive,conversionCount,createdAt,updatedAt,symbol);

@override
String toString() {
  return 'UnitListDto(id: $id, name: $name, shortName: $shortName, decimalPlaces: $decimalPlaces, isSystem: $isSystem, isActive: $isActive, conversionCount: $conversionCount, createdAt: $createdAt, updatedAt: $updatedAt, symbol: $symbol)';
}


}

/// @nodoc
abstract mixin class _$UnitListDtoCopyWith<$Res> implements $UnitListDtoCopyWith<$Res> {
  factory _$UnitListDtoCopyWith(_UnitListDto value, $Res Function(_UnitListDto) _then) = __$UnitListDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'short_name') String shortName,@JsonKey(name: 'decimal_places') int decimalPlaces,@JsonKey(name: 'is_system') bool isSystem,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'conversion_count') int conversionCount,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, String? symbol
});




}
/// @nodoc
class __$UnitListDtoCopyWithImpl<$Res>
    implements _$UnitListDtoCopyWith<$Res> {
  __$UnitListDtoCopyWithImpl(this._self, this._then);

  final _UnitListDto _self;
  final $Res Function(_UnitListDto) _then;

/// Create a copy of UnitListDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? shortName = null,Object? decimalPlaces = null,Object? isSystem = null,Object? isActive = null,Object? conversionCount = null,Object? createdAt = null,Object? updatedAt = null,Object? symbol = freezed,}) {
  return _then(_UnitListDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,decimalPlaces: null == decimalPlaces ? _self.decimalPlaces : decimalPlaces // ignore: cast_nullable_to_non_nullable
as int,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,conversionCount: null == conversionCount ? _self.conversionCount : conversionCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UnitDetailDto {

 String get id; String get name;@JsonKey(name: 'short_name') String get shortName;@JsonKey(name: 'decimal_places') int get decimalPlaces;@JsonKey(name: 'is_system') bool get isSystem;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt; String? get symbol; List<UnitConversionDto> get conversions;
/// Create a copy of UnitDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitDetailDtoCopyWith<UnitDetailDto> get copyWith => _$UnitDetailDtoCopyWithImpl<UnitDetailDto>(this as UnitDetailDto, _$identity);

  /// Serializes this UnitDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnitDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.decimalPlaces, decimalPlaces) || other.decimalPlaces == decimalPlaces)&&(identical(other.isSystem, isSystem) || other.isSystem == isSystem)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&const DeepCollectionEquality().equals(other.conversions, conversions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,shortName,decimalPlaces,isSystem,isActive,createdAt,updatedAt,symbol,const DeepCollectionEquality().hash(conversions));

@override
String toString() {
  return 'UnitDetailDto(id: $id, name: $name, shortName: $shortName, decimalPlaces: $decimalPlaces, isSystem: $isSystem, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, symbol: $symbol, conversions: $conversions)';
}


}

/// @nodoc
abstract mixin class $UnitDetailDtoCopyWith<$Res>  {
  factory $UnitDetailDtoCopyWith(UnitDetailDto value, $Res Function(UnitDetailDto) _then) = _$UnitDetailDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'short_name') String shortName,@JsonKey(name: 'decimal_places') int decimalPlaces,@JsonKey(name: 'is_system') bool isSystem,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, String? symbol, List<UnitConversionDto> conversions
});




}
/// @nodoc
class _$UnitDetailDtoCopyWithImpl<$Res>
    implements $UnitDetailDtoCopyWith<$Res> {
  _$UnitDetailDtoCopyWithImpl(this._self, this._then);

  final UnitDetailDto _self;
  final $Res Function(UnitDetailDto) _then;

/// Create a copy of UnitDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? shortName = null,Object? decimalPlaces = null,Object? isSystem = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? symbol = freezed,Object? conversions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,decimalPlaces: null == decimalPlaces ? _self.decimalPlaces : decimalPlaces // ignore: cast_nullable_to_non_nullable
as int,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,conversions: null == conversions ? _self.conversions : conversions // ignore: cast_nullable_to_non_nullable
as List<UnitConversionDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [UnitDetailDto].
extension UnitDetailDtoPatterns on UnitDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnitDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnitDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnitDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _UnitDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnitDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _UnitDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'short_name')  String shortName, @JsonKey(name: 'decimal_places')  int decimalPlaces, @JsonKey(name: 'is_system')  bool isSystem, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? symbol,  List<UnitConversionDto> conversions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnitDetailDto() when $default != null:
return $default(_that.id,_that.name,_that.shortName,_that.decimalPlaces,_that.isSystem,_that.isActive,_that.createdAt,_that.updatedAt,_that.symbol,_that.conversions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'short_name')  String shortName, @JsonKey(name: 'decimal_places')  int decimalPlaces, @JsonKey(name: 'is_system')  bool isSystem, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? symbol,  List<UnitConversionDto> conversions)  $default,) {final _that = this;
switch (_that) {
case _UnitDetailDto():
return $default(_that.id,_that.name,_that.shortName,_that.decimalPlaces,_that.isSystem,_that.isActive,_that.createdAt,_that.updatedAt,_that.symbol,_that.conversions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'short_name')  String shortName, @JsonKey(name: 'decimal_places')  int decimalPlaces, @JsonKey(name: 'is_system')  bool isSystem, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? symbol,  List<UnitConversionDto> conversions)?  $default,) {final _that = this;
switch (_that) {
case _UnitDetailDto() when $default != null:
return $default(_that.id,_that.name,_that.shortName,_that.decimalPlaces,_that.isSystem,_that.isActive,_that.createdAt,_that.updatedAt,_that.symbol,_that.conversions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnitDetailDto implements UnitDetailDto {
  const _UnitDetailDto({required this.id, required this.name, @JsonKey(name: 'short_name') required this.shortName, @JsonKey(name: 'decimal_places') required this.decimalPlaces, @JsonKey(name: 'is_system') required this.isSystem, @JsonKey(name: 'is_active') required this.isActive, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.symbol, final  List<UnitConversionDto> conversions = const []}): _conversions = conversions;
  factory _UnitDetailDto.fromJson(Map<String, dynamic> json) => _$UnitDetailDtoFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'short_name') final  String shortName;
@override@JsonKey(name: 'decimal_places') final  int decimalPlaces;
@override@JsonKey(name: 'is_system') final  bool isSystem;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override final  String? symbol;
 final  List<UnitConversionDto> _conversions;
@override@JsonKey() List<UnitConversionDto> get conversions {
  if (_conversions is EqualUnmodifiableListView) return _conversions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conversions);
}


/// Create a copy of UnitDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnitDetailDtoCopyWith<_UnitDetailDto> get copyWith => __$UnitDetailDtoCopyWithImpl<_UnitDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnitDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnitDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.decimalPlaces, decimalPlaces) || other.decimalPlaces == decimalPlaces)&&(identical(other.isSystem, isSystem) || other.isSystem == isSystem)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&const DeepCollectionEquality().equals(other._conversions, _conversions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,shortName,decimalPlaces,isSystem,isActive,createdAt,updatedAt,symbol,const DeepCollectionEquality().hash(_conversions));

@override
String toString() {
  return 'UnitDetailDto(id: $id, name: $name, shortName: $shortName, decimalPlaces: $decimalPlaces, isSystem: $isSystem, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, symbol: $symbol, conversions: $conversions)';
}


}

/// @nodoc
abstract mixin class _$UnitDetailDtoCopyWith<$Res> implements $UnitDetailDtoCopyWith<$Res> {
  factory _$UnitDetailDtoCopyWith(_UnitDetailDto value, $Res Function(_UnitDetailDto) _then) = __$UnitDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'short_name') String shortName,@JsonKey(name: 'decimal_places') int decimalPlaces,@JsonKey(name: 'is_system') bool isSystem,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, String? symbol, List<UnitConversionDto> conversions
});




}
/// @nodoc
class __$UnitDetailDtoCopyWithImpl<$Res>
    implements _$UnitDetailDtoCopyWith<$Res> {
  __$UnitDetailDtoCopyWithImpl(this._self, this._then);

  final _UnitDetailDto _self;
  final $Res Function(_UnitDetailDto) _then;

/// Create a copy of UnitDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? shortName = null,Object? decimalPlaces = null,Object? isSystem = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? symbol = freezed,Object? conversions = null,}) {
  return _then(_UnitDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,decimalPlaces: null == decimalPlaces ? _self.decimalPlaces : decimalPlaces // ignore: cast_nullable_to_non_nullable
as int,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,conversions: null == conversions ? _self._conversions : conversions // ignore: cast_nullable_to_non_nullable
as List<UnitConversionDto>,
  ));
}


}

// dart format on
