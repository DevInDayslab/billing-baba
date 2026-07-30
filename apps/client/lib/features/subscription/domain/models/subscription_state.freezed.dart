// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubscriptionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscriptionState()';
}


}

/// @nodoc
class $SubscriptionStateCopyWith<$Res>  {
$SubscriptionStateCopyWith(SubscriptionState _, $Res Function(SubscriptionState) __);
}


/// Adds pattern-matching-related methods to [SubscriptionState].
extension SubscriptionStatePatterns on SubscriptionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SubscriptionStateLoading value)?  loading,TResult Function( SubscriptionStateRefreshing value)?  refreshing,TResult Function( SubscriptionStateLoaded value)?  loaded,TResult Function( SubscriptionStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SubscriptionStateLoading() when loading != null:
return loading(_that);case SubscriptionStateRefreshing() when refreshing != null:
return refreshing(_that);case SubscriptionStateLoaded() when loaded != null:
return loaded(_that);case SubscriptionStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SubscriptionStateLoading value)  loading,required TResult Function( SubscriptionStateRefreshing value)  refreshing,required TResult Function( SubscriptionStateLoaded value)  loaded,required TResult Function( SubscriptionStateError value)  error,}){
final _that = this;
switch (_that) {
case SubscriptionStateLoading():
return loading(_that);case SubscriptionStateRefreshing():
return refreshing(_that);case SubscriptionStateLoaded():
return loaded(_that);case SubscriptionStateError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SubscriptionStateLoading value)?  loading,TResult? Function( SubscriptionStateRefreshing value)?  refreshing,TResult? Function( SubscriptionStateLoaded value)?  loaded,TResult? Function( SubscriptionStateError value)?  error,}){
final _that = this;
switch (_that) {
case SubscriptionStateLoading() when loading != null:
return loading(_that);case SubscriptionStateRefreshing() when refreshing != null:
return refreshing(_that);case SubscriptionStateLoaded() when loaded != null:
return loaded(_that);case SubscriptionStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<SubscriptionPlan> plans,  CurrentSubscription current,  List<PurchaseHistory> history)?  refreshing,TResult Function( List<SubscriptionPlan> plans,  CurrentSubscription current,  List<PurchaseHistory> history)?  loaded,TResult Function( String message,  List<SubscriptionPlan>? plans,  CurrentSubscription? current,  List<PurchaseHistory>? history)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SubscriptionStateLoading() when loading != null:
return loading();case SubscriptionStateRefreshing() when refreshing != null:
return refreshing(_that.plans,_that.current,_that.history);case SubscriptionStateLoaded() when loaded != null:
return loaded(_that.plans,_that.current,_that.history);case SubscriptionStateError() when error != null:
return error(_that.message,_that.plans,_that.current,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<SubscriptionPlan> plans,  CurrentSubscription current,  List<PurchaseHistory> history)  refreshing,required TResult Function( List<SubscriptionPlan> plans,  CurrentSubscription current,  List<PurchaseHistory> history)  loaded,required TResult Function( String message,  List<SubscriptionPlan>? plans,  CurrentSubscription? current,  List<PurchaseHistory>? history)  error,}) {final _that = this;
switch (_that) {
case SubscriptionStateLoading():
return loading();case SubscriptionStateRefreshing():
return refreshing(_that.plans,_that.current,_that.history);case SubscriptionStateLoaded():
return loaded(_that.plans,_that.current,_that.history);case SubscriptionStateError():
return error(_that.message,_that.plans,_that.current,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<SubscriptionPlan> plans,  CurrentSubscription current,  List<PurchaseHistory> history)?  refreshing,TResult? Function( List<SubscriptionPlan> plans,  CurrentSubscription current,  List<PurchaseHistory> history)?  loaded,TResult? Function( String message,  List<SubscriptionPlan>? plans,  CurrentSubscription? current,  List<PurchaseHistory>? history)?  error,}) {final _that = this;
switch (_that) {
case SubscriptionStateLoading() when loading != null:
return loading();case SubscriptionStateRefreshing() when refreshing != null:
return refreshing(_that.plans,_that.current,_that.history);case SubscriptionStateLoaded() when loaded != null:
return loaded(_that.plans,_that.current,_that.history);case SubscriptionStateError() when error != null:
return error(_that.message,_that.plans,_that.current,_that.history);case _:
  return null;

}
}

}

