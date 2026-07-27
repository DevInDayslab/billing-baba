import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/features/backup/backup_constants.dart';
import 'package:billing_baba/features/backup/models/backup_manifest.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:package_info_plus/package_info_plus.dart';

class BackupExportResult {
  const BackupExportResult({
    required this.bytes,
    required this.manifest,
    required this.suggestedFilename,
  });

  final Uint8List bytes;
  final BillingBabaBackupManifest manifest;
  final String suggestedFilename;
}

/// Builds a `.biba` ZIP archive from the local Drift database and sync metadata.
class BackupExporter {
  BackupExporter({
    required this._database,
    required this._storage,
    required this._metadata,
    BackupDatabasePaths? paths,
  })  : _paths = paths ?? BackupDatabasePaths();

  final AppDatabase _database;
  final StorageService _storage;
  final SyncMetadataStore _metadata;
  final BackupDatabasePaths _paths;

  Future<BackupExportResult> export({
    required String businessId,
    String? appVersion,
  }) async {
    if (businessId.trim().isEmpty) {
      throw StateError('Business id is required for backup export');
    }

    await _database.customStatement('PRAGMA wal_checkpoint(FULL);');

    final dbFile = await _paths.resolveFromDatabase(_database);
    if (!await dbFile.exists()) {
      throw StateError(
        'Local database file not found at ${dbFile.path}',
      );
    }

    final dbBytes = await dbFile.readAsBytes();
    final syncMetadata = BackupSyncMetadata(
      pullCursor: _metadata.pullCursor,
      bootstrappedAt: _metadata.bootstrappedAt?.toUtc().toIso8601String(),
      localSchemaVersion: _metadata.localSchemaVersion,
      lastServerSchemaVersion: _metadata.lastServerSchemaVersion,
    );
    final deviceJson = jsonEncode({
      'device_id': _storage.read(StorageKeys.syncDeviceId),
    });
    final businessPrefs = _exportBusinessPrefs(businessId);
    final documentCounters = await _exportDocumentCounters(businessId);
    final pendingQueue = await _exportSyncQueue(businessId);

    final resolvedAppVersion = (appVersion != null && appVersion.isNotEmpty)
        ? appVersion
        : (await PackageInfo.fromPlatform()).version;
    final createdAt = DateTime.now().toUtc().toIso8601String();

    final checksums = <String, String>{
      kBibaDatabaseEntry: _sha256(dbBytes),
      kBibaSyncMetadataEntry: _sha256(utf8.encode(jsonEncode(syncMetadata.toJson()))),
      kBibaDeviceEntry: _sha256(utf8.encode(deviceJson)),
      kBibaBusinessPrefsEntry: _sha256(utf8.encode(jsonEncode(businessPrefs))),
      kBibaDocumentCountersEntry:
          _sha256(utf8.encode(jsonEncode(documentCounters))),
      kBibaPendingQueueEntry: _sha256(utf8.encode(jsonEncode(pendingQueue))),
    };

    final manifest = BillingBabaBackupManifest(
      version: kBibaFormatVersion,
      createdAt: createdAt,
      schemaVersion: kBibaSchemaVersion,
      businessId: businessId,
      appVersion: resolvedAppVersion,
      checksums: checksums,
    );

    final archive = Archive()
      ..addFile(
        ArchiveFile(
          kBibaManifestEntry,
          utf8.encode(jsonEncode(manifest.toJson())).length,
          utf8.encode(jsonEncode(manifest.toJson())),
        ),
      )
      ..addFile(ArchiveFile(kBibaDatabaseEntry, dbBytes.length, dbBytes))
      ..addFile(
        ArchiveFile(
          kBibaSyncMetadataEntry,
          utf8.encode(jsonEncode(syncMetadata.toJson())).length,
          utf8.encode(jsonEncode(syncMetadata.toJson())),
        ),
      )
      ..addFile(
        ArchiveFile(
          kBibaDeviceEntry,
          utf8.encode(deviceJson).length,
          utf8.encode(deviceJson),
        ),
      )
      ..addFile(
        ArchiveFile(
          kBibaBusinessPrefsEntry,
          utf8.encode(jsonEncode(businessPrefs)).length,
          utf8.encode(jsonEncode(businessPrefs)),
        ),
      )
      ..addFile(
        ArchiveFile(
          kBibaDocumentCountersEntry,
          utf8.encode(jsonEncode(documentCounters)).length,
          utf8.encode(jsonEncode(documentCounters)),
        ),
      )
      ..addFile(
        ArchiveFile(
          kBibaPendingQueueEntry,
          utf8.encode(jsonEncode(pendingQueue)).length,
          utf8.encode(jsonEncode(pendingQueue)),
        ),
      );

    final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive));
    final safeBusiness = businessId.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '');
    final date = createdAt.split('T').first;
    return BackupExportResult(
      bytes: zipBytes,
      manifest: manifest,
      suggestedFilename: 'billing-baba-$safeBusiness-$date.biba',
    );
  }

  Map<String, String> _exportBusinessPrefs(String businessId) {
    final prefs = <String, String>{};
    for (final key in kBibaRestorableBusinessPrefKeys) {
      final value = _storage.read('${key}_$businessId');
      if (value != null && value.isNotEmpty) {
        prefs[key] = value;
      }
    }
    return prefs;
  }

  Future<List<Map<String, dynamic>>> _exportDocumentCounters(
    String businessId,
  ) async {
    final rows = await (_database.select(_database.localDocumentCounters)
          ..where((t) => t.businessId.equals(businessId)))
        .get();
    return rows
        .map(
          (row) => {
            'business_id': row.businessId,
            'document_series': row.documentSeries,
            'next_number': row.nextNumber,
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> _exportSyncQueue(String businessId) async {
    final rows = await (_database.select(_database.syncQueue)
          ..where((t) => t.businessId.equals(businessId)))
        .get();
    return rows
        .map(
          (row) => {
            'id': row.id,
            'mutation_id': row.mutationId,
            'kind': row.kind,
            'entity_type': row.entityType,
            'entity_id': row.entityId,
            'operation': row.operation,
            'payload': row.payload,
            'business_id': row.businessId,
            'device_id': row.deviceId,
            'command_id': row.commandId,
            'status': row.status,
            'priority': row.priority,
            'attempt_count': row.attemptCount,
            'last_error': row.lastError,
            'last_attempt_at': row.lastAttemptAt?.toUtc().toIso8601String(),
            'scheduled_at': row.scheduledAt?.toUtc().toIso8601String(),
            'next_retry_at': row.nextRetryAt?.toUtc().toIso8601String(),
            'created_at': row.createdAt.toUtc().toIso8601String(),
          },
        )
        .toList();
  }

  String _sha256(List<int> bytes) => sha256.convert(bytes).toString();
}
