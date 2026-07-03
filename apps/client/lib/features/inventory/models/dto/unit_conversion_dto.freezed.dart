// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unit_conversion_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UnitConversionDto {

 String get id;@JsonKey(name: 'from_unit_id') String get fromUnitId;@JsonKey(name: 'to_unit_id') String get toUnitId;@JsonKey(name: 'conversion_factor') String get conversionFactor; String get label;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;@JsonKey(name: 'from_unit_name') String? get fromUnitName;@JsonKey(name: 'to_unit_name') String? get toUnitName;
/// Create a copy of UnitConversionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitConversionDtoCopyWith<UnitConversionDto> get copyWith => _$UnitConversionDtoCopyWithImpl<UnitConversionDto>(this as UnitConversionDto, _$identity);

  /// Serializes this UnitConversionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnitConversionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUnitId, fromUnitId) || other.fromUnitId == fromUnitId)&&(identical(other.toUnitId, toUnitId) || other.toUnitId == toUnitId)&&(identical(other.conversionFactor, conversionFactor) || other.conversionFactor == conversionFactor)&&(identical(other.label, label) || other.label == label)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.fromUnitName, fromUnitName) || other.fromUnitName == fromUnitName)&&(identical(other.toUnitName, toUnitName) || other.toUnitName == toUnitName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromUnitId,toUnitId,conversionFactor,label,createdAt,updatedAt,fromUnitName,toUnitName);

@override
String toString() {
  return 'UnitConversionDto(id: $id, fromUnitId: $fromUnitId, toUnitId: $toUnitId, conversionFactor: $conversionFactor, label: $label, createdAt: $createdAt, updatedAt: $updatedAt, fromUnitName: $fromUnitName, toUnitName: $toUnitName)';
}


}

