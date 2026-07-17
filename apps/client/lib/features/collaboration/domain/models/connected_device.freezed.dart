// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connected_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConnectedDevice {

 String get id; String get name; DevicePlatform get platform;@JsonKey(name: 'os_name') String get osName;@JsonKey(name: 'app_version') String get appVersion;@JsonKey(name: 'last_seen_at') DateTime get lastSeenAt;@JsonKey(name: 'is_current_device') bool get isCurrentDevice;@JsonKey(name: 'is_online') bool get isOnline;@JsonKey(name: 'sync_status') DeviceSyncStatus get deviceSyncStatus;
/// Create a copy of ConnectedDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectedDeviceCopyWith<ConnectedDevice> get copyWith => _$ConnectedDeviceCopyWithImpl<ConnectedDevice>(this as ConnectedDevice, _$identity);

  /// Serializes this ConnectedDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectedDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.osName, osName) || other.osName == osName)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.isCurrentDevice, isCurrentDevice) || other.isCurrentDevice == isCurrentDevice)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.deviceSyncStatus, deviceSyncStatus) || other.deviceSyncStatus == deviceSyncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,platform,osName,appVersion,lastSeenAt,isCurrentDevice,isOnline,deviceSyncStatus);

@override
String toString() {
  return 'ConnectedDevice(id: $id, name: $name, platform: $platform, osName: $osName, appVersion: $appVersion, lastSeenAt: $lastSeenAt, isCurrentDevice: $isCurrentDevice, isOnline: $isOnline, deviceSyncStatus: $deviceSyncStatus)';
}


}

