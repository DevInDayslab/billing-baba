// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_access.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompanyAccess {

@JsonKey(name: 'business_name') String get businessName;@JsonKey(name: 'owner_name') String get ownerName;@JsonKey(name: 'owner_phone') String get ownerPhone;@JsonKey(name: 'total_members') int get totalMembers;@JsonKey(name: 'logged_in_phone') String get loggedInPhone;
/// Create a copy of CompanyAccess
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyAccessCopyWith<CompanyAccess> get copyWith => _$CompanyAccessCopyWithImpl<CompanyAccess>(this as CompanyAccess, _$identity);

  /// Serializes this CompanyAccess to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyAccess&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.ownerPhone, ownerPhone) || other.ownerPhone == ownerPhone)&&(identical(other.totalMembers, totalMembers) || other.totalMembers == totalMembers)&&(identical(other.loggedInPhone, loggedInPhone) || other.loggedInPhone == loggedInPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,businessName,ownerName,ownerPhone,totalMembers,loggedInPhone);

@override
String toString() {
  return 'CompanyAccess(businessName: $businessName, ownerName: $ownerName, ownerPhone: $ownerPhone, totalMembers: $totalMembers, loggedInPhone: $loggedInPhone)';
}


}

/// @nodoc
abstract mixin class $CompanyAccessCopyWith<$Res>  {
  factory $CompanyAccessCopyWith(CompanyAccess value, $Res Function(CompanyAccess) _then) = _$CompanyAccessCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'business_name') String businessName,@JsonKey(name: 'owner_name') String ownerName,@JsonKey(name: 'owner_phone') String ownerPhone,@JsonKey(name: 'total_members') int totalMembers,@JsonKey(name: 'logged_in_phone') String loggedInPhone
});




}
/// @nodoc
class _$CompanyAccessCopyWithImpl<$Res>
    implements $CompanyAccessCopyWith<$Res> {
  _$CompanyAccessCopyWithImpl(this._self, this._then);

  final CompanyAccess _self;
  final $Res Function(CompanyAccess) _then;

/// Create a copy of CompanyAccess
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? businessName = null,Object? ownerName = null,Object? ownerPhone = null,Object? totalMembers = null,Object? loggedInPhone = null,}) {
  return _then(_self.copyWith(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,ownerPhone: null == ownerPhone ? _self.ownerPhone : ownerPhone // ignore: cast_nullable_to_non_nullable
as String,totalMembers: null == totalMembers ? _self.totalMembers : totalMembers // ignore: cast_nullable_to_non_nullable
as int,loggedInPhone: null == loggedInPhone ? _self.loggedInPhone : loggedInPhone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanyAccess].
extension CompanyAccessPatterns on CompanyAccess {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanyAccess value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanyAccess() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanyAccess value)  $default,){
final _that = this;
switch (_that) {
case _CompanyAccess():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanyAccess value)?  $default,){
final _that = this;
switch (_that) {
case _CompanyAccess() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'business_name')  String businessName, @JsonKey(name: 'owner_name')  String ownerName, @JsonKey(name: 'owner_phone')  String ownerPhone, @JsonKey(name: 'total_members')  int totalMembers, @JsonKey(name: 'logged_in_phone')  String loggedInPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanyAccess() when $default != null:
return $default(_that.businessName,_that.ownerName,_that.ownerPhone,_that.totalMembers,_that.loggedInPhone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'business_name')  String businessName, @JsonKey(name: 'owner_name')  String ownerName, @JsonKey(name: 'owner_phone')  String ownerPhone, @JsonKey(name: 'total_members')  int totalMembers, @JsonKey(name: 'logged_in_phone')  String loggedInPhone)  $default,) {final _that = this;
switch (_that) {
case _CompanyAccess():
return $default(_that.businessName,_that.ownerName,_that.ownerPhone,_that.totalMembers,_that.loggedInPhone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'business_name')  String businessName, @JsonKey(name: 'owner_name')  String ownerName, @JsonKey(name: 'owner_phone')  String ownerPhone, @JsonKey(name: 'total_members')  int totalMembers, @JsonKey(name: 'logged_in_phone')  String loggedInPhone)?  $default,) {final _that = this;
switch (_that) {
case _CompanyAccess() when $default != null:
return $default(_that.businessName,_that.ownerName,_that.ownerPhone,_that.totalMembers,_that.loggedInPhone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompanyAccess implements CompanyAccess {
  const _CompanyAccess({@JsonKey(name: 'business_name') required this.businessName, @JsonKey(name: 'owner_name') required this.ownerName, @JsonKey(name: 'owner_phone') required this.ownerPhone, @JsonKey(name: 'total_members') required this.totalMembers, @JsonKey(name: 'logged_in_phone') required this.loggedInPhone});
  factory _CompanyAccess.fromJson(Map<String, dynamic> json) => _$CompanyAccessFromJson(json);

@override@JsonKey(name: 'business_name') final  String businessName;
@override@JsonKey(name: 'owner_name') final  String ownerName;
@override@JsonKey(name: 'owner_phone') final  String ownerPhone;
@override@JsonKey(name: 'total_members') final  int totalMembers;
@override@JsonKey(name: 'logged_in_phone') final  String loggedInPhone;

/// Create a copy of CompanyAccess
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyAccessCopyWith<_CompanyAccess> get copyWith => __$CompanyAccessCopyWithImpl<_CompanyAccess>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompanyAccessToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyAccess&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.ownerPhone, ownerPhone) || other.ownerPhone == ownerPhone)&&(identical(other.totalMembers, totalMembers) || other.totalMembers == totalMembers)&&(identical(other.loggedInPhone, loggedInPhone) || other.loggedInPhone == loggedInPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,businessName,ownerName,ownerPhone,totalMembers,loggedInPhone);

@override
String toString() {
  return 'CompanyAccess(businessName: $businessName, ownerName: $ownerName, ownerPhone: $ownerPhone, totalMembers: $totalMembers, loggedInPhone: $loggedInPhone)';
}


}

/// @nodoc
abstract mixin class _$CompanyAccessCopyWith<$Res> implements $CompanyAccessCopyWith<$Res> {
  factory _$CompanyAccessCopyWith(_CompanyAccess value, $Res Function(_CompanyAccess) _then) = __$CompanyAccessCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'business_name') String businessName,@JsonKey(name: 'owner_name') String ownerName,@JsonKey(name: 'owner_phone') String ownerPhone,@JsonKey(name: 'total_members') int totalMembers,@JsonKey(name: 'logged_in_phone') String loggedInPhone
});




}
/// @nodoc
class __$CompanyAccessCopyWithImpl<$Res>
    implements _$CompanyAccessCopyWith<$Res> {
  __$CompanyAccessCopyWithImpl(this._self, this._then);

  final _CompanyAccess _self;
  final $Res Function(_CompanyAccess) _then;

/// Create a copy of CompanyAccess
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? businessName = null,Object? ownerName = null,Object? ownerPhone = null,Object? totalMembers = null,Object? loggedInPhone = null,}) {
  return _then(_CompanyAccess(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,ownerPhone: null == ownerPhone ? _self.ownerPhone : ownerPhone // ignore: cast_nullable_to_non_nullable
as String,totalMembers: null == totalMembers ? _self.totalMembers : totalMembers // ignore: cast_nullable_to_non_nullable
as int,loggedInPhone: null == loggedInPhone ? _self.loggedInPhone : loggedInPhone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
