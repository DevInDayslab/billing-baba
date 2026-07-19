// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncStatus {

@JsonKey(name: 'state') CollaborationSyncState get state;@JsonKey(name: 'is_connected') bool get isConnected;@JsonKey(name: 'is_syncing') bool get isSyncing;@JsonKey(name: 'is_enabled') bool get isEnabled;@JsonKey(name: 'last_synced_at') DateTime? get lastSyncedAt;@JsonKey(name: 'pending_uploads') int get pendingUploads;@JsonKey(name: 'pending_downloads') int get pendingDownloads;@JsonKey(name: 'conflict_count') int get conflictCount;@JsonKey(name: 'pending_changes') int get pendingChanges;@JsonKey(name: 'storage_used_mb') double get storageUsedMb;@JsonKey(name: 'storage_total_mb') double get storageTotalMb;@JsonKey(name: 'current_device_name') String get currentDeviceName;@JsonKey(name: 'current_user_phone') String get currentUserPhone;@JsonKey(name: 'error_message') String? get errorMessage;
/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncStatusCopyWith<SyncStatus> get copyWith => _$SyncStatusCopyWithImpl<SyncStatus>(this as SyncStatus, _$identity);

  /// Serializes this SyncStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncStatus&&(identical(other.state, state) || other.state == state)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.isSyncing, isSyncing) || other.isSyncing == isSyncing)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.pendingUploads, pendingUploads) || other.pendingUploads == pendingUploads)&&(identical(other.pendingDownloads, pendingDownloads) || other.pendingDownloads == pendingDownloads)&&(identical(other.conflictCount, conflictCount) || other.conflictCount == conflictCount)&&(identical(other.pendingChanges, pendingChanges) || other.pendingChanges == pendingChanges)&&(identical(other.storageUsedMb, storageUsedMb) || other.storageUsedMb == storageUsedMb)&&(identical(other.storageTotalMb, storageTotalMb) || other.storageTotalMb == storageTotalMb)&&(identical(other.currentDeviceName, currentDeviceName) || other.currentDeviceName == currentDeviceName)&&(identical(other.currentUserPhone, currentUserPhone) || other.currentUserPhone == currentUserPhone)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,isConnected,isSyncing,isEnabled,lastSyncedAt,pendingUploads,pendingDownloads,conflictCount,pendingChanges,storageUsedMb,storageTotalMb,currentDeviceName,currentUserPhone,errorMessage);