/// @nodoc
abstract mixin class $ConnectedDeviceCopyWith<$Res>  {
  factory $ConnectedDeviceCopyWith(ConnectedDevice value, $Res Function(ConnectedDevice) _then) = _$ConnectedDeviceCopyWithImpl;
@useResult
$Res call({
 String id, String name, DevicePlatform platform,@JsonKey(name: 'os_name') String osName,@JsonKey(name: 'app_version') String appVersion,@JsonKey(name: 'last_seen_at') DateTime lastSeenAt,@JsonKey(name: 'is_current_device') bool isCurrentDevice,@JsonKey(name: 'is_online') bool isOnline,@JsonKey(name: 'sync_status') DeviceSyncStatus deviceSyncStatus
});




}
/// @nodoc
class _$ConnectedDeviceCopyWithImpl<$Res>
    implements $ConnectedDeviceCopyWith<$Res> {
  _$ConnectedDeviceCopyWithImpl(this._self, this._then);

  final ConnectedDevice _self;
  final $Res Function(ConnectedDevice) _then;

/// Create a copy of ConnectedDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? platform = null,Object? osName = null,Object? appVersion = null,Object? lastSeenAt = null,Object? isCurrentDevice = null,Object? isOnline = null,Object? deviceSyncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as DevicePlatform,osName: null == osName ? _self.osName : osName // ignore: cast_nullable_to_non_nullable
as String,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,isCurrentDevice: null == isCurrentDevice ? _self.isCurrentDevice : isCurrentDevice // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,deviceSyncStatus: null == deviceSyncStatus ? _self.deviceSyncStatus : deviceSyncStatus // ignore: cast_nullable_to_non_nullable
as DeviceSyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [ConnectedDevice].
extension ConnectedDevicePatterns on ConnectedDevice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectedDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectedDevice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectedDevice value)  $default,){
final _that = this;
switch (_that) {
case _ConnectedDevice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectedDevice value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectedDevice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DevicePlatform platform, @JsonKey(name: 'os_name')  String osName, @JsonKey(name: 'app_version')  String appVersion, @JsonKey(name: 'last_seen_at')  DateTime lastSeenAt, @JsonKey(name: 'is_current_device')  bool isCurrentDevice, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'sync_status')  DeviceSyncStatus deviceSyncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectedDevice() when $default != null:
return $default(_that.id,_that.name,_that.platform,_that.osName,_that.appVersion,_that.lastSeenAt,_that.isCurrentDevice,_that.isOnline,_that.deviceSyncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DevicePlatform platform, @JsonKey(name: 'os_name')  String osName, @JsonKey(name: 'app_version')  String appVersion, @JsonKey(name: 'last_seen_at')  DateTime lastSeenAt, @JsonKey(name: 'is_current_device')  bool isCurrentDevice, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'sync_status')  DeviceSyncStatus deviceSyncStatus)  $default,) {final _that = this;
switch (_that) {
case _ConnectedDevice():
return $default(_that.id,_that.name,_that.platform,_that.osName,_that.appVersion,_that.lastSeenAt,_that.isCurrentDevice,_that.isOnline,_that.deviceSyncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DevicePlatform platform, @JsonKey(name: 'os_name')  String osName, @JsonKey(name: 'app_version')  String appVersion, @JsonKey(name: 'last_seen_at')  DateTime lastSeenAt, @JsonKey(name: 'is_current_device')  bool isCurrentDevice, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'sync_status')  DeviceSyncStatus deviceSyncStatus)?  $default,) {final _that = this;
switch (_that) {
case _ConnectedDevice() when $default != null:
return $default(_that.id,_that.name,_that.platform,_that.osName,_that.appVersion,_that.lastSeenAt,_that.isCurrentDevice,_that.isOnline,_that.deviceSyncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConnectedDevice implements ConnectedDevice {
  const _ConnectedDevice({required this.id, required this.name, required this.platform, @JsonKey(name: 'os_name') required this.osName, @JsonKey(name: 'app_version') required this.appVersion, @JsonKey(name: 'last_seen_at') required this.lastSeenAt, @JsonKey(name: 'is_current_device') this.isCurrentDevice = false, @JsonKey(name: 'is_online') this.isOnline = true, @JsonKey(name: 'sync_status') required this.deviceSyncStatus});
  factory _ConnectedDevice.fromJson(Map<String, dynamic> json) => _$ConnectedDeviceFromJson(json);

@override final  String id;
@override final  String name;
@override final  DevicePlatform platform;
@override@JsonKey(name: 'os_name') final  String osName;
@override@JsonKey(name: 'app_version') final  String appVersion;
@override@JsonKey(name: 'last_seen_at') final  DateTime lastSeenAt;
@override@JsonKey(name: 'is_current_device') final  bool isCurrentDevice;
@override@JsonKey(name: 'is_online') final  bool isOnline;
@override@JsonKey(name: 'sync_status') final  DeviceSyncStatus deviceSyncStatus;

/// Create a copy of ConnectedDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectedDeviceCopyWith<_ConnectedDevice> get copyWith => __$ConnectedDeviceCopyWithImpl<_ConnectedDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectedDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectedDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.osName, osName) || other.osName == osName)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.isCurrentDevice, isCurrentDevice) || other.isCurrentDevice == isCurrentDevice)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.deviceSyncStatus, deviceSyncStatus) || other.deviceSyncStatus == deviceSyncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,platform,osName,appVersion,lastSeenAt,isCurrentDevice,isOnline,deviceSyncStatus);

@override
String toString() {
  return 'ConnectedDevice(id: $id, name: $name, platform: $platform, osName: $osName, appVersion: $appVersion, lastSeenAt: $lastSeenAt, isCurrentDevice: $isCurrentDevice, isOnline: $isOnline, deviceSyncStatus: $deviceSyncStatus)';
}


}

/// @nodoc
abstract mixin class _$ConnectedDeviceCopyWith<$Res> implements $ConnectedDeviceCopyWith<$Res> {
  factory _$ConnectedDeviceCopyWith(_ConnectedDevice value, $Res Function(_ConnectedDevice) _then) = __$ConnectedDeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DevicePlatform platform,@JsonKey(name: 'os_name') String osName,@JsonKey(name: 'app_version') String appVersion,@JsonKey(name: 'last_seen_at') DateTime lastSeenAt,@JsonKey(name: 'is_current_device') bool isCurrentDevice,@JsonKey(name: 'is_online') bool isOnline,@JsonKey(name: 'sync_status') DeviceSyncStatus deviceSyncStatus
});




}
/// @nodoc
class __$ConnectedDeviceCopyWithImpl<$Res>
    implements _$ConnectedDeviceCopyWith<$Res> {
  __$ConnectedDeviceCopyWithImpl(this._self, this._then);

  final _ConnectedDevice _self;
  final $Res Function(_ConnectedDevice) _then;

/// Create a copy of ConnectedDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? platform = null,Object? osName = null,Object? appVersion = null,Object? lastSeenAt = null,Object? isCurrentDevice = null,Object? isOnline = null,Object? deviceSyncStatus = null,}) {
  return _then(_ConnectedDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as DevicePlatform,osName: null == osName ? _self.osName : osName // ignore: cast_nullable_to_non_nullable
as String,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,isCurrentDevice: null == isCurrentDevice ? _self.isCurrentDevice : isCurrentDevice // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,deviceSyncStatus: null == deviceSyncStatus ? _self.deviceSyncStatus : deviceSyncStatus // ignore: cast_nullable_to_non_nullable
as DeviceSyncStatus,
  ));
}


}

// dart format on
