// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_order_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateOrderResult {

@JsonKey(name: 'paymentUuid') String get paymentUuid;@JsonKey(name: 'razorpayOrderId') String get razorpayOrderId;@JsonKey(name: 'razorpayKey') String get razorpayKey; int get amount; String get currency;@JsonKey(name: 'businessName') String get businessName;@JsonKey(name: 'ownerName') String get ownerName;@JsonKey(name: 'businessEmail') String get businessEmail;@JsonKey(name: 'businessPhone') String get businessPhone;
/// Create a copy of CreateOrderResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateOrderResultCopyWith<CreateOrderResult> get copyWith => _$CreateOrderResultCopyWithImpl<CreateOrderResult>(this as CreateOrderResult, _$identity);

  /// Serializes this CreateOrderResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateOrderResult&&(identical(other.paymentUuid, paymentUuid) || other.paymentUuid == paymentUuid)&&(identical(other.razorpayOrderId, razorpayOrderId) || other.razorpayOrderId == razorpayOrderId)&&(identical(other.razorpayKey, razorpayKey) || other.razorpayKey == razorpayKey)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.businessEmail, businessEmail) || other.businessEmail == businessEmail)&&(identical(other.businessPhone, businessPhone) || other.businessPhone == businessPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentUuid,razorpayOrderId,razorpayKey,amount,currency,businessName,ownerName,businessEmail,businessPhone);

@override
String toString() {
  return 'CreateOrderResult(paymentUuid: $paymentUuid, razorpayOrderId: $razorpayOrderId, razorpayKey: $razorpayKey, amount: $amount, currency: $currency, businessName: $businessName, ownerName: $ownerName, businessEmail: $businessEmail, businessPhone: $businessPhone)';
}


}

