// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pagination_meta_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaginationMetaDto {

 int get page; int get limit; int get total;@JsonKey(name: 'totalPages') int? get totalPages;
/// Create a copy of PaginationMetaDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginationMetaDtoCopyWith<PaginationMetaDto> get copyWith => _$PaginationMetaDtoCopyWithImpl<PaginationMetaDto>(this as PaginationMetaDto, _$identity);

  /// Serializes this PaginationMetaDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginationMetaDto&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,limit,total,totalPages);

@override
String toString() {
  return 'PaginationMetaDto(page: $page, limit: $limit, total: $total, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class $PaginationMetaDtoCopyWith<$Res>  {
  factory $PaginationMetaDtoCopyWith(PaginationMetaDto value, $Res Function(PaginationMetaDto) _then) = _$PaginationMetaDtoCopyWithImpl;
@useResult
$Res call({
 int page, int limit, int total,@JsonKey(name: 'totalPages') int? totalPages
});




}
/// @nodoc
class _$PaginationMetaDtoCopyWithImpl<$Res>
    implements $PaginationMetaDtoCopyWith<$Res> {
  _$PaginationMetaDtoCopyWithImpl(this._self, this._then);

  final PaginationMetaDto _self;
  final $Res Function(PaginationMetaDto) _then;

/// Create a copy of PaginationMetaDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? limit = null,Object? total = null,Object? totalPages = freezed,}) {
  return _then(_self.copyWith(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: freezed == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginationMetaDto].
extension PaginationMetaDtoPatterns on PaginationMetaDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginationMetaDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginationMetaDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginationMetaDto value)  $default,){
final _that = this;
switch (_that) {
case _PaginationMetaDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginationMetaDto value)?  $default,){
final _that = this;
switch (_that) {
case _PaginationMetaDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int page,  int limit,  int total, @JsonKey(name: 'totalPages')  int? totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginationMetaDto() when $default != null:
return $default(_that.page,_that.limit,_that.total,_that.totalPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int page,  int limit,  int total, @JsonKey(name: 'totalPages')  int? totalPages)  $default,) {final _that = this;
switch (_that) {
case _PaginationMetaDto():
return $default(_that.page,_that.limit,_that.total,_that.totalPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int page,  int limit,  int total, @JsonKey(name: 'totalPages')  int? totalPages)?  $default,) {final _that = this;
switch (_that) {
case _PaginationMetaDto() when $default != null:
return $default(_that.page,_that.limit,_that.total,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginationMetaDto implements PaginationMetaDto {
  const _PaginationMetaDto({required this.page, required this.limit, required this.total, @JsonKey(name: 'totalPages') this.totalPages});
  factory _PaginationMetaDto.fromJson(Map<String, dynamic> json) => _$PaginationMetaDtoFromJson(json);

@override final  int page;
@override final  int limit;
@override final  int total;
@override@JsonKey(name: 'totalPages') final  int? totalPages;

/// Create a copy of PaginationMetaDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginationMetaDtoCopyWith<_PaginationMetaDto> get copyWith => __$PaginationMetaDtoCopyWithImpl<_PaginationMetaDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginationMetaDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginationMetaDto&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,limit,total,totalPages);

@override
String toString() {
  return 'PaginationMetaDto(page: $page, limit: $limit, total: $total, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$PaginationMetaDtoCopyWith<$Res> implements $PaginationMetaDtoCopyWith<$Res> {
  factory _$PaginationMetaDtoCopyWith(_PaginationMetaDto value, $Res Function(_PaginationMetaDto) _then) = __$PaginationMetaDtoCopyWithImpl;
@override @useResult
$Res call({
 int page, int limit, int total,@JsonKey(name: 'totalPages') int? totalPages
});




}
/// @nodoc
class __$PaginationMetaDtoCopyWithImpl<$Res>
    implements _$PaginationMetaDtoCopyWith<$Res> {
  __$PaginationMetaDtoCopyWithImpl(this._self, this._then);

  final _PaginationMetaDto _self;
  final $Res Function(_PaginationMetaDto) _then;

/// Create a copy of PaginationMetaDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? limit = null,Object? total = null,Object? totalPages = freezed,}) {
  return _then(_PaginationMetaDto(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: freezed == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
