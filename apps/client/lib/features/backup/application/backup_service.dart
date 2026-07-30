import 'dart:typed_data';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/backup/data/backup_exporter.dart';
import 'package:billing_baba/features/backup/data/backup_importer.dart';
import 'package:billing_baba/features/backup/models/backup_manifest.dart';
import 'package:billing_baba/features/command_sync/application/command_sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_service.g.dart';

@Riverpod(keepAlive: true)
Future<BackupService> backupService(Ref ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final metadata = SyncMetadataStore(storage);
  return BackupService(
    ref: ref,
    database: ref.watch(appDatabaseProvider),
    storage: storage,
    metadata: metadata,
  );
}

class BackupService {
  BackupService({
    required this._ref,
    required this.database,
    required this.storage,
    required this.metadata,
    BackupDatabasePaths? paths,
  }) : _paths = paths ?? BackupDatabasePaths();

  final Ref _ref;
  final AppDatabase database;
  final StorageService storage;
  final SyncMetadataStore metadata;
  final BackupDatabasePaths _paths;

  String? get _businessId =>
      storage.read(StorageKeys.lastOpenedBusinessId)?.trim();

  Future<BackupExportResult> exportBackup() async {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) {
      throw StateError('Open a business before exporting a backup');
    }

    final exporter = BackupExporter(
      database: database,
      storage: storage,
      metadata: metadata,
      paths: _paths,
    );
    return exporter.export(businessId: businessId);
  }

  Future<BackupRestoreResult> restoreBackup(Uint8List archiveBytes) async {
    final databaseFile = await _paths.resolveFromDatabase(database);

    final importer = BackupImporter(
      storage: storage,
      metadata: metadata,
      paths: _paths,
      onBeforeDatabaseReplace: () async {
        await _ref.read(appDatabaseProvider).close();
      },
      onDatabaseReopened: (_) async {
        _ref.invalidate(appDatabaseProvider);
        _ref.invalidate(syncQueueProvider);
        _ref.invalidate(syncEngineProvider);
        _ref.invalidate(commandAwareSyncEngineProvider);
        _ref.invalidate(salesInvoiceCommandRepositoryProvider);
        _ref.invalidate(salesReturnCommandRepositoryProvider);
        _ref.invalidate(purchaseBillCommandRepositoryProvider);
        _ref.invalidate(purchaseReturnCommandRepositoryProvider);
      },
    );
    final result = await importer.restore(
      archiveBytes,
      databaseFile: databaseFile,
    );

    final syncEngine = await _ref.read(commandAwareSyncEngineProvider.future);
    await syncEngine.syncNow();

    return result;
  }
}
