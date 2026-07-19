import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_status.freezed.dart';
part 'sync_status.g.dart';

enum CollaborationSyncState {
  @JsonValue('enabled')
  enabled,
  @JsonValue('disabled')
  disabled,
  @JsonValue('syncing')
  syncing,
  @JsonValue('offline')
  offline,
  @JsonValue('error')
  error,
}

extension CollaborationSyncStateX on CollaborationSyncState {
  String get displayLabel => switch (this) {
    CollaborationSyncState.enabled => 'Sync Enabled',
    CollaborationSyncState.disabled => 'Sync Disabled',
    CollaborationSyncState.syncing => 'Syncing',
    CollaborationSyncState.offline => 'Offline',
    CollaborationSyncState.error => 'Error',
  };
}

@freezed
abstract class SyncStatus with _$SyncStatus {
  const factory SyncStatus({
    @JsonKey(name: 'state')
    @Default(CollaborationSyncState.enabled)
    CollaborationSyncState state,
    @JsonKey(name: 'is_connected') @Default(true) bool isConnected,
    @JsonKey(name: 'is_syncing') @Default(false) bool isSyncing,
    @JsonKey(name: 'is_enabled') @Default(true) bool isEnabled,
    @JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt,
    @JsonKey(name: 'pending_uploads') @Default(0) int pendingUploads,
    @JsonKey(name: 'pending_downloads') @Default(0) int pendingDownloads,
    @JsonKey(name: 'conflict_count') @Default(0) int conflictCount,
    @JsonKey(name: 'pending_changes') @Default(0) int pendingChanges,
    @JsonKey(name: 'storage_used_mb') @Default(0) double storageUsedMb,
    @JsonKey(name: 'storage_total_mb') @Default(1024) double storageTotalMb,
    @JsonKey(name: 'current_device_name')
    @Default('Desktop')
    String currentDeviceName,
    @JsonKey(name: 'current_user_phone') @Default('') String currentUserPhone,
    @JsonKey(name: 'error_message') String? errorMessage,
  }) = _SyncStatus;

  factory SyncStatus.fromJson(Map<String, dynamic> json) =>
      _$SyncStatusFromJson(json);
}

extension SyncStatusX on SyncStatus {
  bool get isOffline => state == CollaborationSyncState.offline || !isConnected;

  bool get isDisabled => state == CollaborationSyncState.disabled || !isEnabled;

  bool get hasError => state == CollaborationSyncState.error;
}
