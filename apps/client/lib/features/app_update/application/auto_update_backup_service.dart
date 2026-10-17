import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/features/backup/application/backup_service.dart';
import 'package:billing_baba/features/backup/data/backup_exporter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final autoUpdateBackupServiceProvider = Provider<AutoUpdateBackupService>((
  ref,
) {
  return AutoUpdateBackupService(ref);
});

class AutoUpdateBackupService {
  AutoUpdateBackupService(
    Ref? ref, {
    Directory? backupDirectoryOverride,
    Future<BackupExportResult> Function()? exportBackupFn,
    PackageInfo? packageInfoOverride,
  }) : _ref = ref,
       _backupDirectoryOverride = backupDirectoryOverride,
       _exportBackupFn = exportBackupFn,
       _packageInfoOverride = packageInfoOverride;

  final Ref? _ref;
  final Directory? _backupDirectoryOverride;
  final Future<BackupExportResult> Function()? _exportBackupFn;
  final PackageInfo? _packageInfoOverride;

  static const maxRetainedBackups = 5;

  Future<File> createPreUpdateBackup() async {
    final export = _exportBackupFn != null
        ? await _exportBackupFn()
        : await (await _ref!.read(backupServiceProvider.future))
              .exportBackup();
    final dir = await _resolveAutoBackupDirectory();
    await dir.create(recursive: true);

    final packageInfo =
        _packageInfoOverride ?? await PackageInfo.fromPlatform();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName =
        'backup_${timestamp}_v${packageInfo.version}+${packageInfo.buildNumber}.biba';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(export.bytes, flush: true);

    await pruneOldBackupsInDirectory(dir);
    return file;
  }

  Future<Directory> _resolveAutoBackupDirectory() async {
    final backupDir = _backupDirectoryOverride;
    if (backupDir != null) {
      return backupDir;
    }
    if (!kIsWeb && AppPlatform.current.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null && localAppData.isNotEmpty) {
        return Directory(
          p.join(localAppData, AppConfig.dataDirectoryName, 'auto_backups'),
        );
      }
    }
    final support = await getApplicationSupportDirectory();
    return Directory(
      p.join(support.path, AppConfig.dataDirectoryName, 'auto_backups'),
    );
  }

  @visibleForTesting
  static Future<void> pruneOldBackupsInDirectory(Directory dir) async {
    final files = <File>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.toLowerCase().endsWith('.biba')) {
        files.add(entity);
      }
    }
    files.sort(
      (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
    );
    for (final file in files.skip(maxRetainedBackups)) {
      try {
        await file.delete();
      } on Object {
        // Best-effort prune.
      }
    }
  }
}