@override
String toString() {
  return 'SyncStatus(state: $state, isConnected: $isConnected, isSyncing: $isSyncing, isEnabled: $isEnabled, lastSyncedAt: $lastSyncedAt, pendingUploads: $pendingUploads, pendingDownloads: $pendingDownloads, conflictCount: $conflictCount, pendingChanges: $pendingChanges, storageUsedMb: $storageUsedMb, storageTotalMb: $storageTotalMb, currentDeviceName: $currentDeviceName, currentUserPhone: $currentUserPhone, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $SyncStatusCopyWith<$Res>  {
  factory $SyncStatusCopyWith(SyncStatus value, $Res Function(SyncStatus) _then) = _$SyncStatusCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'state') CollaborationSyncState state,@JsonKey(name: 'is_connected') bool isConnected,@JsonKey(name: 'is_syncing') bool isSyncing,@JsonKey(name: 'is_enabled') bool isEnabled,@JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt,@JsonKey(name: 'pending_uploads') int pendingUploads,@JsonKey(name: 'pending_downloads') int pendingDownloads,@JsonKey(name: 'conflict_count') int conflictCount,@JsonKey(name: 'pending_changes') int pendingChanges,@JsonKey(name: 'storage_used_mb') double storageUsedMb,@JsonKey(name: 'storage_total_mb') double storageTotalMb,@JsonKey(name: 'current_device_name') String currentDeviceName,@JsonKey(name: 'current_user_phone') String currentUserPhone,@JsonKey(name: 'error_message') String? errorMessage
});




}
/// @nodoc
class _$SyncStatusCopyWithImpl<$Res>
    implements $SyncStatusCopyWith<$Res> {
  _$SyncStatusCopyWithImpl(this._self, this._then);

  final SyncStatus _self;
  final $Res Function(SyncStatus) _then;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? state = null,Object? isConnected = null,Object? isSyncing = null,Object? isEnabled = null,Object? lastSyncedAt = freezed,Object? pendingUploads = null,Object? pendingDownloads = null,Object? conflictCount = null,Object? pendingChanges = null,Object? storageUsedMb = null,Object? storageTotalMb = null,Object? currentDeviceName = null,Object? currentUserPhone = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CollaborationSyncState,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,isSyncing: null == isSyncing ? _self.isSyncing : isSyncing // ignore: cast_nullable_to_non_nullable
as bool,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pendingUploads: null == pendingUploads ? _self.pendingUploads : pendingUploads // ignore: cast_nullable_to_non_nullable
as int,pendingDownloads: null == pendingDownloads ? _self.pendingDownloads : pendingDownloads // ignore: cast_nullable_to_non_nullable
as int,conflictCount: null == conflictCount ? _self.conflictCount : conflictCount // ignore: cast_nullable_to_non_nullable
as int,pendingChanges: null == pendingChanges ? _self.pendingChanges : pendingChanges // ignore: cast_nullable_to_non_nullable
as int,storageUsedMb: null == storageUsedMb ? _self.storageUsedMb : storageUsedMb // ignore: cast_nullable_to_non_nullable
as double,storageTotalMb: null == storageTotalMb ? _self.storageTotalMb : storageTotalMb // ignore: cast_nullable_to_non_nullable
as double,currentDeviceName: null == currentDeviceName ? _self.currentDeviceName : currentDeviceName // ignore: cast_nullable_to_non_nullable
as String,currentUserPhone: null == currentUserPhone ? _self.currentUserPhone : currentUserPhone // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncStatus].
extension SyncStatusPatterns on SyncStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncStatus value)  $default,){
final _that = this;
switch (_that) {
case _SyncStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SyncStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'state')  CollaborationSyncState state, @JsonKey(name: 'is_connected')  bool isConnected, @JsonKey(name: 'is_syncing')  bool isSyncing, @JsonKey(name: 'is_enabled')  bool isEnabled, @JsonKey(name: 'last_synced_at')  DateTime? lastSyncedAt, @JsonKey(name: 'pending_uploads')  int pendingUploads, @JsonKey(name: 'pending_downloads')  int pendingDownloads, @JsonKey(name: 'conflict_count')  int conflictCount, @JsonKey(name: 'pending_changes')  int pendingChanges, @JsonKey(name: 'storage_used_mb')  double storageUsedMb, @JsonKey(name: 'storage_total_mb')  double storageTotalMb, @JsonKey(name: 'current_device_name')  String currentDeviceName, @JsonKey(name: 'current_user_phone')  String currentUserPhone, @JsonKey(name: 'error_message')  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncStatus() when $default != null:
return $default(_that.state,_that.isConnected,_that.isSyncing,_that.isEnabled,_that.lastSyncedAt,_that.pendingUploads,_that.pendingDownloads,_that.conflictCount,_that.pendingChanges,_that.storageUsedMb,_that.storageTotalMb,_that.currentDeviceName,_that.currentUserPhone,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'state')  CollaborationSyncState state, @JsonKey(name: 'is_connected')  bool isConnected, @JsonKey(name: 'is_syncing')  bool isSyncing, @JsonKey(name: 'is_enabled')  bool isEnabled, @JsonKey(name: 'last_synced_at')  DateTime? lastSyncedAt, @JsonKey(name: 'pending_uploads')  int pendingUploads, @JsonKey(name: 'pending_downloads')  int pendingDownloads, @JsonKey(name: 'conflict_count')  int conflictCount, @JsonKey(name: 'pending_changes')  int pendingChanges, @JsonKey(name: 'storage_used_mb')  double storageUsedMb, @JsonKey(name: 'storage_total_mb')  double storageTotalMb, @JsonKey(name: 'current_device_name')  String currentDeviceName, @JsonKey(name: 'current_user_phone')  String currentUserPhone, @JsonKey(name: 'error_message')  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SyncStatus():
return $default(_that.state,_that.isConnected,_that.isSyncing,_that.isEnabled,_that.lastSyncedAt,_that.pendingUploads,_that.pendingDownloads,_that.conflictCount,_that.pendingChanges,_that.storageUsedMb,_that.storageTotalMb,_that.currentDeviceName,_that.currentUserPhone,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'state')  CollaborationSyncState state, @JsonKey(name: 'is_connected')  bool isConnected, @JsonKey(name: 'is_syncing')  bool isSyncing, @JsonKey(name: 'is_enabled')  bool isEnabled, @JsonKey(name: 'last_synced_at')  DateTime? lastSyncedAt, @JsonKey(name: 'pending_uploads')  int pendingUploads, @JsonKey(name: 'pending_downloads')  int pendingDownloads, @JsonKey(name: 'conflict_count')  int conflictCount, @JsonKey(name: 'pending_changes')  int pendingChanges, @JsonKey(name: 'storage_used_mb')  double storageUsedMb, @JsonKey(name: 'storage_total_mb')  double storageTotalMb, @JsonKey(name: 'current_device_name')  String currentDeviceName, @JsonKey(name: 'current_user_phone')  String currentUserPhone, @JsonKey(name: 'error_message')  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SyncStatus() when $default != null:
return $default(_that.state,_that.isConnected,_that.isSyncing,_that.isEnabled,_that.lastSyncedAt,_that.pendingUploads,_that.pendingDownloads,_that.conflictCount,_that.pendingChanges,_that.storageUsedMb,_that.storageTotalMb,_that.currentDeviceName,_that.currentUserPhone,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncStatus implements SyncStatus {
  const _SyncStatus({@JsonKey(name: 'state') this.state = CollaborationSyncState.enabled, @JsonKey(name: 'is_connected') this.isConnected = true, @JsonKey(name: 'is_syncing') this.isSyncing = false, @JsonKey(name: 'is_enabled') this.isEnabled = true, @JsonKey(name: 'last_synced_at') this.lastSyncedAt, @JsonKey(name: 'pending_uploads') this.pendingUploads = 0, @JsonKey(name: 'pending_downloads') this.pendingDownloads = 0, @JsonKey(name: 'conflict_count') this.conflictCount = 0, @JsonKey(name: 'pending_changes') this.pendingChanges = 0, @JsonKey(name: 'storage_used_mb') this.storageUsedMb = 0, @JsonKey(name: 'storage_total_mb') this.storageTotalMb = 1024, @JsonKey(name: 'current_device_name') this.currentDeviceName = 'Desktop', @JsonKey(name: 'current_user_phone') this.currentUserPhone = '', @JsonKey(name: 'error_message') this.errorMessage});
  factory _SyncStatus.fromJson(Map<String, dynamic> json) => _$SyncStatusFromJson(json);

@override@JsonKey(name: 'state') final  CollaborationSyncState state;
@override@JsonKey(name: 'is_connected') final  bool isConnected;
@override@JsonKey(name: 'is_syncing') final  bool isSyncing;
@override@JsonKey(name: 'is_enabled') final  bool isEnabled;
@override@JsonKey(name: 'last_synced_at') final  DateTime? lastSyncedAt;
@override@JsonKey(name: 'pending_uploads') final  int pendingUploads;
@override@JsonKey(name: 'pending_downloads') final  int pendingDownloads;
@override@JsonKey(name: 'conflict_count') final  int conflictCount;
@override@JsonKey(name: 'pending_changes') final  int pendingChanges;
@override@JsonKey(name: 'storage_used_mb') final  double storageUsedMb;
@override@JsonKey(name: 'storage_total_mb') final  double storageTotalMb;
@override@JsonKey(name: 'current_device_name') final  String currentDeviceName;
@override@JsonKey(name: 'current_user_phone') final  String currentUserPhone;
@override@JsonKey(name: 'error_message') final  String? errorMessage;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncStatusCopyWith<_SyncStatus> get copyWith => __$SyncStatusCopyWithImpl<_SyncStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncStatus&&(identical(other.state, state) || other.state == state)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.isSyncing, isSyncing) || other.isSyncing == isSyncing)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.pendingUploads, pendingUploads) || other.pendingUploads == pendingUploads)&&(identical(other.pendingDownloads, pendingDownloads) || other.pendingDownloads == pendingDownloads)&&(identical(other.conflictCount, conflictCount) || other.conflictCount == conflictCount)&&(identical(other.pendingChanges, pendingChanges) || other.pendingChanges == pendingChanges)&&(identical(other.storageUsedMb, storageUsedMb) || other.storageUsedMb == storageUsedMb)&&(identical(other.storageTotalMb, storageTotalMb) || other.storageTotalMb == storageTotalMb)&&(identical(other.currentDeviceName, currentDeviceName) || other.currentDeviceName == currentDeviceName)&&(identical(other.currentUserPhone, currentUserPhone) || other.currentUserPhone == currentUserPhone)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,isConnected,isSyncing,isEnabled,lastSyncedAt,pendingUploads,pendingDownloads,conflictCount,pendingChanges,storageUsedMb,storageTotalMb,currentDeviceName,currentUserPhone,errorMessage);

