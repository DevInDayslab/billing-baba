import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/backup/backup_constants.dart';
import 'package:billing_baba/features/backup/data/backup_exporter.dart';
import 'package:billing_baba/features/backup/data/backup_importer.dart';
import 'package:billing_baba/features/backup/models/backup_manifest.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('export then restore round-trip preserves queue and cursor', () async {
    final tempDir = await Directory.systemTemp.createTemp('biba-restore-test');
    final dbFile = File('${tempDir.path}/billing_baba.sqlite');

    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-restore-1',
      StorageKeys.syncDeviceId: 'device-restore-test',
      StorageKeys.syncPullCursor: 'cursor-restore-xyz',
      StorageKeys.syncBootstrappedAt: '2026-07-27T00:00:00.000Z',
      StorageKeys.syncLocalSchemaVersion: '1',
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(preferences: prefs);
    final metadata = SyncMetadataStore(storage);

    final sourceDb = AppDatabase(NativeDatabase(dbFile));
    final queue = SyncQueue(sourceDb);
    await queue.enqueueCommand(
      businessId: 'biz-restore-1',
      command: 'finalize_credit_note',
      commandId: 'cmd-restore-1',
      payload: {'document_id': 'doc-1'},
      entityType: 'sales_documents',
      entityId: 'doc-1',
    );

    final exporter = BackupExporter(
      database: sourceDb,
      storage: storage,
      metadata: metadata,
      paths: BackupDatabasePaths(overrideDatabaseFile: dbFile),
    );
    final exported = await exporter.export(
      businessId: 'biz-restore-1',
      appVersion: '1.0.0-test',
    );
    await sourceDb.close();

    final restoreDbFile = File('${tempDir.path}/restored.sqlite');
    final importer = BackupImporter(
      storage: storage,
      metadata: metadata,
      paths: BackupDatabasePaths(overrideDatabaseFile: restoreDbFile),
    );
    final restored = await importer.restore(
      exported.bytes,
      databaseFile: restoreDbFile,
    );

    expect(restored.manifest.businessId, 'biz-restore-1');
    expect(metadata.pullCursor, 'cursor-restore-xyz');
    expect(storage.read(StorageKeys.syncDeviceId), 'device-restore-test');
    expect(restored.restoredQueueJobs, 1);

    final restoredDb = AppDatabase(NativeDatabase(restoreDbFile));
    final jobs = await restoredDb.select(restoredDb.syncQueue).get();
    expect(jobs.length, 1);
    expect(jobs.first.commandId, 'cmd-restore-1');
    expect(jobs.first.status, SyncQueueStatus.pending.wire);
    await restoredDb.close();

    await tempDir.delete(recursive: true);
  });

  test('restore rejects tampered checksum', () async {
    final tempDir = await Directory.systemTemp.createTemp('biba-tamper-test');
    final dbFile = File('${tempDir.path}/billing_baba.sqlite');

    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-tamper-1',
      StorageKeys.syncDeviceId: 'device-tamper',
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(preferences: prefs);
    final metadata = SyncMetadataStore(storage);

    final db = AppDatabase(NativeDatabase(dbFile));
    final exporter = BackupExporter(
      database: db,
      storage: storage,
      metadata: metadata,
      paths: BackupDatabasePaths(overrideDatabaseFile: dbFile),
    );
    final exported = await exporter.export(
      businessId: 'biz-tamper-1',
      appVersion: '1.0.0-test',
    );
    await db.close();

    final archive = ZipDecoder().decodeBytes(exported.bytes);
    final tamperedArchive = Archive();
    for (final file in archive.files) {
      if (file.name == kBibaDatabaseEntry) {
        tamperedArchive.addFile(
          ArchiveFile(file.name, 4, [0, 1, 2, 3]),
        );
      } else {
        tamperedArchive.addFile(file);
      }
    }
    final tampered = Uint8List.fromList(ZipEncoder().encode(tamperedArchive));

    final tamperedDbFile = File('${tempDir.path}/tampered.sqlite');
    final importer = BackupImporter(
      storage: storage,
      metadata: metadata,
      paths: BackupDatabasePaths(
        overrideDatabaseFile: tamperedDbFile,
      ),
    );

    expect(
      () => importer.restore(
        tampered,
        databaseFile: tamperedDbFile,
      ),
      throwsA(isA<BackupRestoreException>()),
    );

    await tempDir.delete(recursive: true);
  });
}