/// @nodoc


class SubscriptionStateLoading extends SubscriptionState {
  const SubscriptionStateLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscriptionState.loading()';
}


}




/// @nodoc


class SubscriptionStateRefreshing extends SubscriptionState {
  const SubscriptionStateRefreshing({required final  List<SubscriptionPlan> plans, required this.current, required final  List<PurchaseHistory> history}): _plans = plans,_history = history,super._();
  

 final  List<SubscriptionPlan> _plans;
 List<SubscriptionPlan> get plans {
  if (_plans is EqualUnmodifiableListView) return _plans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plans);
}

 final  CurrentSubscription current;
 final  List<PurchaseHistory> _history;
 List<PurchaseHistory> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionStateRefreshingCopyWith<SubscriptionStateRefreshing> get copyWith => _$SubscriptionStateRefreshingCopyWithImpl<SubscriptionStateRefreshing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionStateRefreshing&&const DeepCollectionEquality().equals(other._plans, _plans)&&(identical(other.current, current) || other.current == current)&&const DeepCollectionEquality().equals(other._history, _history));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_plans),current,const DeepCollectionEquality().hash(_history));

@override
String toString() {
  return 'SubscriptionState.refreshing(plans: $plans, current: $current, history: $history)';
}


}

/// @nodoc
abstract mixin class $SubscriptionStateRefreshingCopyWith<$Res> implements $SubscriptionStateCopyWith<$Res> {
  factory $SubscriptionStateRefreshingCopyWith(SubscriptionStateRefreshing value, $Res Function(SubscriptionStateRefreshing) _then) = _$SubscriptionStateRefreshingCopyWithImpl;
@useResult
$Res call({
 List<SubscriptionPlan> plans, CurrentSubscription current, List<PurchaseHistory> history
});


$CurrentSubscriptionCopyWith<$Res> get current;

}
/// @nodoc
class _$SubscriptionStateRefreshingCopyWithImpl<$Res>
    implements $SubscriptionStateRefreshingCopyWith<$Res> {
  _$SubscriptionStateRefreshingCopyWithImpl(this._self, this._then);

  final SubscriptionStateRefreshing _self;
  final $Res Function(SubscriptionStateRefreshing) _then;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? plans = null,Object? current = null,Object? history = null,}) {
  return _then(SubscriptionStateRefreshing(
plans: null == plans ? _self._plans : plans // ignore: cast_nullable_to_non_nullable
as List<SubscriptionPlan>,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as CurrentSubscription,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<PurchaseHistory>,
  ));
}

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrentSubscriptionCopyWith<$Res> get current {
  
  return $CurrentSubscriptionCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}
}

/// @nodoc


class SubscriptionStateLoaded extends SubscriptionState {
  const SubscriptionStateLoaded({required final  List<SubscriptionPlan> plans, required this.current, required final  List<PurchaseHistory> history}): _plans = plans,_history = history,super._();
  

 final  List<SubscriptionPlan> _plans;
 List<SubscriptionPlan> get plans {
  if (_plans is EqualUnmodifiableListView) return _plans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plans);
}

 final  CurrentSubscription current;
 final  List<PurchaseHistory> _history;
 List<PurchaseHistory> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionStateLoadedCopyWith<SubscriptionStateLoaded> get copyWith => _$SubscriptionStateLoadedCopyWithImpl<SubscriptionStateLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionStateLoaded&&const DeepCollectionEquality().equals(other._plans, _plans)&&(identical(other.current, current) || other.current == current)&&const DeepCollectionEquality().equals(other._history, _history));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_plans),current,const DeepCollectionEquality().hash(_history));

@override
String toString() {
  return 'SubscriptionState.loaded(plans: $plans, current: $current, history: $history)';
}


}

