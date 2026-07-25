// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'current_subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CurrentSubscription {

 SubscriptionPlanType get planType; String get planName; SubscriptionStatus get status; DateTime? get expiresAt; int? get remainingDays; DateTime? get purchaseDate; DateTime? get renewalDate;
/// Create a copy of CurrentSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentSubscriptionCopyWith<CurrentSubscription> get copyWith => _$CurrentSubscriptionCopyWithImpl<CurrentSubscription>(this as CurrentSubscription, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentSubscription&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.remainingDays, remainingDays) || other.remainingDays == remainingDays)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.renewalDate, renewalDate) || other.renewalDate == renewalDate));
}


@override
int get hashCode => Object.hash(runtimeType,planType,planName,status,expiresAt,remainingDays,purchaseDate,renewalDate);

@override
String toString() {
  return 'CurrentSubscription(planType: $planType, planName: $planName, status: $status, expiresAt: $expiresAt, remainingDays: $remainingDays, purchaseDate: $purchaseDate, renewalDate: $renewalDate)';
}


}

/// @nodoc
abstract mixin class $CurrentSubscriptionCopyWith<$Res>  {
  factory $CurrentSubscriptionCopyWith(CurrentSubscription value, $Res Function(CurrentSubscription) _then) = _$CurrentSubscriptionCopyWithImpl;
@useResult
$Res call({
 SubscriptionPlanType planType, String planName, SubscriptionStatus status, DateTime? expiresAt, int? remainingDays, DateTime? purchaseDate, DateTime? renewalDate
});




}
/// @nodoc
class _$CurrentSubscriptionCopyWithImpl<$Res>
    implements $CurrentSubscriptionCopyWith<$Res> {
  _$CurrentSubscriptionCopyWithImpl(this._self, this._then);

  final CurrentSubscription _self;
  final $Res Function(CurrentSubscription) _then;

/// Create a copy of CurrentSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? planType = null,Object? planName = null,Object? status = null,Object? expiresAt = freezed,Object? remainingDays = freezed,Object? purchaseDate = freezed,Object? renewalDate = freezed,}) {
  return _then(_self.copyWith(
planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as SubscriptionPlanType,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,remainingDays: freezed == remainingDays ? _self.remainingDays : remainingDays // ignore: cast_nullable_to_non_nullable
as int?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,renewalDate: freezed == renewalDate ? _self.renewalDate : renewalDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrentSubscription].
extension CurrentSubscriptionPatterns on CurrentSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentSubscription value)  $default,){
final _that = this;
switch (_that) {
case _CurrentSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SubscriptionPlanType planType,  String planName,  SubscriptionStatus status,  DateTime? expiresAt,  int? remainingDays,  DateTime? purchaseDate,  DateTime? renewalDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentSubscription() when $default != null:
return $default(_that.planType,_that.planName,_that.status,_that.expiresAt,_that.remainingDays,_that.purchaseDate,_that.renewalDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SubscriptionPlanType planType,  String planName,  SubscriptionStatus status,  DateTime? expiresAt,  int? remainingDays,  DateTime? purchaseDate,  DateTime? renewalDate)  $default,) {final _that = this;
switch (_that) {
case _CurrentSubscription():
return $default(_that.planType,_that.planName,_that.status,_that.expiresAt,_that.remainingDays,_that.purchaseDate,_that.renewalDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SubscriptionPlanType planType,  String planName,  SubscriptionStatus status,  DateTime? expiresAt,  int? remainingDays,  DateTime? purchaseDate,  DateTime? renewalDate)?  $default,) {final _that = this;
switch (_that) {
case _CurrentSubscription() when $default != null:
return $default(_that.planType,_that.planName,_that.status,_that.expiresAt,_that.remainingDays,_that.purchaseDate,_that.renewalDate);case _:
  return null;

}
}

}

/// @nodoc


class _CurrentSubscription extends CurrentSubscription {
  const _CurrentSubscription({required this.planType, required this.planName, required this.status, this.expiresAt, this.remainingDays, this.purchaseDate, this.renewalDate}): super._();
  

@override final  SubscriptionPlanType planType;
@override final  String planName;
@override final  SubscriptionStatus status;
@override final  DateTime? expiresAt;
@override final  int? remainingDays;
@override final  DateTime? purchaseDate;
@override final  DateTime? renewalDate;

/// Create a copy of CurrentSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentSubscriptionCopyWith<_CurrentSubscription> get copyWith => __$CurrentSubscriptionCopyWithImpl<_CurrentSubscription>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentSubscription&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.remainingDays, remainingDays) || other.remainingDays == remainingDays)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.renewalDate, renewalDate) || other.renewalDate == renewalDate));
}


@override
int get hashCode => Object.hash(runtimeType,planType,planName,status,expiresAt,remainingDays,purchaseDate,renewalDate);

@override
String toString() {
  return 'CurrentSubscription(planType: $planType, planName: $planName, status: $status, expiresAt: $expiresAt, remainingDays: $remainingDays, purchaseDate: $purchaseDate, renewalDate: $renewalDate)';
}


}

/// @nodoc
abstract mixin class _$CurrentSubscriptionCopyWith<$Res> implements $CurrentSubscriptionCopyWith<$Res> {
  factory _$CurrentSubscriptionCopyWith(_CurrentSubscription value, $Res Function(_CurrentSubscription) _then) = __$CurrentSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 SubscriptionPlanType planType, String planName, SubscriptionStatus status, DateTime? expiresAt, int? remainingDays, DateTime? purchaseDate, DateTime? renewalDate
});




}
/// @nodoc
class __$CurrentSubscriptionCopyWithImpl<$Res>
    implements _$CurrentSubscriptionCopyWith<$Res> {
  __$CurrentSubscriptionCopyWithImpl(this._self, this._then);

  final _CurrentSubscription _self;
  final $Res Function(_CurrentSubscription) _then;

/// Create a copy of CurrentSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? planType = null,Object? planName = null,Object? status = null,Object? expiresAt = freezed,Object? remainingDays = freezed,Object? purchaseDate = freezed,Object? renewalDate = freezed,}) {
  return _then(_CurrentSubscription(
planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as SubscriptionPlanType,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,remainingDays: freezed == remainingDays ? _self.remainingDays : remainingDays // ignore: cast_nullable_to_non_nullable
as int?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,renewalDate: freezed == renewalDate ? _self.renewalDate : renewalDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
