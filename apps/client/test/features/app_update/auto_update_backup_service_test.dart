import 'dart:io';
import 'dart:typed_data';

import 'package:billing_baba/features/app_update/application/auto_update_backup_service.dart';
import 'package:billing_baba/features/backup/data/backup_exporter.dart';
import 'package:billing_baba/features/backup/models/backup_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

import 'update_test_helpers.dart';

BackupExportResult _exportResult() => BackupExportResult(
  bytes: Uint8List.fromList([1, 2, 3]),
  manifest: BillingBabaBackupManifest(
    version: 1,
    createdAt: '2026-01-01T00:00:00Z',
    schemaVersion: 1,
    businessId: 'biz',
    appVersion: '1.0.0',
    checksums: const {},
  ),
  suggestedFilename: 'x.biba',
);

void main() {
  test('creates backup file with version in name', () async {
    final dir = await Directory.systemTemp.createTemp('auto-backup');
    final service = AutoUpdateBackupService(
      null,
      backupDirectoryOverride: dir,
      packageInfoOverride: testPackageInfo(version: '2.3.4', buildNumber: '9'),
      exportBackupFn: () async => _exportResult(),
    );

    final file = await service.createPreUpdateBackup();
    expect(file.path, contains('backup_'));
    expect(file.path, contains('v2.3.4+9.biba'));
    expect(await file.exists(), isTrue);
    await dir.delete(recursive: true);
  });

  test('keeps only newest five backups', () async {
    final dir = await Directory.systemTemp.createTemp('auto-backup-prune');
    for (var i = 0; i < 8; i++) {
      final file = File('${dir.path}/backup_old_$i.biba');
      await file.writeAsBytes([i]);
      await file.setLastModified(DateTime(2026, 1, i + 1));
    }
    await AutoUpdateBackupService.pruneOldBackupsInDirectory(dir);
    final remaining = dir.listSync().whereType<File>().toList();
    expect(remaining.length, AutoUpdateBackupService.maxRetainedBackups);
    await dir.delete(recursive: true);
  });

  test('unwritable directory throws', () async {
    final service = AutoUpdateBackupService(
      null,
      backupDirectoryOverride: Directory(r'Z:\billing_baba_nonexistent_backup_root'),
      packageInfoOverride: testPackageInfo(),
      exportBackupFn: () async => _exportResult(),
    );
    expect(
      () async => await service.createPreUpdateBackup(),
      throwsA(anything),
    );
  });
}
