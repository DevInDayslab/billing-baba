import 'dart:io' show Platform;

import 'package:billing_baba/core/platform/app_platform.dart';

OperatingSystem detectNativeOperatingSystem() {
  if (Platform.isWindows) return OperatingSystem.windows;
  if (Platform.isMacOS) return OperatingSystem.macOS;
  if (Platform.isLinux) return OperatingSystem.linux;
  if (Platform.isAndroid) return OperatingSystem.android;
  if (Platform.isIOS) return OperatingSystem.ios;
  // Fallback for uncommon hosts (e.g. Fuchsia).
  return OperatingSystem.linux;
}
