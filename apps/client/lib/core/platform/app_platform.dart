import 'dart:io' show Platform;

import 'package:billing_baba/core/platform/app_platform_detector.dart';
import 'package:flutter/foundation.dart';

enum PlatformFamily {
  desktop,
  mobile,
}

enum OperatingSystem {
  windows,
  macOS,
  linux,
  android,
  ios,
}

/// Single source of platform information for the client.
///
/// Prefer [AppPlatform.current] over `dart:io` [Platform] checks elsewhere.
final class AppPlatform {
  const AppPlatform({required this.os});

  final OperatingSystem os;

  PlatformFamily get family => switch (os) {
    OperatingSystem.windows ||
    OperatingSystem.macOS ||
    OperatingSystem.linux => PlatformFamily.desktop,
    OperatingSystem.android || OperatingSystem.ios => PlatformFamily.mobile,
  };

  bool get isDesktop => family == PlatformFamily.desktop;
  bool get isMobile => family == PlatformFamily.mobile;
  bool get isWindows => os == OperatingSystem.windows;
  bool get isMacOS => os == OperatingSystem.macOS;
  bool get isLinux => os == OperatingSystem.linux;
  bool get isAndroid => os == OperatingSystem.android;
  bool get isIOS => os == OperatingSystem.ios;

  static AppPlatform get current => _current;

  static final AppPlatform _current = AppPlatform(os: _detectOs());

  static OperatingSystem _detectOs() {
    if (kIsWeb) {
      return switch (defaultTargetPlatform) {
        TargetPlatform.iOS => OperatingSystem.ios,
        TargetPlatform.android => OperatingSystem.android,
        TargetPlatform.macOS => OperatingSystem.macOS,
        TargetPlatform.windows => OperatingSystem.windows,
        TargetPlatform.linux => OperatingSystem.linux,
        TargetPlatform.fuchsia => OperatingSystem.linux,
      };
    }
    return detectNativeOperatingSystem();
  }
}
