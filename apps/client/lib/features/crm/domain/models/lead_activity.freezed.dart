// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeadActivity {

 String get id;@JsonKey(name: 'lead_id') String get leadId;@JsonKey(name: 'business_id') String get businessId; LeadActivityType get type; String? get notes;@JsonKey(name: 'added_by') String? get addedBy;@JsonKey(name: 'sync_version') int get syncVersion;@JsonKey(name: 'is_deleted') bool get isDeleted;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'deleted_at') DateTime? get deletedAt;@JsonKey(name: 'device_id') String get deviceId;@JsonKey(name: 'sync_status') String get syncStatus;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of LeadActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeadActivityCopyWith<LeadActivity> get copyWith => _$LeadActivityCopyWithImpl<LeadActivity>(this as LeadActivity, _$identity);

  /// Serializes this LeadActivity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeadActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.leadId, leadId) || other.leadId == leadId)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.type, type) || other.type == type)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.addedBy, addedBy) || other.addedBy == addedBy)&&(identical(other.syncVersion, syncVersion) || other.syncVersion == syncVersion)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,leadId,businessId,type,notes,addedBy,syncVersion,isDeleted,updatedAt,deletedAt,deviceId,syncStatus,createdAt);

@override
String toString() {
  return 'LeadActivity(id: $id, leadId: $leadId, businessId: $businessId, type: $type, notes: $notes, addedBy: $addedBy, syncVersion: $syncVersion, isDeleted: $isDeleted, updatedAt: $updatedAt, deletedAt: $deletedAt, deviceId: $deviceId, syncStatus: $syncStatus, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $LeadActivityCopyWith<$Res>  {
  factory $LeadActivityCopyWith(LeadActivity value, $Res Function(LeadActivity) _then) = _$LeadActivityCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'lead_id') String leadId,@JsonKey(name: 'business_id') String businessId, LeadActivityType type, String? notes,@JsonKey(name: 'added_by') String? addedBy,@JsonKey(name: 'sync_version') int syncVersion,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'deleted_at') DateTime? deletedAt,@JsonKey(name: 'device_id') String deviceId,@JsonKey(name: 'sync_status') String syncStatus,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$LeadActivityCopyWithImpl<$Res>
    implements $LeadActivityCopyWith<$Res> {
  _$LeadActivityCopyWithImpl(this._self, this._then);

  final LeadActivity _self;
  final $Res Function(LeadActivity) _then;

/// Create a copy of LeadActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? leadId = null,Object? businessId = null,Object? type = null,Object? notes = freezed,Object? addedBy = freezed,Object? syncVersion = null,Object? isDeleted = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? deviceId = null,Object? syncStatus = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,leadId: null == leadId ? _self.leadId : leadId // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LeadActivityType,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,addedBy: freezed == addedBy ? _self.addedBy : addedBy // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [LeadActivity].
extension LeadActivityPatterns on LeadActivity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeadActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeadActivity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeadActivity value)  $default,){
final _that = this;
switch (_that) {
case _LeadActivity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeadActivity value)?  $default,){
final _that = this;
switch (_that) {
case _LeadActivity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'lead_id')  String leadId, @JsonKey(name: 'business_id')  String businessId,  LeadActivityType type,  String? notes, @JsonKey(name: 'added_by')  String? addedBy, @JsonKey(name: 'sync_version')  int syncVersion, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'device_id')  String deviceId, @JsonKey(name: 'sync_status')  String syncStatus, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeadActivity() when $default != null:
return $default(_that.id,_that.leadId,_that.businessId,_that.type,_that.notes,_that.addedBy,_that.syncVersion,_that.isDeleted,_that.updatedAt,_that.deletedAt,_that.deviceId,_that.syncStatus,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'lead_id')  String leadId, @JsonKey(name: 'business_id')  String businessId,  LeadActivityType type,  String? notes, @JsonKey(name: 'added_by')  String? addedBy, @JsonKey(name: 'sync_version')  int syncVersion, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'device_id')  String deviceId, @JsonKey(name: 'sync_status')  String syncStatus, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _LeadActivity():
return $default(_that.id,_that.leadId,_that.businessId,_that.type,_that.notes,_that.addedBy,_that.syncVersion,_that.isDeleted,_that.updatedAt,_that.deletedAt,_that.deviceId,_that.syncStatus,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'lead_id')  String leadId, @JsonKey(name: 'business_id')  String businessId,  LeadActivityType type,  String? notes, @JsonKey(name: 'added_by')  String? addedBy, @JsonKey(name: 'sync_version')  int syncVersion, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'device_id')  String deviceId, @JsonKey(name: 'sync_status')  String syncStatus, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LeadActivity() when $default != null:
return $default(_that.id,_that.leadId,_that.businessId,_that.type,_that.notes,_that.addedBy,_that.syncVersion,_that.isDeleted,_that.updatedAt,_that.deletedAt,_that.deviceId,_that.syncStatus,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeadActivity implements LeadActivity {
  const _LeadActivity({required this.id, @JsonKey(name: 'lead_id') required this.leadId, @JsonKey(name: 'business_id') required this.businessId, required this.type, this.notes, @JsonKey(name: 'added_by') this.addedBy, @JsonKey(name: 'sync_version') this.syncVersion = 1, @JsonKey(name: 'is_deleted') this.isDeleted = false, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'deleted_at') this.deletedAt, @JsonKey(name: 'device_id') this.deviceId = '', @JsonKey(name: 'sync_status') this.syncStatus = 'pending', @JsonKey(name: 'created_at') required this.createdAt});
  factory _LeadActivity.fromJson(Map<String, dynamic> json) => _$LeadActivityFromJson(json);

@override final  String id;
@override@JsonKey(name: 'lead_id') final  String leadId;
@override@JsonKey(name: 'business_id') final  String businessId;
@override final  LeadActivityType type;
@override final  String? notes;
@override@JsonKey(name: 'added_by') final  String? addedBy;
@override@JsonKey(name: 'sync_version') final  int syncVersion;
@override@JsonKey(name: 'is_deleted') final  bool isDeleted;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'deleted_at') final  DateTime? deletedAt;
@override@JsonKey(name: 'device_id') final  String deviceId;
@override@JsonKey(name: 'sync_status') final  String syncStatus;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of LeadActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeadActivityCopyWith<_LeadActivity> get copyWith => __$LeadActivityCopyWithImpl<_LeadActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeadActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeadActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.leadId, leadId) || other.leadId == leadId)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.type, type) || other.type == type)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.addedBy, addedBy) || other.addedBy == addedBy)&&(identical(other.syncVersion, syncVersion) || other.syncVersion == syncVersion)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,leadId,businessId,type,notes,addedBy,syncVersion,isDeleted,updatedAt,deletedAt,deviceId,syncStatus,createdAt);

