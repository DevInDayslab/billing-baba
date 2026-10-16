import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Detects whether this desktop process is the first Billing Baba window.
///
/// The primary instance keeps the restored company session (dashboard on cold
/// start). Additional instances clear business scope and land on the company
/// picker — same as "Switch company".
abstract final class DesktopAppInstance {
  static bool _isPrimary = true;
  static bool _registered = false;

  static RandomAccessFile? _lockFile;

  /// Override for tests: `--dart-define=DESKTOP_ADDITIONAL_INSTANCE=true`.
  static bool get isPrimary {
    const forceAdditional = bool.fromEnvironment('DESKTOP_ADDITIONAL_INSTANCE');
    if (forceAdditional) return false;
    return _isPrimary;
  }

  static Future<void> register() async {
    if (_registered) return;
    _registered = true;

    if (kIsWeb || !AppPlatform.current.isDesktop) {
      _isPrimary = true;
      return;
    }

    _isPrimary = await _acquireFileLock();

    LoggingService.instance.info(
      'DesktopAppInstance: ${_isPrimary ? 'primary' : 'additional'}',
    );
  }

  static Future<void> release() async {
    if (_lockFile == null) return;
    try {
      await _lockFile!.unlock();
      await _lockFile!.close();
    } on Object {
      // Best-effort on shutdown.
    }
    _lockFile = null;
  }

  static Future<bool> _acquireFileLock() async {
    try {
      final dir = await _resolveDataDirectory();
      await dir.create(recursive: true);
      final lockPath = p.join(dir.path, 'primary_instance.lock');
      final raf = await File(lockPath).open(mode: FileMode.write);
      try {
        await raf.lock();
        _lockFile = raf;
        return true;
      } on FileSystemException {
        await raf.close();
        return false;
      }
    } on Object catch (e, st) {
      LoggingService.instance.error(
        'DesktopAppInstance: file lock failed — treating as primary',
        e,
        st,
      );
      return true;
    }
  }

  static Future<Directory> _resolveDataDirectory() async {
    if (AppPlatform.current.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null && localAppData.isNotEmpty) {
        return Directory(p.join(localAppData, AppConfig.dataDirectoryName));
      }
    }
    return getApplicationSupportDirectory();
  }
}
