import 'dart:io' show InternetAddress, Platform;

import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Collects device and build metadata for startup diagnostics.
abstract final class DeviceInfoCollector {
  static Future<DeviceInfoSnapshot> collect() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    var platform = 'Unknown';
    var operatingSystem = 'Unknown';
    var windowsVersion = '';
    var cpuArchitecture = '';

    if (kIsWeb) {
      platform = 'Web';
      operatingSystem = 'Web';
    } else {
      platform = _platformName();
      final details = await _nativeDetails(deviceInfo);
      operatingSystem = details.operatingSystem;
      windowsVersion = details.windowsVersion;
      cpuArchitecture = details.cpuArchitecture;
    }

    return DeviceInfoSnapshot(
      platform: platform,
      operatingSystem: operatingSystem,
      windowsVersion: windowsVersion,
      cpuArchitecture: cpuArchitecture,
      flutterVersion: kIsWeb ? 'Web' : _flutterVersionLabel(),
      buildVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
      appName: packageInfo.appName,
    );
  }

  static String _platformName() {
    final platform = AppPlatform.current;
    if (platform.isWindows) return 'Windows';
    if (platform.isMacOS) return 'macOS';
    if (platform.isLinux) return 'Linux';
    if (platform.isAndroid) return 'Android';
    if (platform.isIOS) return 'iOS';
    return 'Unknown';
  }

  static Future<_NativeDetails> _nativeDetails(DeviceInfoPlugin deviceInfo) async {
    final platform = AppPlatform.current;
    if (platform.isWindows) {
      final info = await deviceInfo.windowsInfo;
      return _NativeDetails(
        operatingSystem: 'Windows ${info.majorVersion}.${info.minorVersion} '
            'build ${info.buildNumber}',
        windowsVersion: '${info.displayVersion} (${info.buildNumber})',
        cpuArchitecture: '${info.numberOfCores} cores',
      );
    }
    if (platform.isMacOS) {
      final info = await deviceInfo.macOsInfo;
      return _NativeDetails(
        operatingSystem: '${info.osRelease} ${info.kernelVersion}',
        cpuArchitecture: info.arch,
      );
    }
    if (platform.isLinux) {
      final info = await deviceInfo.linuxInfo;
      return _NativeDetails(
        operatingSystem: '${info.prettyName} ${info.version ?? ''}',
        cpuArchitecture: info.machineId ?? '',
      );
    }
    if (platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return _NativeDetails(
        operatingSystem:
            'Android ${info.version.release} (SDK ${info.version.sdkInt})',
        cpuArchitecture: info.supportedAbis.join(', '),
      );
    }
    if (platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return _NativeDetails(
        operatingSystem: '${info.systemName} ${info.systemVersion}',
        cpuArchitecture: info.utsname.machine,
      );
    }
    return const _NativeDetails(operatingSystem: 'Unknown');
  }

  static String _flutterVersionLabel() {
    return Platform.version.split('\n').first;
  }
}

class _NativeDetails {
  const _NativeDetails({
    required this.operatingSystem,
    this.windowsVersion = '',
    this.cpuArchitecture = '',
  });

  final String operatingSystem;
  final String windowsVersion;
  final String cpuArchitecture;
}

class DeviceInfoSnapshot {
  const DeviceInfoSnapshot({
    required this.platform,
    required this.operatingSystem,
    required this.windowsVersion,
    required this.cpuArchitecture,
    required this.flutterVersion,
    required this.buildVersion,
    required this.appName,
  });

  final String platform;
  final String operatingSystem;
  final String windowsVersion;
  final String cpuArchitecture;
  final String flutterVersion;
  final String buildVersion;
  final String appName;

  List<String> toLogLines() {
    return [
      'Platform: $platform',
      'OS: $operatingSystem',
      if (windowsVersion.isNotEmpty) 'Windows Version: $windowsVersion',
      if (cpuArchitecture.isNotEmpty) 'CPU Architecture: $cpuArchitecture',
      'Flutter Version: $flutterVersion',
      'Build Version: $buildVersion',
    ];
  }
}

/// Resolves DNS for [host] when dart:io is available.
Future<List<InternetAddress>> lookupHost(String host) {
  return InternetAddress.lookup(host);
}
