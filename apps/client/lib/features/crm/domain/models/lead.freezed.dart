// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Lead {

 String get id;@JsonKey(name: 'business_id') String get businessId; String get name;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'created_at') DateTime get createdAt; String? get company; String? get phone; String? get email;@JsonKey(name: 'lead_source') LeadSource? get leadSource; LeadStatus get status;@JsonKey(name: 'assigned_to') String? get assignedTo; String? get notes;@JsonKey(name: 'sync_version') int get syncVersion;@JsonKey(name: 'is_deleted') bool get isDeleted;@JsonKey(name: 'deleted_at') DateTime? get deletedAt;@JsonKey(name: 'device_id') String get deviceId;@JsonKey(name: 'sync_status') String get syncStatus;
/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeadCopyWith<Lead> get copyWith => _$LeadCopyWithImpl<Lead>(this as Lead, _$identity);

  /// Serializes this Lead to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lead&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.name, name) || other.name == name)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.company, company) || other.company == company)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.leadSource, leadSource) || other.leadSource == leadSource)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.syncVersion, syncVersion) || other.syncVersion == syncVersion)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,name,updatedAt,createdAt,company,phone,email,leadSource,status,assignedTo,notes,syncVersion,isDeleted,deletedAt,deviceId,syncStatus);

@override
String toString() {
  return 'Lead(id: $id, businessId: $businessId, name: $name, updatedAt: $updatedAt, createdAt: $createdAt, company: $company, phone: $phone, email: $email, leadSource: $leadSource, status: $status, assignedTo: $assignedTo, notes: $notes, syncVersion: $syncVersion, isDeleted: $isDeleted, deletedAt: $deletedAt, deviceId: $deviceId, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $LeadCopyWith<$Res>  {
  factory $LeadCopyWith(Lead value, $Res Function(Lead) _then) = _$LeadCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'business_id') String businessId, String name,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'created_at') DateTime createdAt, String? company, String? phone, String? email,@JsonKey(name: 'lead_source') LeadSource? leadSource, LeadStatus status,@JsonKey(name: 'assigned_to') String? assignedTo, String? notes,@JsonKey(name: 'sync_version') int syncVersion,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'deleted_at') DateTime? deletedAt,@JsonKey(name: 'device_id') String deviceId,@JsonKey(name: 'sync_status') String syncStatus
});




}
/// @nodoc
class _$LeadCopyWithImpl<$Res>
    implements $LeadCopyWith<$Res> {
  _$LeadCopyWithImpl(this._self, this._then);

  final Lead _self;
  final $Res Function(Lead) _then;

/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessId = null,Object? name = null,Object? updatedAt = null,Object? createdAt = null,Object? company = freezed,Object? phone = freezed,Object? email = freezed,Object? leadSource = freezed,Object? status = null,Object? assignedTo = freezed,Object? notes = freezed,Object? syncVersion = null,Object? isDeleted = null,Object? deletedAt = freezed,Object? deviceId = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,leadSource: freezed == leadSource ? _self.leadSource : leadSource // ignore: cast_nullable_to_non_nullable
as LeadSource?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LeadStatus,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,syncVersion: null == syncVersion ? _self.syncVersion : syncVersion // ignore: cast_nullable_to_non_nullable
as int,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Lead].
extension LeadPatterns on Lead {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lead value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lead() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lead value)  $default,){
final _that = this;
switch (_that) {
case _Lead():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lead value)?  $default,){
final _that = this;
switch (_that) {
case _Lead() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'business_id')  String businessId,  String name, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'created_at')  DateTime createdAt,  String? company,  String? phone,  String? email, @JsonKey(name: 'lead_source')  LeadSource? leadSource,  LeadStatus status, @JsonKey(name: 'assigned_to')  String? assignedTo,  String? notes, @JsonKey(name: 'sync_version')  int syncVersion, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'device_id')  String deviceId, @JsonKey(name: 'sync_status')  String syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lead() when $default != null:
return $default(_that.id,_that.businessId,_that.name,_that.updatedAt,_that.createdAt,_that.company,_that.phone,_that.email,_that.leadSource,_that.status,_that.assignedTo,_that.notes,_that.syncVersion,_that.isDeleted,_that.deletedAt,_that.deviceId,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'business_id')  String businessId,  String name, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'created_at')  DateTime createdAt,  String? company,  String? phone,  String? email, @JsonKey(name: 'lead_source')  LeadSource? leadSource,  LeadStatus status, @JsonKey(name: 'assigned_to')  String? assignedTo,  String? notes, @JsonKey(name: 'sync_version')  int syncVersion, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'device_id')  String deviceId, @JsonKey(name: 'sync_status')  String syncStatus)  $default,) {final _that = this;
switch (_that) {
case _Lead():
return $default(_that.id,_that.businessId,_that.name,_that.updatedAt,_that.createdAt,_that.company,_that.phone,_that.email,_that.leadSource,_that.status,_that.assignedTo,_that.notes,_that.syncVersion,_that.isDeleted,_that.deletedAt,_that.deviceId,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'business_id')  String businessId,  String name, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'created_at')  DateTime createdAt,  String? company,  String? phone,  String? email, @JsonKey(name: 'lead_source')  LeadSource? leadSource,  LeadStatus status, @JsonKey(name: 'assigned_to')  String? assignedTo,  String? notes, @JsonKey(name: 'sync_version')  int syncVersion, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'deleted_at')  DateTime? deletedAt, @JsonKey(name: 'device_id')  String deviceId, @JsonKey(name: 'sync_status')  String syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _Lead() when $default != null:
return $default(_that.id,_that.businessId,_that.name,_that.updatedAt,_that.createdAt,_that.company,_that.phone,_that.email,_that.leadSource,_that.status,_that.assignedTo,_that.notes,_that.syncVersion,_that.isDeleted,_that.deletedAt,_that.deviceId,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Lead implements Lead {
  const _Lead({required this.id, @JsonKey(name: 'business_id') required this.businessId, required this.name, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'created_at') required this.createdAt, this.company, this.phone, this.email, @JsonKey(name: 'lead_source') this.leadSource, this.status = LeadStatus.newLead, @JsonKey(name: 'assigned_to') this.assignedTo, this.notes, @JsonKey(name: 'sync_version') this.syncVersion = 1, @JsonKey(name: 'is_deleted') this.isDeleted = false, @JsonKey(name: 'deleted_at') this.deletedAt, @JsonKey(name: 'device_id') this.deviceId = '', @JsonKey(name: 'sync_status') this.syncStatus = 'pending'});
  factory _Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);

