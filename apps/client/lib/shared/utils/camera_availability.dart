import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Whether barcode camera scanning can be started safely on this device.
///
/// The mobile_scanner plugin can crash on Android emulators with no virtual
/// camera because CameraX reports zero cameras and the plugin does not catch
/// the native initialization failure.
Future<bool> isBarcodeCameraAvailable() async {
  if (kIsWeb) return false;
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    return false;
  }

  final plugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final info = await plugin.androidInfo;
    return info.isPhysicalDevice;
  }
  if (Platform.isIOS) {
    final info = await plugin.iosInfo;
    return info.isPhysicalDevice;
  }

  return false;
}
