// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BusinessSummary {

 String get id; String get name; String get role; String? get gstin;
/// Create a copy of BusinessSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessSummaryCopyWith<BusinessSummary> get copyWith => _$BusinessSummaryCopyWithImpl<BusinessSummary>(this as BusinessSummary, _$identity);

  /// Serializes this BusinessSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.gstin, gstin) || other.gstin == gstin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,role,gstin);

@override
String toString() {
  return 'BusinessSummary(id: $id, name: $name, role: $role, gstin: $gstin)';
}


}

/// @nodoc
abstract mixin class $BusinessSummaryCopyWith<$Res>  {
  factory $BusinessSummaryCopyWith(BusinessSummary value, $Res Function(BusinessSummary) _then) = _$BusinessSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String role, String? gstin
});




}
/// @nodoc
class _$BusinessSummaryCopyWithImpl<$Res>
    implements $BusinessSummaryCopyWith<$Res> {
  _$BusinessSummaryCopyWithImpl(this._self, this._then);

  final BusinessSummary _self;
  final $Res Function(BusinessSummary) _then;

/// Create a copy of BusinessSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? role = null,Object? gstin = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,gstin: freezed == gstin ? _self.gstin : gstin // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BusinessSummary].
extension BusinessSummaryPatterns on BusinessSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusinessSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusinessSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusinessSummary value)  $default,){
final _that = this;
switch (_that) {
case _BusinessSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusinessSummary value)?  $default,){
final _that = this;
switch (_that) {
case _BusinessSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String role,  String? gstin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusinessSummary() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.gstin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String role,  String? gstin)  $default,) {final _that = this;
switch (_that) {
case _BusinessSummary():
return $default(_that.id,_that.name,_that.role,_that.gstin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String role,  String? gstin)?  $default,) {final _that = this;
switch (_that) {
case _BusinessSummary() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.gstin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BusinessSummary implements BusinessSummary {
  const _BusinessSummary({required this.id, required this.name, required this.role, this.gstin});
  factory _BusinessSummary.fromJson(Map<String, dynamic> json) => _$BusinessSummaryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String role;
@override final  String? gstin;

/// Create a copy of BusinessSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessSummaryCopyWith<_BusinessSummary> get copyWith => __$BusinessSummaryCopyWithImpl<_BusinessSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BusinessSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusinessSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.gstin, gstin) || other.gstin == gstin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,role,gstin);

@override
String toString() {
  return 'BusinessSummary(id: $id, name: $name, role: $role, gstin: $gstin)';
}


}

/// @nodoc
abstract mixin class _$BusinessSummaryCopyWith<$Res> implements $BusinessSummaryCopyWith<$Res> {
  factory _$BusinessSummaryCopyWith(_BusinessSummary value, $Res Function(_BusinessSummary) _then) = __$BusinessSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String role, String? gstin
});




}
/// @nodoc
class __$BusinessSummaryCopyWithImpl<$Res>
    implements _$BusinessSummaryCopyWith<$Res> {
  __$BusinessSummaryCopyWithImpl(this._self, this._then);

  final _BusinessSummary _self;
  final $Res Function(_BusinessSummary) _then;

/// Create a copy of BusinessSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? role = null,Object? gstin = freezed,}) {
  return _then(_BusinessSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,gstin: freezed == gstin ? _self.gstin : gstin // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
