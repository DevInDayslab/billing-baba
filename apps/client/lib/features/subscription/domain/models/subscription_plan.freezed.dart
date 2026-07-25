// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubscriptionPlan {

 String get id; SubscriptionPlanType get planType; String get title; String get description; int get durationDays; String get durationLabel; double get amount; String get currency; int get deviceLimit; String get licenseType; String? get badge; bool get isPopular; List<String> get features; bool get isActive;
/// Create a copy of SubscriptionPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionPlanCopyWith<SubscriptionPlan> get copyWith => _$SubscriptionPlanCopyWithImpl<SubscriptionPlan>(this as SubscriptionPlan, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.durationLabel, durationLabel) || other.durationLabel == durationLabel)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.deviceLimit, deviceLimit) || other.deviceLimit == deviceLimit)&&(identical(other.licenseType, licenseType) || other.licenseType == licenseType)&&(identical(other.badge, badge) || other.badge == badge)&&(identical(other.isPopular, isPopular) || other.isPopular == isPopular)&&const DeepCollectionEquality().equals(other.features, features)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode => Object.hash(runtimeType,id,planType,title,description,durationDays,durationLabel,amount,currency,deviceLimit,licenseType,badge,isPopular,const DeepCollectionEquality().hash(features),isActive);

@override
String toString() {
  return 'SubscriptionPlan(id: $id, planType: $planType, title: $title, description: $description, durationDays: $durationDays, durationLabel: $durationLabel, amount: $amount, currency: $currency, deviceLimit: $deviceLimit, licenseType: $licenseType, badge: $badge, isPopular: $isPopular, features: $features, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $SubscriptionPlanCopyWith<$Res>  {
  factory $SubscriptionPlanCopyWith(SubscriptionPlan value, $Res Function(SubscriptionPlan) _then) = _$SubscriptionPlanCopyWithImpl;
@useResult
$Res call({
 String id, SubscriptionPlanType planType, String title, String description, int durationDays, String durationLabel, double amount, String currency, int deviceLimit, String licenseType, String? badge, bool isPopular, List<String> features, bool isActive
});




}
/// @nodoc
class _$SubscriptionPlanCopyWithImpl<$Res>
    implements $SubscriptionPlanCopyWith<$Res> {
  _$SubscriptionPlanCopyWithImpl(this._self, this._then);

  final SubscriptionPlan _self;
  final $Res Function(SubscriptionPlan) _then;

/// Create a copy of SubscriptionPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? planType = null,Object? title = null,Object? description = null,Object? durationDays = null,Object? durationLabel = null,Object? amount = null,Object? currency = null,Object? deviceLimit = null,Object? licenseType = null,Object? badge = freezed,Object? isPopular = null,Object? features = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as SubscriptionPlanType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,durationDays: null == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int,durationLabel: null == durationLabel ? _self.durationLabel : durationLabel // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,deviceLimit: null == deviceLimit ? _self.deviceLimit : deviceLimit // ignore: cast_nullable_to_non_nullable
as int,licenseType: null == licenseType ? _self.licenseType : licenseType // ignore: cast_nullable_to_non_nullable
as String,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String?,isPopular: null == isPopular ? _self.isPopular : isPopular // ignore: cast_nullable_to_non_nullable
as bool,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionPlan].
extension SubscriptionPlanPatterns on SubscriptionPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionPlan value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionPlan value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  SubscriptionPlanType planType,  String title,  String description,  int durationDays,  String durationLabel,  double amount,  String currency,  int deviceLimit,  String licenseType,  String? badge,  bool isPopular,  List<String> features,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionPlan() when $default != null:
return $default(_that.id,_that.planType,_that.title,_that.description,_that.durationDays,_that.durationLabel,_that.amount,_that.currency,_that.deviceLimit,_that.licenseType,_that.badge,_that.isPopular,_that.features,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  SubscriptionPlanType planType,  String title,  String description,  int durationDays,  String durationLabel,  double amount,  String currency,  int deviceLimit,  String licenseType,  String? badge,  bool isPopular,  List<String> features,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionPlan():
return $default(_that.id,_that.planType,_that.title,_that.description,_that.durationDays,_that.durationLabel,_that.amount,_that.currency,_that.deviceLimit,_that.licenseType,_that.badge,_that.isPopular,_that.features,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  SubscriptionPlanType planType,  String title,  String description,  int durationDays,  String durationLabel,  double amount,  String currency,  int deviceLimit,  String licenseType,  String? badge,  bool isPopular,  List<String> features,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionPlan() when $default != null:
return $default(_that.id,_that.planType,_that.title,_that.description,_that.durationDays,_that.durationLabel,_that.amount,_that.currency,_that.deviceLimit,_that.licenseType,_that.badge,_that.isPopular,_that.features,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc


class _SubscriptionPlan implements SubscriptionPlan {
  const _SubscriptionPlan({required this.id, required this.planType, required this.title, required this.description, required this.durationDays, required this.durationLabel, required this.amount, this.currency = 'INR', required this.deviceLimit, required this.licenseType, this.badge, this.isPopular = false, final  List<String> features = const <String>[], this.isActive = true}): _features = features;
  

@override final  String id;
@override final  SubscriptionPlanType planType;
@override final  String title;
@override final  String description;
@override final  int durationDays;
@override final  String durationLabel;
@override final  double amount;
@override@JsonKey() final  String currency;
@override final  int deviceLimit;
@override final  String licenseType;
@override final  String? badge;
@override@JsonKey() final  bool isPopular;
 final  List<String> _features;
@override@JsonKey() List<String> get features {
  if (_features is EqualUnmodifiableListView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_features);
}

@override@JsonKey() final  bool isActive;

/// Create a copy of SubscriptionPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionPlanCopyWith<_SubscriptionPlan> get copyWith => __$SubscriptionPlanCopyWithImpl<_SubscriptionPlan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.durationLabel, durationLabel) || other.durationLabel == durationLabel)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.deviceLimit, deviceLimit) || other.deviceLimit == deviceLimit)&&(identical(other.licenseType, licenseType) || other.licenseType == licenseType)&&(identical(other.badge, badge) || other.badge == badge)&&(identical(other.isPopular, isPopular) || other.isPopular == isPopular)&&const DeepCollectionEquality().equals(other._features, _features)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode => Object.hash(runtimeType,id,planType,title,description,durationDays,durationLabel,amount,currency,deviceLimit,licenseType,badge,isPopular,const DeepCollectionEquality().hash(_features),isActive);

@override
String toString() {
  return 'SubscriptionPlan(id: $id, planType: $planType, title: $title, description: $description, durationDays: $durationDays, durationLabel: $durationLabel, amount: $amount, currency: $currency, deviceLimit: $deviceLimit, licenseType: $licenseType, badge: $badge, isPopular: $isPopular, features: $features, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionPlanCopyWith<$Res> implements $SubscriptionPlanCopyWith<$Res> {
  factory _$SubscriptionPlanCopyWith(_SubscriptionPlan value, $Res Function(_SubscriptionPlan) _then) = __$SubscriptionPlanCopyWithImpl;
@override @useResult
$Res call({
 String id, SubscriptionPlanType planType, String title, String description, int durationDays, String durationLabel, double amount, String currency, int deviceLimit, String licenseType, String? badge, bool isPopular, List<String> features, bool isActive
});




}
/// @nodoc
class __$SubscriptionPlanCopyWithImpl<$Res>
    implements _$SubscriptionPlanCopyWith<$Res> {
  __$SubscriptionPlanCopyWithImpl(this._self, this._then);

  final _SubscriptionPlan _self;
  final $Res Function(_SubscriptionPlan) _then;

/// Create a copy of SubscriptionPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? planType = null,Object? title = null,Object? description = null,Object? durationDays = null,Object? durationLabel = null,Object? amount = null,Object? currency = null,Object? deviceLimit = null,Object? licenseType = null,Object? badge = freezed,Object? isPopular = null,Object? features = null,Object? isActive = null,}) {
  return _then(_SubscriptionPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as SubscriptionPlanType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,durationDays: null == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int,durationLabel: null == durationLabel ? _self.durationLabel : durationLabel // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,deviceLimit: null == deviceLimit ? _self.deviceLimit : deviceLimit // ignore: cast_nullable_to_non_nullable
as int,licenseType: null == licenseType ? _self.licenseType : licenseType // ignore: cast_nullable_to_non_nullable
as String,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String?,isPopular: null == isPopular ? _self.isPopular : isPopular // ignore: cast_nullable_to_non_nullable
as bool,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
