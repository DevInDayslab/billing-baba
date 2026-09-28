import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Resolves [API_BASE_URL] for the current platform and device type.
///
/// - Android emulator: `127.0.0.1` / `localhost` → `10.0.2.2` (host loopback).
/// - Physical Android over USB: keep `127.0.0.1` and run
///   `adb reverse tcp:3000 tcp:3000` so the phone tunnels to the host API.
/// - iOS simulator / desktop: `127.0.0.1` / `localhost` unchanged.
/// - Physical devices on Wi‑Fi: use your machine's LAN IP in `.env`
///   (e.g. `http://192.168.1.5:3000`).
abstract final class ApiBaseUrlResolver {
  static const _androidEmulatorHost = '10.0.2.2';
  static const _loopbackHosts = {'localhost', '127.0.0.1', '0.0.0.0'};

  /// Platform-aware URL after [resolve] has run.
  static String? _cachedResolvedUrl;
  static String? _cachedRewriteNote;
  static String? _cachedDeviceKind;

  static String? get rewriteNote => _cachedRewriteNote;
  static String? get deviceKind => _cachedDeviceKind;

  /// Resolves and caches the API base URL. Call once after `dotenv.load()`.
  static Future<String> resolve(String configuredUrl) async {
    if (_cachedResolvedUrl != null) return _cachedResolvedUrl!;

    final normalizedUrl = _ensureScheme(configuredUrl);
    final uri = Uri.parse(normalizedUrl);
    final host = uri.host.toLowerCase();
    _cachedDeviceKind = await _detectDeviceKind();

    if (!_loopbackHosts.contains(host)) {
      _cachedResolvedUrl = normalizedUrl;
      _cachedRewriteNote = null;
      return normalizedUrl;
    }

    final platform = AppPlatform.current;
    if (platform.isAndroid) {
      final isEmulator = _cachedDeviceKind == 'android-emulator';
      if (isEmulator) {
        final resolved = uri.replace(host: _androidEmulatorHost).toString();
        _cachedResolvedUrl = _trimTrailingSlash(resolved);
        _cachedRewriteNote =
            'loopback → $_androidEmulatorHost (Android emulator)';
        return _cachedResolvedUrl!;
      }
      _cachedResolvedUrl = normalizedUrl;
      _cachedRewriteNote =
          'loopback on physical Android — use adb reverse tcp:3000 tcp:3000 '
          'or set API_BASE_URL to your host LAN IP';
      return normalizedUrl;
    }

    if (platform.isIOS && _cachedDeviceKind == 'ios-physical') {
      _cachedResolvedUrl = normalizedUrl;
      _cachedRewriteNote =
          'loopback on physical iOS — set API_BASE_URL to your host LAN IP';
      return normalizedUrl;
    }

    _cachedResolvedUrl = normalizedUrl;
    _cachedRewriteNote = null;
    return normalizedUrl;
  }

  static Future<String> _detectDeviceKind() async {
    if (kIsWeb) return 'web';
    final platform = AppPlatform.current;
    if (platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.isPhysicalDevice ? 'android-physical' : 'android-emulator';
    }
    if (platform.isIOS) {
      final info = await DeviceInfoPlugin().iosInfo;
      return info.isPhysicalDevice ? 'ios-physical' : 'ios-simulator';
    }
    if (platform.isWindows) return 'windows-desktop';
    if (platform.isMacOS) return 'macos-desktop';
    if (platform.isLinux) return 'linux-desktop';
    return 'unknown';
  }

  static String _trimTrailingSlash(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Dio requires a scheme on non-web platforms; bare hostnames are common in `.env`.
  static String _ensureScheme(String configuredUrl) {
    final trimmed = configuredUrl.trim();
    if (trimmed.isEmpty || trimmed.contains('://')) return trimmed;

    final lower = trimmed.toLowerCase();
    final useHttp =
        lower.startsWith('localhost') ||
        lower.startsWith('127.0.0.1') ||
        lower.startsWith('0.0.0.0') ||
        lower.startsWith('10.') ||
        lower.startsWith('192.168.');
    return '${useHttp ? 'http' : 'https'}://$trimmed';
  }
}