@override
String toString() {
  return 'LeadActivity(id: $id, leadId: $leadId, businessId: $businessId, type: $type, notes: $notes, addedBy: $addedBy, syncVersion: $syncVersion, isDeleted: $isDeleted, updatedAt: $updatedAt, deletedAt: $deletedAt, deviceId: $deviceId, syncStatus: $syncStatus, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LeadActivityCopyWith<$Res> implements $LeadActivityCopyWith<$Res> {
  factory _$LeadActivityCopyWith(_LeadActivity value, $Res Function(_LeadActivity) _then) = __$LeadActivityCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'lead_id') String leadId,@JsonKey(name: 'business_id') String businessId, LeadActivityType type, String? notes,@JsonKey(name: 'added_by') String? addedBy,@JsonKey(name: 'sync_version') int syncVersion,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'deleted_at') DateTime? deletedAt,@JsonKey(name: 'device_id') String deviceId,@JsonKey(name: 'sync_status') String syncStatus,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$LeadActivityCopyWithImpl<$Res>
    implements _$LeadActivityCopyWith<$Res> {
  __$LeadActivityCopyWithImpl(this._self, this._then);

  final _LeadActivity _self;
  final $Res Function(_LeadActivity) _then;

/// Create a copy of LeadActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? leadId = null,Object? businessId = null,Object? type = null,Object? notes = freezed,Object? addedBy = freezed,Object? syncVersion = null,Object? isDeleted = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? deviceId = null,Object? syncStatus = null,Object? createdAt = null,}) {
  return _then(_LeadActivity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,leadId: null == leadId ? _self.leadId : leadId // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LeadActivityType,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,addedBy: freezed == addedBy ? _self.addedBy : addedBy // ignore: cast_nullable_to_non_nullable
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
