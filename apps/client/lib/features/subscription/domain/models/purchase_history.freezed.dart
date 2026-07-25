// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PurchaseHistory {

 String get id; SubscriptionPlanType get oldPlan; SubscriptionPlanType get newPlan; String get event; Map<String, dynamic>? get metadata; DateTime get createdAt;
/// Create a copy of PurchaseHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseHistoryCopyWith<PurchaseHistory> get copyWith => _$PurchaseHistoryCopyWithImpl<PurchaseHistory>(this as PurchaseHistory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.oldPlan, oldPlan) || other.oldPlan == oldPlan)&&(identical(other.newPlan, newPlan) || other.newPlan == newPlan)&&(identical(other.event, event) || other.event == event)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,oldPlan,newPlan,event,const DeepCollectionEquality().hash(metadata),createdAt);

@override
String toString() {
  return 'PurchaseHistory(id: $id, oldPlan: $oldPlan, newPlan: $newPlan, event: $event, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PurchaseHistoryCopyWith<$Res>  {
  factory $PurchaseHistoryCopyWith(PurchaseHistory value, $Res Function(PurchaseHistory) _then) = _$PurchaseHistoryCopyWithImpl;
@useResult
$Res call({
 String id, SubscriptionPlanType oldPlan, SubscriptionPlanType newPlan, String event, Map<String, dynamic>? metadata, DateTime createdAt
});




}
/// @nodoc
class _$PurchaseHistoryCopyWithImpl<$Res>
    implements $PurchaseHistoryCopyWith<$Res> {
  _$PurchaseHistoryCopyWithImpl(this._self, this._then);

  final PurchaseHistory _self;
  final $Res Function(PurchaseHistory) _then;

/// Create a copy of PurchaseHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? oldPlan = null,Object? newPlan = null,Object? event = null,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,oldPlan: null == oldPlan ? _self.oldPlan : oldPlan // ignore: cast_nullable_to_non_nullable
as SubscriptionPlanType,newPlan: null == newPlan ? _self.newPlan : newPlan // ignore: cast_nullable_to_non_nullable
as SubscriptionPlanType,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseHistory].
extension PurchaseHistoryPatterns on PurchaseHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseHistory value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseHistory value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  SubscriptionPlanType oldPlan,  SubscriptionPlanType newPlan,  String event,  Map<String, dynamic>? metadata,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseHistory() when $default != null:
return $default(_that.id,_that.oldPlan,_that.newPlan,_that.event,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  SubscriptionPlanType oldPlan,  SubscriptionPlanType newPlan,  String event,  Map<String, dynamic>? metadata,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PurchaseHistory():
return $default(_that.id,_that.oldPlan,_that.newPlan,_that.event,_that.metadata,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  SubscriptionPlanType oldPlan,  SubscriptionPlanType newPlan,  String event,  Map<String, dynamic>? metadata,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseHistory() when $default != null:
return $default(_that.id,_that.oldPlan,_that.newPlan,_that.event,_that.metadata,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseHistory implements PurchaseHistory {
  const _PurchaseHistory({required this.id, required this.oldPlan, required this.newPlan, required this.event, final  Map<String, dynamic>? metadata, required this.createdAt}): _metadata = metadata;
  

@override final  String id;
@override final  SubscriptionPlanType oldPlan;
@override final  SubscriptionPlanType newPlan;
@override final  String event;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime createdAt;

/// Create a copy of PurchaseHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseHistoryCopyWith<_PurchaseHistory> get copyWith => __$PurchaseHistoryCopyWithImpl<_PurchaseHistory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.oldPlan, oldPlan) || other.oldPlan == oldPlan)&&(identical(other.newPlan, newPlan) || other.newPlan == newPlan)&&(identical(other.event, event) || other.event == event)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,oldPlan,newPlan,event,const DeepCollectionEquality().hash(_metadata),createdAt);

@override
String toString() {
  return 'PurchaseHistory(id: $id, oldPlan: $oldPlan, newPlan: $newPlan, event: $event, metadata: $metadata, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PurchaseHistoryCopyWith<$Res> implements $PurchaseHistoryCopyWith<$Res> {
  factory _$PurchaseHistoryCopyWith(_PurchaseHistory value, $Res Function(_PurchaseHistory) _then) = __$PurchaseHistoryCopyWithImpl;
@override @useResult
$Res call({
 String id, SubscriptionPlanType oldPlan, SubscriptionPlanType newPlan, String event, Map<String, dynamic>? metadata, DateTime createdAt
});




}
/// @nodoc
class __$PurchaseHistoryCopyWithImpl<$Res>
    implements _$PurchaseHistoryCopyWith<$Res> {
  __$PurchaseHistoryCopyWithImpl(this._self, this._then);

  final _PurchaseHistory _self;
  final $Res Function(_PurchaseHistory) _then;

/// Create a copy of PurchaseHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? oldPlan = null,Object? newPlan = null,Object? event = null,Object? metadata = freezed,Object? createdAt = null,}) {
  return _then(_PurchaseHistory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,oldPlan: null == oldPlan ? _self.oldPlan : oldPlan // ignore: cast_nullable_to_non_nullable
as SubscriptionPlanType,newPlan: null == newPlan ? _self.newPlan : newPlan // ignore: cast_nullable_to_non_nullable
as SubscriptionPlanType,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