/// @nodoc
abstract mixin class $SubscriptionStateLoadedCopyWith<$Res> implements $SubscriptionStateCopyWith<$Res> {
  factory $SubscriptionStateLoadedCopyWith(SubscriptionStateLoaded value, $Res Function(SubscriptionStateLoaded) _then) = _$SubscriptionStateLoadedCopyWithImpl;
@useResult
$Res call({
 List<SubscriptionPlan> plans, CurrentSubscription current, List<PurchaseHistory> history
});


$CurrentSubscriptionCopyWith<$Res> get current;

}
/// @nodoc
class _$SubscriptionStateLoadedCopyWithImpl<$Res>
    implements $SubscriptionStateLoadedCopyWith<$Res> {
  _$SubscriptionStateLoadedCopyWithImpl(this._self, this._then);

  final SubscriptionStateLoaded _self;
  final $Res Function(SubscriptionStateLoaded) _then;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? plans = null,Object? current = null,Object? history = null,}) {
  return _then(SubscriptionStateLoaded(
plans: null == plans ? _self._plans : plans // ignore: cast_nullable_to_non_nullable
as List<SubscriptionPlan>,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as CurrentSubscription,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<PurchaseHistory>,
  ));
}

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrentSubscriptionCopyWith<$Res> get current {
  
  return $CurrentSubscriptionCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}
}

/// @nodoc


class SubscriptionStateError extends SubscriptionState {
  const SubscriptionStateError({required this.message, final  List<SubscriptionPlan>? plans, this.current, final  List<PurchaseHistory>? history}): _plans = plans,_history = history,super._();
  

 final  String message;
 final  List<SubscriptionPlan>? _plans;
 List<SubscriptionPlan>? get plans {
  final value = _plans;
  if (value == null) return null;
  if (_plans is EqualUnmodifiableListView) return _plans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  CurrentSubscription? current;
 final  List<PurchaseHistory>? _history;
 List<PurchaseHistory>? get history {
  final value = _history;
  if (value == null) return null;
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionStateErrorCopyWith<SubscriptionStateError> get copyWith => _$SubscriptionStateErrorCopyWithImpl<SubscriptionStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionStateError&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._plans, _plans)&&(identical(other.current, current) || other.current == current)&&const DeepCollectionEquality().equals(other._history, _history));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(_plans),current,const DeepCollectionEquality().hash(_history));

@override
String toString() {
  return 'SubscriptionState.error(message: $message, plans: $plans, current: $current, history: $history)';
}


}

/// @nodoc
abstract mixin class $SubscriptionStateErrorCopyWith<$Res> implements $SubscriptionStateCopyWith<$Res> {
  factory $SubscriptionStateErrorCopyWith(SubscriptionStateError value, $Res Function(SubscriptionStateError) _then) = _$SubscriptionStateErrorCopyWithImpl;
@useResult
$Res call({
 String message, List<SubscriptionPlan>? plans, CurrentSubscription? current, List<PurchaseHistory>? history
});


$CurrentSubscriptionCopyWith<$Res>? get current;

}
/// @nodoc
class _$SubscriptionStateErrorCopyWithImpl<$Res>
    implements $SubscriptionStateErrorCopyWith<$Res> {
  _$SubscriptionStateErrorCopyWithImpl(this._self, this._then);

  final SubscriptionStateError _self;
  final $Res Function(SubscriptionStateError) _then;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? plans = freezed,Object? current = freezed,Object? history = freezed,}) {
  return _then(SubscriptionStateError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,plans: freezed == plans ? _self._plans : plans // ignore: cast_nullable_to_non_nullable
as List<SubscriptionPlan>?,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as CurrentSubscription?,history: freezed == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<PurchaseHistory>?,
  ));
}

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrentSubscriptionCopyWith<$Res>? get current {
    if (_self.current == null) {
    return null;
  }

  return $CurrentSubscriptionCopyWith<$Res>(_self.current!, (value) {
    return _then(_self.copyWith(current: value));
  });
}
}

// dart format on
