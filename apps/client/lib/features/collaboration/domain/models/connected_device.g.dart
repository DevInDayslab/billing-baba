// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connected_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConnectedDevice _$ConnectedDeviceFromJson(Map<String, dynamic> json) =>
    _ConnectedDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      platform: $enumDecode(_$DevicePlatformEnumMap, json['platform']),
      osName: json['os_name'] as String,
      appVersion: json['app_version'] as String,
      lastSeenAt: DateTime.parse(json['last_seen_at'] as String),
      isCurrentDevice: json['is_current_device'] as bool? ?? false,
      isOnline: json['is_online'] as bool? ?? true,
      deviceSyncStatus: $enumDecode(
        _$DeviceSyncStatusEnumMap,
        json['sync_status'],
      ),
    );

Map<String, dynamic> _$ConnectedDeviceToJson(_ConnectedDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'platform': _$DevicePlatformEnumMap[instance.platform]!,
      'os_name': instance.osName,
      'app_version': instance.appVersion,
      'last_seen_at': instance.lastSeenAt.toIso8601String(),
      'is_current_device': instance.isCurrentDevice,
      'is_online': instance.isOnline,
      'sync_status': _$DeviceSyncStatusEnumMap[instance.deviceSyncStatus]!,
    };

const _$DevicePlatformEnumMap = {
  DevicePlatform.desktop: 'desktop',
  DevicePlatform.macos: 'macos',
  DevicePlatform.windows: 'windows',
  DevicePlatform.android: 'android',
  DevicePlatform.web: 'web',
};

const _$DeviceSyncStatusEnumMap = {
  DeviceSyncStatus.synced: 'synced',
  DeviceSyncStatus.syncing: 'syncing',
  DeviceSyncStatus.offline: 'offline',
  DeviceSyncStatus.pending: 'pending',
};
