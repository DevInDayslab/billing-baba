import 'package:freezed_annotation/freezed_annotation.dart';

part 'connected_device.freezed.dart';
part 'connected_device.g.dart';

enum DevicePlatform {
  @JsonValue('desktop')
  desktop,
  @JsonValue('macos')
  macos,
  @JsonValue('windows')
  windows,
  @JsonValue('android')
  android,
  @JsonValue('web')
  web,
}

extension DevicePlatformX on DevicePlatform {
  String get displayLabel => switch (this) {
    DevicePlatform.desktop => 'Desktop',
    DevicePlatform.macos => 'MacBook',
    DevicePlatform.windows => 'Windows',
    DevicePlatform.android => 'Android',
    DevicePlatform.web => 'Web',
  };
}

enum DeviceSyncStatus {
  @JsonValue('synced')
  synced,
  @JsonValue('syncing')
  syncing,
  @JsonValue('offline')
  offline,
  @JsonValue('pending')
  pending,
}

extension DeviceSyncStatusX on DeviceSyncStatus {
  String get displayLabel => switch (this) {
    DeviceSyncStatus.synced => 'Synced',
    DeviceSyncStatus.syncing => 'Syncing',
    DeviceSyncStatus.offline => 'Offline',
    DeviceSyncStatus.pending => 'Pending',
  };
}

@freezed
abstract class ConnectedDevice with _$ConnectedDevice {
  const factory ConnectedDevice({
    required String id,
    required String name,
    required DevicePlatform platform,
    @JsonKey(name: 'os_name') required String osName,
    @JsonKey(name: 'app_version') required String appVersion,
    @JsonKey(name: 'last_seen_at') required DateTime lastSeenAt,
    @JsonKey(name: 'is_current_device') @Default(false) bool isCurrentDevice,
    @JsonKey(name: 'is_online') @Default(true) bool isOnline,
    @JsonKey(name: 'sync_status') required DeviceSyncStatus deviceSyncStatus,
  }) = _ConnectedDevice;

  factory ConnectedDevice.fromJson(Map<String, dynamic> json) =>
      _$ConnectedDeviceFromJson(json);
}

extension ConnectedDeviceX on ConnectedDevice {
  String get platformLabel => platform.displayLabel;

  String get onlineLabel => isOnline ? 'Online' : 'Offline';
}
