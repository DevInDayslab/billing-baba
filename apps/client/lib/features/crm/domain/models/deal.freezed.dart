// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Deal {

 String get id;@JsonKey(name: 'business_id') String get businessId; String get name; DealStage get stage;@JsonKey(name: 'account_name') String? get accountName;@JsonKey(name: 'assigned_to') String? get assignedTo; double get amount;@JsonKey(name: 'expected_close_date') DateTime? get expectedCloseDate; String? get description;@JsonKey(name: 'sync_version') int get syncVersion;@JsonKey(name: 'is_deleted') bool get isDeleted;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'deleted_at') DateTime? get deletedAt;@JsonKey(name: 'device_id') String get deviceId;@JsonKey(name: 'sync_status') String get syncStatus;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of Deal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DealCopyWith<Deal> get copyWith => _$DealCopyWithImpl<Deal>(this as Deal, _$identity);

  /// Serializes this Deal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Deal&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.name, name) || other.name == name)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.expectedCloseDate, expectedCloseDate) || other.expectedCloseDate == expectedCloseDate)&&(identical(other.description, description) || other.description == description)&&(identical(other.syncVersion, syncVersion) || other.syncVersion == syncVersion)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,name,stage,accountName,assignedTo,amount,expectedCloseDate,description,syncVersion,isDeleted,updatedAt,deletedAt,deviceId,syncStatus,createdAt);

@override
String toString() {
  return 'Deal(id: $id, businessId: $businessId, name: $name, stage: $stage, accountName: $accountName, assignedTo: $assignedTo, amount: $amount, expectedCloseDate: $expectedCloseDate, description: $description, syncVersion: $syncVersion, isDeleted: $isDeleted, updatedAt: $updatedAt, deletedAt: $deletedAt, deviceId: $deviceId, syncStatus: $syncStatus, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DealCopyWith<$Res>  {
  factory $DealCopyWith(Deal value, $Res Function(Deal) _then) = _$DealCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'business_id') String businessId, String name, DealStage stage,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'assigned_to') String? assignedTo, double amount,@JsonKey(name: 'expected_close_date') DateTime? expectedCloseDate, String? description,@JsonKey(name: 'sync_version') int syncVersion,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'deleted_at') DateTime? deletedAt,@JsonKey(name: 'device_id') String deviceId,@JsonKey(name: 'sync_status') String syncStatus,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$DealCopyWithImpl<$Res>
    implements $DealCopyWith<$Res> {
  _$DealCopyWithImpl(this._self, this._then);

  final Deal _self;
  final $Res Function(Deal) _then;

/// Create a copy of Deal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessId = null,Object? name = null,Object? stage = null,Object? accountName = freezed,Object? assignedTo = freezed,Object? amount = null,Object? expectedCloseDate = freezed,Object? description = freezed,Object? syncVersion = null,Object? isDeleted = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? deviceId = null,Object? syncStatus = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as DealStage,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,expectedCloseDate: freezed == expectedCloseDate ? _self.expectedCloseDate : expectedCloseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,syncVersion: null == syncVersion ? _self.syncVersion : syncVersion // ignore: cast_nullable_to_non_nullable
as int,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Deal].
extension DealPatterns on Deal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Deal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Deal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Deal value)  $default,){
final _that = this;
switch (_that) {
case _Deal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Deal value)?  $default,){
final _that = this;
switch (_that) {
case _Deal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'business_id')  String businessId,  String name,  DealStage stage, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'assigned_to')  String? assignedTo,  double amount, @JsonKey(name: 'expected_close_date')  DateTime? expectedCloseDate,  String? description, @JsonKey(name: 'sync_version')  int syncVersion, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'device_id')  String deviceId, @JsonKey(name: 'sync_status')  String syncStatus, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Deal() when $default != null:
return $default(_that.id,_that.businessId,_that.name,_that.stage,_that.accountName,_that.assignedTo,_that.amount,_that.expectedCloseDate,_that.description,_that.syncVersion,_that.isDeleted,_that.updatedAt,_that.deletedAt,_that.deviceId,_that.syncStatus,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'business_id')  String businessId,  String name,  DealStage stage, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'assigned_to')  String? assignedTo,  double amount, @JsonKey(name: 'expected_close_date')  DateTime? expectedCloseDate,  String? description, @JsonKey(name: 'sync_version')  int syncVersion, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'device_id')  String deviceId, @JsonKey(name: 'sync_status')  String syncStatus, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Deal():
return $default(_that.id,_that.businessId,_that.name,_that.stage,_that.accountName,_that.assignedTo,_that.amount,_that.expectedCloseDate,_that.description,_that.syncVersion,_that.isDeleted,_that.updatedAt,_that.deletedAt,_that.deviceId,_that.syncStatus,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'business_id')  String businessId,  String name,  DealStage stage, @JsonKey(name: 'account_name')  String? accountName, @JsonKey(name: 'assigned_to')  String? assignedTo,  double amount, @JsonKey(name: 'expected_close_date')  DateTime? expectedCloseDate,  String? description, @JsonKey(name: 'sync_version')  int syncVersion, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'device_id')  String deviceId, @JsonKey(name: 'sync_status')  String syncStatus, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Deal() when $default != null:
return $default(_that.id,_that.businessId,_that.name,_that.stage,_that.accountName,_that.assignedTo,_that.amount,_that.expectedCloseDate,_that.description,_that.syncVersion,_that.isDeleted,_that.updatedAt,_that.deletedAt,_that.deviceId,_that.syncStatus,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Deal implements Deal {
  const _Deal({required this.id, @JsonKey(name: 'business_id') required this.businessId, required this.name, this.stage = DealStage.qualification, @JsonKey(name: 'account_name') this.accountName, @JsonKey(name: 'assigned_to') this.assignedTo, this.amount = 0, @JsonKey(name: 'expected_close_date') this.expectedCloseDate, this.description, @JsonKey(name: 'sync_version') this.syncVersion = 1, @JsonKey(name: 'is_deleted') this.isDeleted = false, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'deleted_at') this.deletedAt, @JsonKey(name: 'device_id') this.deviceId = '', @JsonKey(name: 'sync_status') this.syncStatus = 'pending', @JsonKey(name: 'created_at') required this.createdAt});
  factory _Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);

