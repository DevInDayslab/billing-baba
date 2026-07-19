// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncStatus _$SyncStatusFromJson(Map<String, dynamic> json) => _SyncStatus(
  state:
      $enumDecodeNullable(_$CollaborationSyncStateEnumMap, json['state']) ??
      CollaborationSyncState.enabled,
  isConnected: json['is_connected'] as bool? ?? true,
  isSyncing: json['is_syncing'] as bool? ?? false,
  isEnabled: json['is_enabled'] as bool? ?? true,
  lastSyncedAt: json['last_synced_at'] == null
      ? null
      : DateTime.parse(json['last_synced_at'] as String),
  pendingUploads: (json['pending_uploads'] as num?)?.toInt() ?? 0,
  pendingDownloads: (json['pending_downloads'] as num?)?.toInt() ?? 0,
  conflictCount: (json['conflict_count'] as num?)?.toInt() ?? 0,
  pendingChanges: (json['pending_changes'] as num?)?.toInt() ?? 0,
  storageUsedMb: (json['storage_used_mb'] as num?)?.toDouble() ?? 0,
  storageTotalMb: (json['storage_total_mb'] as num?)?.toDouble() ?? 1024,
  currentDeviceName: json['current_device_name'] as String? ?? 'Desktop',
  currentUserPhone: json['current_user_phone'] as String? ?? '',
  errorMessage: json['error_message'] as String?,
);

Map<String, dynamic> _$SyncStatusToJson(_SyncStatus instance) =>
    <String, dynamic>{
      'state': _$CollaborationSyncStateEnumMap[instance.state]!,
      'is_connected': instance.isConnected,
      'is_syncing': instance.isSyncing,
      'is_enabled': instance.isEnabled,
      'last_synced_at': instance.lastSyncedAt?.toIso8601String(),
      'pending_uploads': instance.pendingUploads,
      'pending_downloads': instance.pendingDownloads,
      'conflict_count': instance.conflictCount,
      'pending_changes': instance.pendingChanges,
      'storage_used_mb': instance.storageUsedMb,
      'storage_total_mb': instance.storageTotalMb,
      'current_device_name': instance.currentDeviceName,
      'current_user_phone': instance.currentUserPhone,
      'error_message': instance.errorMessage,
    };

const _$CollaborationSyncStateEnumMap = {
  CollaborationSyncState.enabled: 'enabled',
  CollaborationSyncState.disabled: 'disabled',
  CollaborationSyncState.syncing: 'syncing',
  CollaborationSyncState.offline: 'offline',
  CollaborationSyncState.error: 'error',
};
