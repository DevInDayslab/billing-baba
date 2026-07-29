import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

/// Resolves stable device id + app version for sync transport headers.
///
/// Persists [StorageKeys.syncDeviceId] for the install lifetime.
class SyncDeviceIdentity {
  SyncDeviceIdentity(
    this._storage, {
    Uuid? uuid,
    Future<PackageInfo> Function()? packageInfoLoader,
    String? Function()? platformName,
  })  : _uuid = uuid ?? const Uuid(),
        _packageInfoLoader =
            packageInfoLoader ?? PackageInfo.fromPlatform,
        _platformName = platformName ?? _defaultPlatformName;

  final StorageService _storage;
  final Uuid _uuid;
  final Future<PackageInfo> Function() _packageInfoLoader;
  final String? Function() _platformName;

  Future<String> deviceId() async {
    final existing = _storage.read(StorageKeys.syncDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _uuid.v4();
    await _storage.write(StorageKeys.syncDeviceId, id);
    return id;
  }

  Future<String> appVersion() async {
    final info = await _packageInfoLoader();
    return info.version;
  }

  String platform() => _platformName() ?? 'unknown';

  String deviceName() => 'Billing Baba (${platform()})';

  static String _defaultPlatformName() {
    final os = AppPlatform.current.os;
    return switch (os) {
      OperatingSystem.windows => 'windows',
      OperatingSystem.macOS => 'macos',
      OperatingSystem.linux => 'linux',
      OperatingSystem.android => 'android',
      OperatingSystem.ios => 'ios',
    };
  }
}
