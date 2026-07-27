import 'dart:convert';
import 'dart:io';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'dart:typed_data';

import 'package:billing_baba/features/backup/data/backup_exporter.dart';
import 'package:billing_baba/features/backup/data/backup_importer.dart';
import 'package:billing_baba/features/backup/models/backup_manifest.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Verifies restored command jobs keep stable command_id for server replay.
void main() {
  test('restored finalize command retains command_id for idempotent replay',
      () async {
    final tempDir = await Directory.systemTemp.createTemp('biba-sync-test');
    final dbFile = File('${tempDir.path}/billing_baba.sqlite');

    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-sync-1',
      StorageKeys.syncDeviceId: 'device-sync-test',
      StorageKeys.syncPullCursor: 'cursor-sync-abc',
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(preferences: prefs);
    final metadata = SyncMetadataStore(storage);

    final db = AppDatabase(NativeDatabase(dbFile));
    final queue = SyncQueue(db);
    const commandId = 'finalize-cmd-stable-id';
    await queue.enqueueCommand(
      businessId: 'biz-sync-1',
      command: 'finalize_debit_note',
      commandId: commandId,
      payload: {'document_id': 'doc-debit-1'},
      entityType: 'purchase_documents',
      entityId: 'doc-debit-1',
    );

    final exporter = BackupExporter(
      database: db,
      storage: storage,
      metadata: metadata,
      paths: BackupDatabasePaths(overrideDatabaseFile: dbFile),
    );
    final exported = await exporter.export(
      businessId: 'biz-sync-1',
      appVersion: '1.0.0-test',
    );
    await db.close();

    final restoredFile = File('${tempDir.path}/restored-sync.sqlite');
    final importer = BackupImporter(
      storage: storage,
      metadata: metadata,
      paths: BackupDatabasePaths(overrideDatabaseFile: restoredFile),
    );
    await importer.restore(exported.bytes);

    final restoredDb = AppDatabase(NativeDatabase(restoredFile));
    final jobs = await restoredDb.select(restoredDb.syncQueue).get();
    expect(jobs.single.commandId, commandId);
    expect(jobs.single.status, SyncQueueStatus.pending.wire);

    final payload = jsonDecode(jobs.single.payload) as Map<String, dynamic>;
    expect(payload['command'], 'finalize_debit_note');
    expect(metadata.pullCursor, 'cursor-sync-abc');

    await restoredDb.close();
    await tempDir.delete(recursive: true);
  });
}
