// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_payment_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VerifyPaymentResult {

 bool get activated; SubscriptionPlanType get plan; DateTime get expiresAt;
/// Create a copy of VerifyPaymentResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyPaymentResultCopyWith<VerifyPaymentResult> get copyWith => _$VerifyPaymentResultCopyWithImpl<VerifyPaymentResult>(this as VerifyPaymentResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyPaymentResult&&(identical(other.activated, activated) || other.activated == activated)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,activated,plan,expiresAt);

@override
String toString() {
  return 'VerifyPaymentResult(activated: $activated, plan: $plan, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $VerifyPaymentResultCopyWith<$Res>  {
  factory $VerifyPaymentResultCopyWith(VerifyPaymentResult value, $Res Function(VerifyPaymentResult) _then) = _$VerifyPaymentResultCopyWithImpl;
@useResult
$Res call({
 bool activated, SubscriptionPlanType plan, DateTime expiresAt
});




}
/// @nodoc
class _$VerifyPaymentResultCopyWithImpl<$Res>
    implements $VerifyPaymentResultCopyWith<$Res> {
  _$VerifyPaymentResultCopyWithImpl(this._self, this._then);

  final VerifyPaymentResult _self;
  final $Res Function(VerifyPaymentResult) _then;

/// Create a copy of VerifyPaymentResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activated = null,Object? plan = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
activated: null == activated ? _self.activated : activated // ignore: cast_nullable_to_non_nullable
as bool,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as SubscriptionPlanType,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyPaymentResult].
extension VerifyPaymentResultPatterns on VerifyPaymentResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyPaymentResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyPaymentResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyPaymentResult value)  $default,){
final _that = this;
switch (_that) {
case _VerifyPaymentResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyPaymentResult value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyPaymentResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool activated,  SubscriptionPlanType plan,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyPaymentResult() when $default != null:
return $default(_that.activated,_that.plan,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool activated,  SubscriptionPlanType plan,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _VerifyPaymentResult():
return $default(_that.activated,_that.plan,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool activated,  SubscriptionPlanType plan,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _VerifyPaymentResult() when $default != null:
return $default(_that.activated,_that.plan,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _VerifyPaymentResult implements VerifyPaymentResult {
  const _VerifyPaymentResult({required this.activated, required this.plan, required this.expiresAt});
  

@override final  bool activated;
@override final  SubscriptionPlanType plan;
@override final  DateTime expiresAt;

/// Create a copy of VerifyPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyPaymentResultCopyWith<_VerifyPaymentResult> get copyWith => __$VerifyPaymentResultCopyWithImpl<_VerifyPaymentResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyPaymentResult&&(identical(other.activated, activated) || other.activated == activated)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,activated,plan,expiresAt);

@override
String toString() {
  return 'VerifyPaymentResult(activated: $activated, plan: $plan, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$VerifyPaymentResultCopyWith<$Res> implements $VerifyPaymentResultCopyWith<$Res> {
  factory _$VerifyPaymentResultCopyWith(_VerifyPaymentResult value, $Res Function(_VerifyPaymentResult) _then) = __$VerifyPaymentResultCopyWithImpl;
@override @useResult
$Res call({
 bool activated, SubscriptionPlanType plan, DateTime expiresAt
});




}
/// @nodoc
class __$VerifyPaymentResultCopyWithImpl<$Res>
    implements _$VerifyPaymentResultCopyWith<$Res> {
  __$VerifyPaymentResultCopyWithImpl(this._self, this._then);

  final _VerifyPaymentResult _self;
  final $Res Function(_VerifyPaymentResult) _then;

/// Create a copy of VerifyPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activated = null,Object? plan = null,Object? expiresAt = null,}) {
  return _then(_VerifyPaymentResult(
activated: null == activated ? _self.activated : activated // ignore: cast_nullable_to_non_nullable
as bool,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as SubscriptionPlanType,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