/// @nodoc
abstract mixin class $UnitConversionDtoCopyWith<$Res>  {
  factory $UnitConversionDtoCopyWith(UnitConversionDto value, $Res Function(UnitConversionDto) _then) = _$UnitConversionDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'from_unit_id') String fromUnitId,@JsonKey(name: 'to_unit_id') String toUnitId,@JsonKey(name: 'conversion_factor') String conversionFactor, String label,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt,@JsonKey(name: 'from_unit_name') String? fromUnitName,@JsonKey(name: 'to_unit_name') String? toUnitName
});




}
/// @nodoc
class _$UnitConversionDtoCopyWithImpl<$Res>
    implements $UnitConversionDtoCopyWith<$Res> {
  _$UnitConversionDtoCopyWithImpl(this._self, this._then);

  final UnitConversionDto _self;
  final $Res Function(UnitConversionDto) _then;

/// Create a copy of UnitConversionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromUnitId = null,Object? toUnitId = null,Object? conversionFactor = null,Object? label = null,Object? createdAt = null,Object? updatedAt = null,Object? fromUnitName = freezed,Object? toUnitName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromUnitId: null == fromUnitId ? _self.fromUnitId : fromUnitId // ignore: cast_nullable_to_non_nullable
as String,toUnitId: null == toUnitId ? _self.toUnitId : toUnitId // ignore: cast_nullable_to_non_nullable
as String,conversionFactor: null == conversionFactor ? _self.conversionFactor : conversionFactor // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,fromUnitName: freezed == fromUnitName ? _self.fromUnitName : fromUnitName // ignore: cast_nullable_to_non_nullable
as String?,toUnitName: freezed == toUnitName ? _self.toUnitName : toUnitName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UnitConversionDto].
extension UnitConversionDtoPatterns on UnitConversionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnitConversionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnitConversionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnitConversionDto value)  $default,){
final _that = this;
switch (_that) {
case _UnitConversionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnitConversionDto value)?  $default,){
final _that = this;
switch (_that) {
case _UnitConversionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'from_unit_id')  String fromUnitId, @JsonKey(name: 'to_unit_id')  String toUnitId, @JsonKey(name: 'conversion_factor')  String conversionFactor,  String label, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'from_unit_name')  String? fromUnitName, @JsonKey(name: 'to_unit_name')  String? toUnitName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnitConversionDto() when $default != null:
return $default(_that.id,_that.fromUnitId,_that.toUnitId,_that.conversionFactor,_that.label,_that.createdAt,_that.updatedAt,_that.fromUnitName,_that.toUnitName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'from_unit_id')  String fromUnitId, @JsonKey(name: 'to_unit_id')  String toUnitId, @JsonKey(name: 'conversion_factor')  String conversionFactor,  String label, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'from_unit_name')  String? fromUnitName, @JsonKey(name: 'to_unit_name')  String? toUnitName)  $default,) {final _that = this;
switch (_that) {
case _UnitConversionDto():
return $default(_that.id,_that.fromUnitId,_that.toUnitId,_that.conversionFactor,_that.label,_that.createdAt,_that.updatedAt,_that.fromUnitName,_that.toUnitName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'from_unit_id')  String fromUnitId, @JsonKey(name: 'to_unit_id')  String toUnitId, @JsonKey(name: 'conversion_factor')  String conversionFactor,  String label, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt, @JsonKey(name: 'from_unit_name')  String? fromUnitName, @JsonKey(name: 'to_unit_name')  String? toUnitName)?  $default,) {final _that = this;
switch (_that) {
case _UnitConversionDto() when $default != null:
return $default(_that.id,_that.fromUnitId,_that.toUnitId,_that.conversionFactor,_that.label,_that.createdAt,_that.updatedAt,_that.fromUnitName,_that.toUnitName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnitConversionDto implements UnitConversionDto {
  const _UnitConversionDto({required this.id, @JsonKey(name: 'from_unit_id') required this.fromUnitId, @JsonKey(name: 'to_unit_id') required this.toUnitId, @JsonKey(name: 'conversion_factor') required this.conversionFactor, required this.label, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'from_unit_name') this.fromUnitName, @JsonKey(name: 'to_unit_name') this.toUnitName});
  factory _UnitConversionDto.fromJson(Map<String, dynamic> json) => _$UnitConversionDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'from_unit_id') final  String fromUnitId;
@override@JsonKey(name: 'to_unit_id') final  String toUnitId;
@override@JsonKey(name: 'conversion_factor') final  String conversionFactor;
@override final  String label;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override@JsonKey(name: 'from_unit_name') final  String? fromUnitName;
@override@JsonKey(name: 'to_unit_name') final  String? toUnitName;

/// Create a copy of UnitConversionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnitConversionDtoCopyWith<_UnitConversionDto> get copyWith => __$UnitConversionDtoCopyWithImpl<_UnitConversionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnitConversionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnitConversionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUnitId, fromUnitId) || other.fromUnitId == fromUnitId)&&(identical(other.toUnitId, toUnitId) || other.toUnitId == toUnitId)&&(identical(other.conversionFactor, conversionFactor) || other.conversionFactor == conversionFactor)&&(identical(other.label, label) || other.label == label)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.fromUnitName, fromUnitName) || other.fromUnitName == fromUnitName)&&(identical(other.toUnitName, toUnitName) || other.toUnitName == toUnitName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromUnitId,toUnitId,conversionFactor,label,createdAt,updatedAt,fromUnitName,toUnitName);

@override
String toString() {
  return 'UnitConversionDto(id: $id, fromUnitId: $fromUnitId, toUnitId: $toUnitId, conversionFactor: $conversionFactor, label: $label, createdAt: $createdAt, updatedAt: $updatedAt, fromUnitName: $fromUnitName, toUnitName: $toUnitName)';
}


}

/// @nodoc
abstract mixin class _$UnitConversionDtoCopyWith<$Res> implements $UnitConversionDtoCopyWith<$Res> {
  factory _$UnitConversionDtoCopyWith(_UnitConversionDto value, $Res Function(_UnitConversionDto) _then) = __$UnitConversionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'from_unit_id') String fromUnitId,@JsonKey(name: 'to_unit_id') String toUnitId,@JsonKey(name: 'conversion_factor') String conversionFactor, String label,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt,@JsonKey(name: 'from_unit_name') String? fromUnitName,@JsonKey(name: 'to_unit_name') String? toUnitName
});




}
/// @nodoc
class __$UnitConversionDtoCopyWithImpl<$Res>
    implements _$UnitConversionDtoCopyWith<$Res> {
  __$UnitConversionDtoCopyWithImpl(this._self, this._then);

  final _UnitConversionDto _self;
  final $Res Function(_UnitConversionDto) _then;

/// Create a copy of UnitConversionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromUnitId = null,Object? toUnitId = null,Object? conversionFactor = null,Object? label = null,Object? createdAt = null,Object? updatedAt = null,Object? fromUnitName = freezed,Object? toUnitName = freezed,}) {
  return _then(_UnitConversionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromUnitId: null == fromUnitId ? _self.fromUnitId : fromUnitId // ignore: cast_nullable_to_non_nullable
as String,toUnitId: null == toUnitId ? _self.toUnitId : toUnitId // ignore: cast_nullable_to_non_nullable
as String,conversionFactor: null == conversionFactor ? _self.conversionFactor : conversionFactor // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,fromUnitName: freezed == fromUnitName ? _self.fromUnitName : fromUnitName // ignore: cast_nullable_to_non_nullable
as String?,toUnitName: freezed == toUnitName ? _self.toUnitName : toUnitName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