@override
String toString() {
  return 'SyncStatus(state: $state, isConnected: $isConnected, isSyncing: $isSyncing, isEnabled: $isEnabled, lastSyncedAt: $lastSyncedAt, pendingUploads: $pendingUploads, pendingDownloads: $pendingDownloads, conflictCount: $conflictCount, pendingChanges: $pendingChanges, storageUsedMb: $storageUsedMb, storageTotalMb: $storageTotalMb, currentDeviceName: $currentDeviceName, currentUserPhone: $currentUserPhone, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SyncStatusCopyWith<$Res> implements $SyncStatusCopyWith<$Res> {
  factory _$SyncStatusCopyWith(_SyncStatus value, $Res Function(_SyncStatus) _then) = __$SyncStatusCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'state') CollaborationSyncState state,@JsonKey(name: 'is_connected') bool isConnected,@JsonKey(name: 'is_syncing') bool isSyncing,@JsonKey(name: 'is_enabled') bool isEnabled,@JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt,@JsonKey(name: 'pending_uploads') int pendingUploads,@JsonKey(name: 'pending_downloads') int pendingDownloads,@JsonKey(name: 'conflict_count') int conflictCount,@JsonKey(name: 'pending_changes') int pendingChanges,@JsonKey(name: 'storage_used_mb') double storageUsedMb,@JsonKey(name: 'storage_total_mb') double storageTotalMb,@JsonKey(name: 'current_device_name') String currentDeviceName,@JsonKey(name: 'current_user_phone') String currentUserPhone,@JsonKey(name: 'error_message') String? errorMessage
});




}
/// @nodoc
class __$SyncStatusCopyWithImpl<$Res>
    implements _$SyncStatusCopyWith<$Res> {
  __$SyncStatusCopyWithImpl(this._self, this._then);

  final _SyncStatus _self;
  final $Res Function(_SyncStatus) _then;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? state = null,Object? isConnected = null,Object? isSyncing = null,Object? isEnabled = null,Object? lastSyncedAt = freezed,Object? pendingUploads = null,Object? pendingDownloads = null,Object? conflictCount = null,Object? pendingChanges = null,Object? storageUsedMb = null,Object? storageTotalMb = null,Object? currentDeviceName = null,Object? currentUserPhone = null,Object? errorMessage = freezed,}) {
  return _then(_SyncStatus(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CollaborationSyncState,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,isSyncing: null == isSyncing ? _self.isSyncing : isSyncing // ignore: cast_nullable_to_non_nullable
as bool,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pendingUploads: null == pendingUploads ? _self.pendingUploads : pendingUploads // ignore: cast_nullable_to_non_nullable
as int,pendingDownloads: null == pendingDownloads ? _self.pendingDownloads : pendingDownloads // ignore: cast_nullable_to_non_nullable
as int,conflictCount: null == conflictCount ? _self.conflictCount : conflictCount // ignore: cast_nullable_to_non_nullable
as int,pendingChanges: null == pendingChanges ? _self.pendingChanges : pendingChanges // ignore: cast_nullable_to_non_nullable
as int,storageUsedMb: null == storageUsedMb ? _self.storageUsedMb : storageUsedMb // ignore: cast_nullable_to_non_nullable
as double,storageTotalMb: null == storageTotalMb ? _self.storageTotalMb : storageTotalMb // ignore: cast_nullable_to_non_nullable
as double,currentDeviceName: null == currentDeviceName ? _self.currentDeviceName : currentDeviceName // ignore: cast_nullable_to_non_nullable
as String,currentUserPhone: null == currentUserPhone ? _self.currentUserPhone : currentUserPhone // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
