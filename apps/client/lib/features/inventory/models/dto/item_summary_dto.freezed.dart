// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_summary_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategorySummaryDto {

 String get id; String get name;
/// Create a copy of CategorySummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorySummaryDtoCopyWith<CategorySummaryDto> get copyWith => _$CategorySummaryDtoCopyWithImpl<CategorySummaryDto>(this as CategorySummaryDto, _$identity);

  /// Serializes this CategorySummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorySummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CategorySummaryDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $CategorySummaryDtoCopyWith<$Res>  {
  factory $CategorySummaryDtoCopyWith(CategorySummaryDto value, $Res Function(CategorySummaryDto) _then) = _$CategorySummaryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$CategorySummaryDtoCopyWithImpl<$Res>
    implements $CategorySummaryDtoCopyWith<$Res> {
  _$CategorySummaryDtoCopyWithImpl(this._self, this._then);

  final CategorySummaryDto _self;
  final $Res Function(CategorySummaryDto) _then;

/// Create a copy of CategorySummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CategorySummaryDto].
extension CategorySummaryDtoPatterns on CategorySummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategorySummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategorySummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategorySummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _CategorySummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategorySummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _CategorySummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategorySummaryDto() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _CategorySummaryDto():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _CategorySummaryDto() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategorySummaryDto implements CategorySummaryDto {
  const _CategorySummaryDto({required this.id, required this.name});
  factory _CategorySummaryDto.fromJson(Map<String, dynamic> json) => _$CategorySummaryDtoFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of CategorySummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorySummaryDtoCopyWith<_CategorySummaryDto> get copyWith => __$CategorySummaryDtoCopyWithImpl<_CategorySummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategorySummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorySummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CategorySummaryDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CategorySummaryDtoCopyWith<$Res> implements $CategorySummaryDtoCopyWith<$Res> {
  factory _$CategorySummaryDtoCopyWith(_CategorySummaryDto value, $Res Function(_CategorySummaryDto) _then) = __$CategorySummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$CategorySummaryDtoCopyWithImpl<$Res>
    implements _$CategorySummaryDtoCopyWith<$Res> {
  __$CategorySummaryDtoCopyWithImpl(this._self, this._then);

  final _CategorySummaryDto _self;
  final $Res Function(_CategorySummaryDto) _then;

/// Create a copy of CategorySummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_CategorySummaryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BrandSummaryDto {

 String get id; String get name;
/// Create a copy of BrandSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrandSummaryDtoCopyWith<BrandSummaryDto> get copyWith => _$BrandSummaryDtoCopyWithImpl<BrandSummaryDto>(this as BrandSummaryDto, _$identity);

  /// Serializes this BrandSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrandSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'BrandSummaryDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $BrandSummaryDtoCopyWith<$Res>  {
  factory $BrandSummaryDtoCopyWith(BrandSummaryDto value, $Res Function(BrandSummaryDto) _then) = _$BrandSummaryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$BrandSummaryDtoCopyWithImpl<$Res>
    implements $BrandSummaryDtoCopyWith<$Res> {
  _$BrandSummaryDtoCopyWithImpl(this._self, this._then);

  final BrandSummaryDto _self;
  final $Res Function(BrandSummaryDto) _then;

/// Create a copy of BrandSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BrandSummaryDto].
extension BrandSummaryDtoPatterns on BrandSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BrandSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BrandSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BrandSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _BrandSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BrandSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _BrandSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BrandSummaryDto() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _BrandSummaryDto():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _BrandSummaryDto() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BrandSummaryDto implements BrandSummaryDto {
  const _BrandSummaryDto({required this.id, required this.name});
  factory _BrandSummaryDto.fromJson(Map<String, dynamic> json) => _$BrandSummaryDtoFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of BrandSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrandSummaryDtoCopyWith<_BrandSummaryDto> get copyWith => __$BrandSummaryDtoCopyWithImpl<_BrandSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrandSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BrandSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'BrandSummaryDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$BrandSummaryDtoCopyWith<$Res> implements $BrandSummaryDtoCopyWith<$Res> {
  factory _$BrandSummaryDtoCopyWith(_BrandSummaryDto value, $Res Function(_BrandSummaryDto) _then) = __$BrandSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$BrandSummaryDtoCopyWithImpl<$Res>
    implements _$BrandSummaryDtoCopyWith<$Res> {
  __$BrandSummaryDtoCopyWithImpl(this._self, this._then);

  final _BrandSummaryDto _self;
  final $Res Function(_BrandSummaryDto) _then;

/// Create a copy of BrandSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_BrandSummaryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BaseUnitSummaryDto {

 String get id; String get name;@JsonKey(name: 'short_name') String get shortName; String? get symbol;
/// Create a copy of BaseUnitSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaseUnitSummaryDtoCopyWith<BaseUnitSummaryDto> get copyWith => _$BaseUnitSummaryDtoCopyWithImpl<BaseUnitSummaryDto>(this as BaseUnitSummaryDto, _$identity);

  /// Serializes this BaseUnitSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaseUnitSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.symbol, symbol) || other.symbol == symbol));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,shortName,symbol);

@override
String toString() {
  return 'BaseUnitSummaryDto(id: $id, name: $name, shortName: $shortName, symbol: $symbol)';
}


}

/// @nodoc
abstract mixin class $BaseUnitSummaryDtoCopyWith<$Res>  {
  factory $BaseUnitSummaryDtoCopyWith(BaseUnitSummaryDto value, $Res Function(BaseUnitSummaryDto) _then) = _$BaseUnitSummaryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'short_name') String shortName, String? symbol
});




}
/// @nodoc
class _$BaseUnitSummaryDtoCopyWithImpl<$Res>
    implements $BaseUnitSummaryDtoCopyWith<$Res> {
  _$BaseUnitSummaryDtoCopyWithImpl(this._self, this._then);

  final BaseUnitSummaryDto _self;
  final $Res Function(BaseUnitSummaryDto) _then;

/// Create a copy of BaseUnitSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? shortName = null,Object? symbol = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BaseUnitSummaryDto].
extension BaseUnitSummaryDtoPatterns on BaseUnitSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BaseUnitSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BaseUnitSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BaseUnitSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _BaseUnitSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BaseUnitSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _BaseUnitSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'short_name')  String shortName,  String? symbol)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BaseUnitSummaryDto() when $default != null:
return $default(_that.id,_that.name,_that.shortName,_that.symbol);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'short_name')  String shortName,  String? symbol)  $default,) {final _that = this;
switch (_that) {
case _BaseUnitSummaryDto():
return $default(_that.id,_that.name,_that.shortName,_that.symbol);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'short_name')  String shortName,  String? symbol)?  $default,) {final _that = this;
switch (_that) {
case _BaseUnitSummaryDto() when $default != null:
return $default(_that.id,_that.name,_that.shortName,_that.symbol);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BaseUnitSummaryDto implements BaseUnitSummaryDto {
  const _BaseUnitSummaryDto({required this.id, required this.name, @JsonKey(name: 'short_name') required this.shortName, this.symbol});
  factory _BaseUnitSummaryDto.fromJson(Map<String, dynamic> json) => _$BaseUnitSummaryDtoFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'short_name') final  String shortName;
@override final  String? symbol;

/// Create a copy of BaseUnitSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaseUnitSummaryDtoCopyWith<_BaseUnitSummaryDto> get copyWith => __$BaseUnitSummaryDtoCopyWithImpl<_BaseUnitSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BaseUnitSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BaseUnitSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.symbol, symbol) || other.symbol == symbol));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,shortName,symbol);

@override
String toString() {
  return 'BaseUnitSummaryDto(id: $id, name: $name, shortName: $shortName, symbol: $symbol)';
}


}

/// @nodoc
abstract mixin class _$BaseUnitSummaryDtoCopyWith<$Res> implements $BaseUnitSummaryDtoCopyWith<$Res> {
  factory _$BaseUnitSummaryDtoCopyWith(_BaseUnitSummaryDto value, $Res Function(_BaseUnitSummaryDto) _then) = __$BaseUnitSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'short_name') String shortName, String? symbol
});




}
/// @nodoc
class __$BaseUnitSummaryDtoCopyWithImpl<$Res>
    implements _$BaseUnitSummaryDtoCopyWith<$Res> {
  __$BaseUnitSummaryDtoCopyWithImpl(this._self, this._then);

  final _BaseUnitSummaryDto _self;
  final $Res Function(_BaseUnitSummaryDto) _then;

/// Create a copy of BaseUnitSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? shortName = null,Object? symbol = freezed,}) {
  return _then(_BaseUnitSummaryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TierPriceDto {

@JsonKey(name: 'pricing_tier') String get pricingTier; String get price;
/// Create a copy of TierPriceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TierPriceDtoCopyWith<TierPriceDto> get copyWith => _$TierPriceDtoCopyWithImpl<TierPriceDto>(this as TierPriceDto, _$identity);

  /// Serializes this TierPriceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TierPriceDto&&(identical(other.pricingTier, pricingTier) || other.pricingTier == pricingTier)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pricingTier,price);

@override
String toString() {
  return 'TierPriceDto(pricingTier: $pricingTier, price: $price)';
}


}

/// @nodoc
abstract mixin class $TierPriceDtoCopyWith<$Res>  {
  factory $TierPriceDtoCopyWith(TierPriceDto value, $Res Function(TierPriceDto) _then) = _$TierPriceDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'pricing_tier') String pricingTier, String price
});




}
/// @nodoc
class _$TierPriceDtoCopyWithImpl<$Res>
    implements $TierPriceDtoCopyWith<$Res> {
  _$TierPriceDtoCopyWithImpl(this._self, this._then);

  final TierPriceDto _self;
  final $Res Function(TierPriceDto) _then;

/// Create a copy of TierPriceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pricingTier = null,Object? price = null,}) {
  return _then(_self.copyWith(
pricingTier: null == pricingTier ? _self.pricingTier : pricingTier // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TierPriceDto].
extension TierPriceDtoPatterns on TierPriceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TierPriceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TierPriceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TierPriceDto value)  $default,){
final _that = this;
switch (_that) {
case _TierPriceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TierPriceDto value)?  $default,){
final _that = this;
switch (_that) {
case _TierPriceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'pricing_tier')  String pricingTier,  String price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TierPriceDto() when $default != null:
return $default(_that.pricingTier,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'pricing_tier')  String pricingTier,  String price)  $default,) {final _that = this;
switch (_that) {
case _TierPriceDto():
return $default(_that.pricingTier,_that.price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'pricing_tier')  String pricingTier,  String price)?  $default,) {final _that = this;
switch (_that) {
case _TierPriceDto() when $default != null:
return $default(_that.pricingTier,_that.price);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TierPriceDto implements TierPriceDto {
  const _TierPriceDto({@JsonKey(name: 'pricing_tier') required this.pricingTier, required this.price});
  factory _TierPriceDto.fromJson(Map<String, dynamic> json) => _$TierPriceDtoFromJson(json);

@override@JsonKey(name: 'pricing_tier') final  String pricingTier;
@override final  String price;

/// Create a copy of TierPriceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TierPriceDtoCopyWith<_TierPriceDto> get copyWith => __$TierPriceDtoCopyWithImpl<_TierPriceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TierPriceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TierPriceDto&&(identical(other.pricingTier, pricingTier) || other.pricingTier == pricingTier)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pricingTier,price);

@override
String toString() {
  return 'TierPriceDto(pricingTier: $pricingTier, price: $price)';
}


}

/// @nodoc
abstract mixin class _$TierPriceDtoCopyWith<$Res> implements $TierPriceDtoCopyWith<$Res> {
  factory _$TierPriceDtoCopyWith(_TierPriceDto value, $Res Function(_TierPriceDto) _then) = __$TierPriceDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'pricing_tier') String pricingTier, String price
});




}
/// @nodoc
class __$TierPriceDtoCopyWithImpl<$Res>
    implements _$TierPriceDtoCopyWith<$Res> {
  __$TierPriceDtoCopyWithImpl(this._self, this._then);

  final _TierPriceDto _self;
  final $Res Function(_TierPriceDto) _then;

/// Create a copy of TierPriceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pricingTier = null,Object? price = null,}) {
  return _then(_TierPriceDto(
pricingTier: null == pricingTier ? _self.pricingTier : pricingTier // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ItemImageDto {

 String get id;@JsonKey(name: 'image_url') String get imageUrl;@JsonKey(name: 'thumbnail_url') String? get thumbnailUrl;@JsonKey(name: 'medium_url') String? get mediumUrl;@JsonKey(name: 'media_asset_id') String? get mediaAssetId;@JsonKey(name: 'sort_order') int get sortOrder;@JsonKey(name: 'is_primary') bool get isPrimary;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;
/// Create a copy of ItemImageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemImageDtoCopyWith<ItemImageDto> get copyWith => _$ItemImageDtoCopyWithImpl<ItemImageDto>(this as ItemImageDto, _$identity);

  /// Serializes this ItemImageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemImageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.mediumUrl, mediumUrl) || other.mediumUrl == mediumUrl)&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imageUrl,thumbnailUrl,mediumUrl,mediaAssetId,sortOrder,isPrimary,createdAt,updatedAt);

@override
String toString() {
  return 'ItemImageDto(id: $id, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, mediumUrl: $mediumUrl, mediaAssetId: $mediaAssetId, sortOrder: $sortOrder, isPrimary: $isPrimary, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ItemImageDtoCopyWith<$Res>  {
  factory $ItemImageDtoCopyWith(ItemImageDto value, $Res Function(ItemImageDto) _then) = _$ItemImageDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'medium_url') String? mediumUrl,@JsonKey(name: 'media_asset_id') String? mediaAssetId,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class _$ItemImageDtoCopyWithImpl<$Res>
    implements $ItemImageDtoCopyWith<$Res> {
  _$ItemImageDtoCopyWithImpl(this._self, this._then);

  final ItemImageDto _self;
  final $Res Function(ItemImageDto) _then;

/// Create a copy of ItemImageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? imageUrl = null,Object? thumbnailUrl = freezed,Object? mediumUrl = freezed,Object? mediaAssetId = freezed,Object? sortOrder = null,Object? isPrimary = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,mediumUrl: freezed == mediumUrl ? _self.mediumUrl : mediumUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaAssetId: freezed == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemImageDto].
extension ItemImageDtoPatterns on ItemImageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemImageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemImageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemImageDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemImageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemImageDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemImageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'medium_url')  String? mediumUrl, @JsonKey(name: 'media_asset_id')  String? mediaAssetId, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemImageDto() when $default != null:
return $default(_that.id,_that.imageUrl,_that.thumbnailUrl,_that.mediumUrl,_that.mediaAssetId,_that.sortOrder,_that.isPrimary,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'medium_url')  String? mediumUrl, @JsonKey(name: 'media_asset_id')  String? mediaAssetId, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ItemImageDto():
return $default(_that.id,_that.imageUrl,_that.thumbnailUrl,_that.mediumUrl,_that.mediaAssetId,_that.sortOrder,_that.isPrimary,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'medium_url')  String? mediumUrl, @JsonKey(name: 'media_asset_id')  String? mediaAssetId, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ItemImageDto() when $default != null:
return $default(_that.id,_that.imageUrl,_that.thumbnailUrl,_that.mediumUrl,_that.mediaAssetId,_that.sortOrder,_that.isPrimary,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemImageDto implements ItemImageDto {
  const _ItemImageDto({required this.id, @JsonKey(name: 'image_url') required this.imageUrl, @JsonKey(name: 'thumbnail_url') this.thumbnailUrl, @JsonKey(name: 'medium_url') this.mediumUrl, @JsonKey(name: 'media_asset_id') this.mediaAssetId, @JsonKey(name: 'sort_order') required this.sortOrder, @JsonKey(name: 'is_primary') required this.isPrimary, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _ItemImageDto.fromJson(Map<String, dynamic> json) => _$ItemImageDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'image_url') final  String imageUrl;
@override@JsonKey(name: 'thumbnail_url') final  String? thumbnailUrl;
@override@JsonKey(name: 'medium_url') final  String? mediumUrl;
@override@JsonKey(name: 'media_asset_id') final  String? mediaAssetId;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey(name: 'is_primary') final  bool isPrimary;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;

/// Create a copy of ItemImageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemImageDtoCopyWith<_ItemImageDto> get copyWith => __$ItemImageDtoCopyWithImpl<_ItemImageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemImageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemImageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.mediumUrl, mediumUrl) || other.mediumUrl == mediumUrl)&&(identical(other.mediaAssetId, mediaAssetId) || other.mediaAssetId == mediaAssetId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imageUrl,thumbnailUrl,mediumUrl,mediaAssetId,sortOrder,isPrimary,createdAt,updatedAt);

@override
String toString() {
  return 'ItemImageDto(id: $id, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, mediumUrl: $mediumUrl, mediaAssetId: $mediaAssetId, sortOrder: $sortOrder, isPrimary: $isPrimary, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ItemImageDtoCopyWith<$Res> implements $ItemImageDtoCopyWith<$Res> {
  factory _$ItemImageDtoCopyWith(_ItemImageDto value, $Res Function(_ItemImageDto) _then) = __$ItemImageDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'medium_url') String? mediumUrl,@JsonKey(name: 'media_asset_id') String? mediaAssetId,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class __$ItemImageDtoCopyWithImpl<$Res>
    implements _$ItemImageDtoCopyWith<$Res> {
  __$ItemImageDtoCopyWithImpl(this._self, this._then);

  final _ItemImageDto _self;
  final $Res Function(_ItemImageDto) _then;

/// Create a copy of ItemImageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imageUrl = null,Object? thumbnailUrl = freezed,Object? mediumUrl = freezed,Object? mediaAssetId = freezed,Object? sortOrder = null,Object? isPrimary = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ItemImageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,mediumUrl: freezed == mediumUrl ? _self.mediumUrl : mediumUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaAssetId: freezed == mediaAssetId ? _self.mediaAssetId : mediaAssetId // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ItemLocationSummaryDto {

 String get id;@JsonKey(name: 'godown_id') String get godownId; String? get rack; String? get shelf;
/// Create a copy of ItemLocationSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemLocationSummaryDtoCopyWith<ItemLocationSummaryDto> get copyWith => _$ItemLocationSummaryDtoCopyWithImpl<ItemLocationSummaryDto>(this as ItemLocationSummaryDto, _$identity);

  /// Serializes this ItemLocationSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemLocationSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.godownId, godownId) || other.godownId == godownId)&&(identical(other.rack, rack) || other.rack == rack)&&(identical(other.shelf, shelf) || other.shelf == shelf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,godownId,rack,shelf);

@override
String toString() {
  return 'ItemLocationSummaryDto(id: $id, godownId: $godownId, rack: $rack, shelf: $shelf)';
}


}

/// @nodoc
abstract mixin class $ItemLocationSummaryDtoCopyWith<$Res>  {
  factory $ItemLocationSummaryDtoCopyWith(ItemLocationSummaryDto value, $Res Function(ItemLocationSummaryDto) _then) = _$ItemLocationSummaryDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'godown_id') String godownId, String? rack, String? shelf
});




}
/// @nodoc
class _$ItemLocationSummaryDtoCopyWithImpl<$Res>
    implements $ItemLocationSummaryDtoCopyWith<$Res> {
  _$ItemLocationSummaryDtoCopyWithImpl(this._self, this._then);

  final ItemLocationSummaryDto _self;
  final $Res Function(ItemLocationSummaryDto) _then;

/// Create a copy of ItemLocationSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? godownId = null,Object? rack = freezed,Object? shelf = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,godownId: null == godownId ? _self.godownId : godownId // ignore: cast_nullable_to_non_nullable
as String,rack: freezed == rack ? _self.rack : rack // ignore: cast_nullable_to_non_nullable
as String?,shelf: freezed == shelf ? _self.shelf : shelf // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemLocationSummaryDto].
extension ItemLocationSummaryDtoPatterns on ItemLocationSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemLocationSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemLocationSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemLocationSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemLocationSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemLocationSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemLocationSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'godown_id')  String godownId,  String? rack,  String? shelf)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemLocationSummaryDto() when $default != null:
return $default(_that.id,_that.godownId,_that.rack,_that.shelf);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'godown_id')  String godownId,  String? rack,  String? shelf)  $default,) {final _that = this;
switch (_that) {
case _ItemLocationSummaryDto():
return $default(_that.id,_that.godownId,_that.rack,_that.shelf);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'godown_id')  String godownId,  String? rack,  String? shelf)?  $default,) {final _that = this;
switch (_that) {
case _ItemLocationSummaryDto() when $default != null:
return $default(_that.id,_that.godownId,_that.rack,_that.shelf);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemLocationSummaryDto implements ItemLocationSummaryDto {
  const _ItemLocationSummaryDto({required this.id, @JsonKey(name: 'godown_id') required this.godownId, this.rack, this.shelf});
  factory _ItemLocationSummaryDto.fromJson(Map<String, dynamic> json) => _$ItemLocationSummaryDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'godown_id') final  String godownId;
@override final  String? rack;
@override final  String? shelf;

/// Create a copy of ItemLocationSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemLocationSummaryDtoCopyWith<_ItemLocationSummaryDto> get copyWith => __$ItemLocationSummaryDtoCopyWithImpl<_ItemLocationSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemLocationSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemLocationSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.godownId, godownId) || other.godownId == godownId)&&(identical(other.rack, rack) || other.rack == rack)&&(identical(other.shelf, shelf) || other.shelf == shelf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,godownId,rack,shelf);

@override
String toString() {
  return 'ItemLocationSummaryDto(id: $id, godownId: $godownId, rack: $rack, shelf: $shelf)';
}


}

/// @nodoc
abstract mixin class _$ItemLocationSummaryDtoCopyWith<$Res> implements $ItemLocationSummaryDtoCopyWith<$Res> {
  factory _$ItemLocationSummaryDtoCopyWith(_ItemLocationSummaryDto value, $Res Function(_ItemLocationSummaryDto) _then) = __$ItemLocationSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'godown_id') String godownId, String? rack, String? shelf
});




}
/// @nodoc
class __$ItemLocationSummaryDtoCopyWithImpl<$Res>
    implements _$ItemLocationSummaryDtoCopyWith<$Res> {
  __$ItemLocationSummaryDtoCopyWithImpl(this._self, this._then);

  final _ItemLocationSummaryDto _self;
  final $Res Function(_ItemLocationSummaryDto) _then;

/// Create a copy of ItemLocationSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? godownId = null,Object? rack = freezed,Object? shelf = freezed,}) {
  return _then(_ItemLocationSummaryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,godownId: null == godownId ? _self.godownId : godownId // ignore: cast_nullable_to_non_nullable
as String,rack: freezed == rack ? _self.rack : rack // ignore: cast_nullable_to_non_nullable
as String?,shelf: freezed == shelf ? _self.shelf : shelf // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OpeningStockGodownDto {

@JsonKey(name: 'godown_id') String get godownId;@JsonKey(name: 'godown_name') String get godownName; String get quantity;
/// Create a copy of OpeningStockGodownDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpeningStockGodownDtoCopyWith<OpeningStockGodownDto> get copyWith => _$OpeningStockGodownDtoCopyWithImpl<OpeningStockGodownDto>(this as OpeningStockGodownDto, _$identity);

  /// Serializes this OpeningStockGodownDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpeningStockGodownDto&&(identical(other.godownId, godownId) || other.godownId == godownId)&&(identical(other.godownName, godownName) || other.godownName == godownName)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,godownId,godownName,quantity);

@override
String toString() {
  return 'OpeningStockGodownDto(godownId: $godownId, godownName: $godownName, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $OpeningStockGodownDtoCopyWith<$Res>  {
  factory $OpeningStockGodownDtoCopyWith(OpeningStockGodownDto value, $Res Function(OpeningStockGodownDto) _then) = _$OpeningStockGodownDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'godown_id') String godownId,@JsonKey(name: 'godown_name') String godownName, String quantity
});




}
/// @nodoc
class _$OpeningStockGodownDtoCopyWithImpl<$Res>
    implements $OpeningStockGodownDtoCopyWith<$Res> {
  _$OpeningStockGodownDtoCopyWithImpl(this._self, this._then);

  final OpeningStockGodownDto _self;
  final $Res Function(OpeningStockGodownDto) _then;

/// Create a copy of OpeningStockGodownDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? godownId = null,Object? godownName = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
godownId: null == godownId ? _self.godownId : godownId // ignore: cast_nullable_to_non_nullable
as String,godownName: null == godownName ? _self.godownName : godownName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OpeningStockGodownDto].
extension OpeningStockGodownDtoPatterns on OpeningStockGodownDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpeningStockGodownDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpeningStockGodownDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpeningStockGodownDto value)  $default,){
final _that = this;
switch (_that) {
case _OpeningStockGodownDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpeningStockGodownDto value)?  $default,){
final _that = this;
switch (_that) {
case _OpeningStockGodownDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'godown_id')  String godownId, @JsonKey(name: 'godown_name')  String godownName,  String quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpeningStockGodownDto() when $default != null:
return $default(_that.godownId,_that.godownName,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'godown_id')  String godownId, @JsonKey(name: 'godown_name')  String godownName,  String quantity)  $default,) {final _that = this;
switch (_that) {
case _OpeningStockGodownDto():
return $default(_that.godownId,_that.godownName,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'godown_id')  String godownId, @JsonKey(name: 'godown_name')  String godownName,  String quantity)?  $default,) {final _that = this;
switch (_that) {
case _OpeningStockGodownDto() when $default != null:
return $default(_that.godownId,_that.godownName,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpeningStockGodownDto implements OpeningStockGodownDto {
  const _OpeningStockGodownDto({@JsonKey(name: 'godown_id') required this.godownId, @JsonKey(name: 'godown_name') required this.godownName, required this.quantity});
  factory _OpeningStockGodownDto.fromJson(Map<String, dynamic> json) => _$OpeningStockGodownDtoFromJson(json);

@override@JsonKey(name: 'godown_id') final  String godownId;
@override@JsonKey(name: 'godown_name') final  String godownName;
@override final  String quantity;

/// Create a copy of OpeningStockGodownDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpeningStockGodownDtoCopyWith<_OpeningStockGodownDto> get copyWith => __$OpeningStockGodownDtoCopyWithImpl<_OpeningStockGodownDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpeningStockGodownDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpeningStockGodownDto&&(identical(other.godownId, godownId) || other.godownId == godownId)&&(identical(other.godownName, godownName) || other.godownName == godownName)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,godownId,godownName,quantity);

@override
String toString() {
  return 'OpeningStockGodownDto(godownId: $godownId, godownName: $godownName, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$OpeningStockGodownDtoCopyWith<$Res> implements $OpeningStockGodownDtoCopyWith<$Res> {
  factory _$OpeningStockGodownDtoCopyWith(_OpeningStockGodownDto value, $Res Function(_OpeningStockGodownDto) _then) = __$OpeningStockGodownDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'godown_id') String godownId,@JsonKey(name: 'godown_name') String godownName, String quantity
});




}
/// @nodoc
class __$OpeningStockGodownDtoCopyWithImpl<$Res>
    implements _$OpeningStockGodownDtoCopyWith<$Res> {
  __$OpeningStockGodownDtoCopyWithImpl(this._self, this._then);

  final _OpeningStockGodownDto _self;
  final $Res Function(_OpeningStockGodownDto) _then;

/// Create a copy of OpeningStockGodownDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? godownId = null,Object? godownName = null,Object? quantity = null,}) {
  return _then(_OpeningStockGodownDto(
godownId: null == godownId ? _self.godownId : godownId // ignore: cast_nullable_to_non_nullable
as String,godownName: null == godownName ? _self.godownName : godownName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OpeningStockDto {

@JsonKey(name: 'total_quantity') String get totalQuantity; List<OpeningStockGodownDto> get godowns;
/// Create a copy of OpeningStockDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpeningStockDtoCopyWith<OpeningStockDto> get copyWith => _$OpeningStockDtoCopyWithImpl<OpeningStockDto>(this as OpeningStockDto, _$identity);

  /// Serializes this OpeningStockDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpeningStockDto&&(identical(other.totalQuantity, totalQuantity) || other.totalQuantity == totalQuantity)&&const DeepCollectionEquality().equals(other.godowns, godowns));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalQuantity,const DeepCollectionEquality().hash(godowns));

@override
String toString() {
  return 'OpeningStockDto(totalQuantity: $totalQuantity, godowns: $godowns)';
}


}

/// @nodoc
abstract mixin class $OpeningStockDtoCopyWith<$Res>  {
  factory $OpeningStockDtoCopyWith(OpeningStockDto value, $Res Function(OpeningStockDto) _then) = _$OpeningStockDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_quantity') String totalQuantity, List<OpeningStockGodownDto> godowns
});




}
/// @nodoc
class _$OpeningStockDtoCopyWithImpl<$Res>
    implements $OpeningStockDtoCopyWith<$Res> {
  _$OpeningStockDtoCopyWithImpl(this._self, this._then);

  final OpeningStockDto _self;
  final $Res Function(OpeningStockDto) _then;

/// Create a copy of OpeningStockDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalQuantity = null,Object? godowns = null,}) {
  return _then(_self.copyWith(
totalQuantity: null == totalQuantity ? _self.totalQuantity : totalQuantity // ignore: cast_nullable_to_non_nullable
as String,godowns: null == godowns ? _self.godowns : godowns // ignore: cast_nullable_to_non_nullable
as List<OpeningStockGodownDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [OpeningStockDto].
extension OpeningStockDtoPatterns on OpeningStockDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpeningStockDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpeningStockDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpeningStockDto value)  $default,){
final _that = this;
switch (_that) {
case _OpeningStockDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpeningStockDto value)?  $default,){
final _that = this;
switch (_that) {
case _OpeningStockDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_quantity')  String totalQuantity,  List<OpeningStockGodownDto> godowns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpeningStockDto() when $default != null:
return $default(_that.totalQuantity,_that.godowns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_quantity')  String totalQuantity,  List<OpeningStockGodownDto> godowns)  $default,) {final _that = this;
switch (_that) {
case _OpeningStockDto():
return $default(_that.totalQuantity,_that.godowns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_quantity')  String totalQuantity,  List<OpeningStockGodownDto> godowns)?  $default,) {final _that = this;
switch (_that) {
case _OpeningStockDto() when $default != null:
return $default(_that.totalQuantity,_that.godowns);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpeningStockDto implements OpeningStockDto {
  const _OpeningStockDto({@JsonKey(name: 'total_quantity') required this.totalQuantity, final  List<OpeningStockGodownDto> godowns = const []}): _godowns = godowns;
  factory _OpeningStockDto.fromJson(Map<String, dynamic> json) => _$OpeningStockDtoFromJson(json);

@override@JsonKey(name: 'total_quantity') final  String totalQuantity;
 final  List<OpeningStockGodownDto> _godowns;
@override@JsonKey() List<OpeningStockGodownDto> get godowns {
  if (_godowns is EqualUnmodifiableListView) return _godowns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_godowns);
}


/// Create a copy of OpeningStockDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpeningStockDtoCopyWith<_OpeningStockDto> get copyWith => __$OpeningStockDtoCopyWithImpl<_OpeningStockDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpeningStockDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpeningStockDto&&(identical(other.totalQuantity, totalQuantity) || other.totalQuantity == totalQuantity)&&const DeepCollectionEquality().equals(other._godowns, _godowns));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalQuantity,const DeepCollectionEquality().hash(_godowns));

@override
String toString() {
  return 'OpeningStockDto(totalQuantity: $totalQuantity, godowns: $godowns)';
}


}

/// @nodoc
abstract mixin class _$OpeningStockDtoCopyWith<$Res> implements $OpeningStockDtoCopyWith<$Res> {
  factory _$OpeningStockDtoCopyWith(_OpeningStockDto value, $Res Function(_OpeningStockDto) _then) = __$OpeningStockDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_quantity') String totalQuantity, List<OpeningStockGodownDto> godowns
});




}
/// @nodoc
class __$OpeningStockDtoCopyWithImpl<$Res>
    implements _$OpeningStockDtoCopyWith<$Res> {
  __$OpeningStockDtoCopyWithImpl(this._self, this._then);

  final _OpeningStockDto _self;
  final $Res Function(_OpeningStockDto) _then;

/// Create a copy of OpeningStockDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalQuantity = null,Object? godowns = null,}) {
  return _then(_OpeningStockDto(
totalQuantity: null == totalQuantity ? _self.totalQuantity : totalQuantity // ignore: cast_nullable_to_non_nullable
as String,godowns: null == godowns ? _self._godowns : godowns // ignore: cast_nullable_to_non_nullable
as List<OpeningStockGodownDto>,
  ));
}


}

// dart format on