@override final  String id;
@override@JsonKey(name: 'business_id') final  String businessId;
@override final  String name;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override final  String? company;
@override final  String? phone;
@override final  String? email;
@override@JsonKey(name: 'lead_source') final  LeadSource? leadSource;
@override@JsonKey() final  LeadStatus status;
@override@JsonKey(name: 'assigned_to') final  String? assignedTo;
@override final  String? notes;
@override@JsonKey(name: 'sync_version') final  int syncVersion;
@override@JsonKey(name: 'is_deleted') final  bool isDeleted;
@override@JsonKey(name: 'deleted_at') final  DateTime? deletedAt;
@override@JsonKey(name: 'device_id') final  String deviceId;
@override@JsonKey(name: 'sync_status') final  String syncStatus;

/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeadCopyWith<_Lead> get copyWith => __$LeadCopyWithImpl<_Lead>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lead&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.name, name) || other.name == name)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.company, company) || other.company == company)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.leadSource, leadSource) || other.leadSource == leadSource)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.syncVersion, syncVersion) || other.syncVersion == syncVersion)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,name,updatedAt,createdAt,company,phone,email,leadSource,status,assignedTo,notes,syncVersion,isDeleted,deletedAt,deviceId,syncStatus);

@override
String toString() {
  return 'Lead(id: $id, businessId: $businessId, name: $name, updatedAt: $updatedAt, createdAt: $createdAt, company: $company, phone: $phone, email: $email, leadSource: $leadSource, status: $status, assignedTo: $assignedTo, notes: $notes, syncVersion: $syncVersion, isDeleted: $isDeleted, deletedAt: $deletedAt, deviceId: $deviceId, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$LeadCopyWith<$Res> implements $LeadCopyWith<$Res> {
  factory _$LeadCopyWith(_Lead value, $Res Function(_Lead) _then) = __$LeadCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'business_id') String businessId, String name,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'created_at') DateTime createdAt, String? company, String? phone, String? email,@JsonKey(name: 'lead_source') LeadSource? leadSource, LeadStatus status,@JsonKey(name: 'assigned_to') String? assignedTo, String? notes,@JsonKey(name: 'sync_version') int syncVersion,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'deleted_at') DateTime? deletedAt,@JsonKey(name: 'device_id') String deviceId,@JsonKey(name: 'sync_status') String syncStatus
});




}
/// @nodoc
class __$LeadCopyWithImpl<$Res>
    implements _$LeadCopyWith<$Res> {
  __$LeadCopyWithImpl(this._self, this._then);

  final _Lead _self;
  final $Res Function(_Lead) _then;

/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessId = null,Object? name = null,Object? updatedAt = null,Object? createdAt = null,Object? company = freezed,Object? phone = freezed,Object? email = freezed,Object? leadSource = freezed,Object? status = null,Object? assignedTo = freezed,Object? notes = freezed,Object? syncVersion = null,Object? isDeleted = null,Object? deletedAt = freezed,Object? deviceId = null,Object? syncStatus = null,}) {
  return _then(_Lead(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,leadSource: freezed == leadSource ? _self.leadSource : leadSource // ignore: cast_nullable_to_non_nullable
as LeadSource?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LeadStatus,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,syncVersion: null == syncVersion ? _self.syncVersion : syncVersion // ignore: cast_nullable_to_non_nullable
as int,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