/// @nodoc
abstract mixin class $CreateOrderResultCopyWith<$Res>  {
  factory $CreateOrderResultCopyWith(CreateOrderResult value, $Res Function(CreateOrderResult) _then) = _$CreateOrderResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'paymentUuid') String paymentUuid,@JsonKey(name: 'razorpayOrderId') String razorpayOrderId,@JsonKey(name: 'razorpayKey') String razorpayKey, int amount, String currency,@JsonKey(name: 'businessName') String businessName,@JsonKey(name: 'ownerName') String ownerName,@JsonKey(name: 'businessEmail') String businessEmail,@JsonKey(name: 'businessPhone') String businessPhone
});




}
/// @nodoc
class _$CreateOrderResultCopyWithImpl<$Res>
    implements $CreateOrderResultCopyWith<$Res> {
  _$CreateOrderResultCopyWithImpl(this._self, this._then);

  final CreateOrderResult _self;
  final $Res Function(CreateOrderResult) _then;

/// Create a copy of CreateOrderResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentUuid = null,Object? razorpayOrderId = null,Object? razorpayKey = null,Object? amount = null,Object? currency = null,Object? businessName = null,Object? ownerName = null,Object? businessEmail = null,Object? businessPhone = null,}) {
  return _then(_self.copyWith(
paymentUuid: null == paymentUuid ? _self.paymentUuid : paymentUuid // ignore: cast_nullable_to_non_nullable
as String,razorpayOrderId: null == razorpayOrderId ? _self.razorpayOrderId : razorpayOrderId // ignore: cast_nullable_to_non_nullable
as String,razorpayKey: null == razorpayKey ? _self.razorpayKey : razorpayKey // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,businessEmail: null == businessEmail ? _self.businessEmail : businessEmail // ignore: cast_nullable_to_non_nullable
as String,businessPhone: null == businessPhone ? _self.businessPhone : businessPhone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateOrderResult].
extension CreateOrderResultPatterns on CreateOrderResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateOrderResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateOrderResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateOrderResult value)  $default,){
final _that = this;
switch (_that) {
case _CreateOrderResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateOrderResult value)?  $default,){
final _that = this;
switch (_that) {
case _CreateOrderResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'paymentUuid')  String paymentUuid, @JsonKey(name: 'razorpayOrderId')  String razorpayOrderId, @JsonKey(name: 'razorpayKey')  String razorpayKey,  int amount,  String currency, @JsonKey(name: 'businessName')  String businessName, @JsonKey(name: 'ownerName')  String ownerName, @JsonKey(name: 'businessEmail')  String businessEmail, @JsonKey(name: 'businessPhone')  String businessPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateOrderResult() when $default != null:
return $default(_that.paymentUuid,_that.razorpayOrderId,_that.razorpayKey,_that.amount,_that.currency,_that.businessName,_that.ownerName,_that.businessEmail,_that.businessPhone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'paymentUuid')  String paymentUuid, @JsonKey(name: 'razorpayOrderId')  String razorpayOrderId, @JsonKey(name: 'razorpayKey')  String razorpayKey,  int amount,  String currency, @JsonKey(name: 'businessName')  String businessName, @JsonKey(name: 'ownerName')  String ownerName, @JsonKey(name: 'businessEmail')  String businessEmail, @JsonKey(name: 'businessPhone')  String businessPhone)  $default,) {final _that = this;
switch (_that) {
case _CreateOrderResult():
return $default(_that.paymentUuid,_that.razorpayOrderId,_that.razorpayKey,_that.amount,_that.currency,_that.businessName,_that.ownerName,_that.businessEmail,_that.businessPhone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'paymentUuid')  String paymentUuid, @JsonKey(name: 'razorpayOrderId')  String razorpayOrderId, @JsonKey(name: 'razorpayKey')  String razorpayKey,  int amount,  String currency, @JsonKey(name: 'businessName')  String businessName, @JsonKey(name: 'ownerName')  String ownerName, @JsonKey(name: 'businessEmail')  String businessEmail, @JsonKey(name: 'businessPhone')  String businessPhone)?  $default,) {final _that = this;
switch (_that) {
case _CreateOrderResult() when $default != null:
return $default(_that.paymentUuid,_that.razorpayOrderId,_that.razorpayKey,_that.amount,_that.currency,_that.businessName,_that.ownerName,_that.businessEmail,_that.businessPhone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateOrderResult implements CreateOrderResult {
  const _CreateOrderResult({@JsonKey(name: 'paymentUuid') required this.paymentUuid, @JsonKey(name: 'razorpayOrderId') required this.razorpayOrderId, @JsonKey(name: 'razorpayKey') required this.razorpayKey, required this.amount, required this.currency, @JsonKey(name: 'businessName') required this.businessName, @JsonKey(name: 'ownerName') required this.ownerName, @JsonKey(name: 'businessEmail') required this.businessEmail, @JsonKey(name: 'businessPhone') required this.businessPhone});
  factory _CreateOrderResult.fromJson(Map<String, dynamic> json) => _$CreateOrderResultFromJson(json);

@override@JsonKey(name: 'paymentUuid') final  String paymentUuid;
@override@JsonKey(name: 'razorpayOrderId') final  String razorpayOrderId;
@override@JsonKey(name: 'razorpayKey') final  String razorpayKey;
@override final  int amount;
@override final  String currency;
@override@JsonKey(name: 'businessName') final  String businessName;
@override@JsonKey(name: 'ownerName') final  String ownerName;
@override@JsonKey(name: 'businessEmail') final  String businessEmail;
@override@JsonKey(name: 'businessPhone') final  String businessPhone;

/// Create a copy of CreateOrderResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateOrderResultCopyWith<_CreateOrderResult> get copyWith => __$CreateOrderResultCopyWithImpl<_CreateOrderResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateOrderResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateOrderResult&&(identical(other.paymentUuid, paymentUuid) || other.paymentUuid == paymentUuid)&&(identical(other.razorpayOrderId, razorpayOrderId) || other.razorpayOrderId == razorpayOrderId)&&(identical(other.razorpayKey, razorpayKey) || other.razorpayKey == razorpayKey)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.businessEmail, businessEmail) || other.businessEmail == businessEmail)&&(identical(other.businessPhone, businessPhone) || other.businessPhone == businessPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentUuid,razorpayOrderId,razorpayKey,amount,currency,businessName,ownerName,businessEmail,businessPhone);

@override
String toString() {
  return 'CreateOrderResult(paymentUuid: $paymentUuid, razorpayOrderId: $razorpayOrderId, razorpayKey: $razorpayKey, amount: $amount, currency: $currency, businessName: $businessName, ownerName: $ownerName, businessEmail: $businessEmail, businessPhone: $businessPhone)';
}


}

/// @nodoc
abstract mixin class _$CreateOrderResultCopyWith<$Res> implements $CreateOrderResultCopyWith<$Res> {
  factory _$CreateOrderResultCopyWith(_CreateOrderResult value, $Res Function(_CreateOrderResult) _then) = __$CreateOrderResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'paymentUuid') String paymentUuid,@JsonKey(name: 'razorpayOrderId') String razorpayOrderId,@JsonKey(name: 'razorpayKey') String razorpayKey, int amount, String currency,@JsonKey(name: 'businessName') String businessName,@JsonKey(name: 'ownerName') String ownerName,@JsonKey(name: 'businessEmail') String businessEmail,@JsonKey(name: 'businessPhone') String businessPhone
});




}
/// @nodoc
class __$CreateOrderResultCopyWithImpl<$Res>
    implements _$CreateOrderResultCopyWith<$Res> {
  __$CreateOrderResultCopyWithImpl(this._self, this._then);

  final _CreateOrderResult _self;
  final $Res Function(_CreateOrderResult) _then;

/// Create a copy of CreateOrderResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentUuid = null,Object? razorpayOrderId = null,Object? razorpayKey = null,Object? amount = null,Object? currency = null,Object? businessName = null,Object? ownerName = null,Object? businessEmail = null,Object? businessPhone = null,}) {
  return _then(_CreateOrderResult(
paymentUuid: null == paymentUuid ? _self.paymentUuid : paymentUuid // ignore: cast_nullable_to_non_nullable
as String,razorpayOrderId: null == razorpayOrderId ? _self.razorpayOrderId : razorpayOrderId // ignore: cast_nullable_to_non_nullable
as String,razorpayKey: null == razorpayKey ? _self.razorpayKey : razorpayKey // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,businessEmail: null == businessEmail ? _self.businessEmail : businessEmail // ignore: cast_nullable_to_non_nullable
as String,businessPhone: null == businessPhone ? _self.businessPhone : businessPhone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
