import 'dart:io';

import 'package:archive/archive.dart';
import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/features/backup/backup_constants.dart';
import 'package:billing_baba/features/backup/data/backup_exporter.dart';
import 'package:billing_baba/features/backup/models/backup_manifest.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;
  late File dbFile;
  late AppDatabase db;
  late StorageService storage;
  late SyncMetadataStore metadata;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-backup-1',
      StorageKeys.syncDeviceId: 'device-backup-test',
      StorageKeys.syncPullCursor: 'cursor-test-abc',
      StorageKeys.syncBootstrappedAt: '2026-07-27T00:00:00.000Z',
      StorageKeys.syncLocalSchemaVersion: '1',
    });
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(preferences: prefs);
    metadata = SyncMetadataStore(storage);

    tempDir = await Directory.systemTemp.createTemp('biba-backup-test');
    dbFile = File('${tempDir.path}/billing_baba.sqlite');
    db = AppDatabase(NativeDatabase(dbFile));

    await db.customStatement(
      "INSERT INTO parties_local (id, business_id, name, party_type, created_at, updated_at, sync_version, is_deleted) "
      "VALUES ('party-1', 'biz-backup-1', 'Test Party', 'customer', '2026-07-27T00:00:00.000Z', '2026-07-27T00:00:00.000Z', 0, 0)",
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('export produces valid manifest and checksums', () async {
    final exporter = BackupExporter(
      database: db,
      storage: storage,
      metadata: metadata,
      paths: BackupDatabasePaths(overrideDatabaseFile: dbFile),
    );

    final result = await exporter.export(
      businessId: 'biz-backup-1',
      appVersion: '1.0.0-test',
    );
    expect(result.bytes.isNotEmpty, isTrue);
    expect(result.manifest.version, kBibaFormatVersion);
    expect(result.manifest.businessId, 'biz-backup-1');
    expect(result.manifest.checksums.containsKey(kBibaDatabaseEntry), isTrue);

    final archive = ZipDecoder().decodeBytes(result.bytes);
    final manifestEntry = archive.files.firstWhere(
      (file) => file.name == kBibaManifestEntry,
    );
    final manifest = BillingBabaBackupManifest.parse(
      String.fromCharCodes(manifestEntry.content as List<int>),
    );
    expect(manifest.tablesIncluded, isNotEmpty);
  });
}