@override final  String id;
@override@JsonKey(name: 'business_id') final  String businessId;
@override final  String name;
@override@JsonKey() final  DealStage stage;
@override@JsonKey(name: 'account_name') final  String? accountName;
@override@JsonKey(name: 'assigned_to') final  String? assignedTo;
@override@JsonKey() final  double amount;
@override@JsonKey(name: 'expected_close_date') final  DateTime? expectedCloseDate;
@override final  String? description;
@override@JsonKey(name: 'sync_version') final  int syncVersion;
@override@JsonKey(name: 'is_deleted') final  bool isDeleted;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'deleted_at') final  DateTime? deletedAt;
@override@JsonKey(name: 'device_id') final  String deviceId;
@override@JsonKey(name: 'sync_status') final  String syncStatus;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of Deal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DealCopyWith<_Deal> get copyWith => __$DealCopyWithImpl<_Deal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DealToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Deal&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.name, name) || other.name == name)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.expectedCloseDate, expectedCloseDate) || other.expectedCloseDate == expectedCloseDate)&&(identical(other.description, description) || other.description == description)&&(identical(other.syncVersion, syncVersion) || other.syncVersion == syncVersion)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,name,stage,accountName,assignedTo,amount,expectedCloseDate,description,syncVersion,isDeleted,updatedAt,deletedAt,deviceId,syncStatus,createdAt);

@override
String toString() {
  return 'Deal(id: $id, businessId: $businessId, name: $name, stage: $stage, accountName: $accountName, assignedTo: $assignedTo, amount: $amount, expectedCloseDate: $expectedCloseDate, description: $description, syncVersion: $syncVersion, isDeleted: $isDeleted, updatedAt: $updatedAt, deletedAt: $deletedAt, deviceId: $deviceId, syncStatus: $syncStatus, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DealCopyWith<$Res> implements $DealCopyWith<$Res> {
  factory _$DealCopyWith(_Deal value, $Res Function(_Deal) _then) = __$DealCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'business_id') String businessId, String name, DealStage stage,@JsonKey(name: 'account_name') String? accountName,@JsonKey(name: 'assigned_to') String? assignedTo, double amount,@JsonKey(name: 'expected_close_date') DateTime? expectedCloseDate, String? description,@JsonKey(name: 'sync_version') int syncVersion,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'deleted_at') DateTime? deletedAt,@JsonKey(name: 'device_id') String deviceId,@JsonKey(name: 'sync_status') String syncStatus,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$DealCopyWithImpl<$Res>
    implements _$DealCopyWith<$Res> {
  __$DealCopyWithImpl(this._self, this._then);

  final _Deal _self;
  final $Res Function(_Deal) _then;

/// Create a copy of Deal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessId = null,Object? name = null,Object? stage = null,Object? accountName = freezed,Object? assignedTo = freezed,Object? amount = null,Object? expectedCloseDate = freezed,Object? description = freezed,Object? syncVersion = null,Object? isDeleted = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? deviceId = null,Object? syncStatus = null,Object? createdAt = null,}) {
  return _then(_Deal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as DealStage,accountName: freezed == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String?,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,expectedCloseDate: freezed == expectedCloseDate ? _self.expectedCloseDate : expectedCloseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,syncVersion: null == syncVersion ? _self.syncVersion : syncVersion // ignore: cast_nullable_to_non_nullable
as int,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
