import 'dart:convert';

import 'package:billing_baba/core/database/drift_database_paths.dart';
import 'package:billing_baba/features/backup/backup_constants.dart';

export 'package:billing_baba/core/database/drift_database_paths.dart'
    show DriftDatabasePaths, kDriftDatabaseName;

/// Backup/restore database path resolver (same source as Drift).
typedef BackupDatabasePaths = DriftDatabasePaths;

class BillingBabaBackupManifest {
  const BillingBabaBackupManifest({
    required this.version,
    required this.createdAt,
    required this.schemaVersion,
    required this.businessId,
    required this.appVersion,
    required this.checksums,
    this.tablesIncluded = kBibaTablesIncluded,
  });

  factory BillingBabaBackupManifest.fromJson(Map<String, dynamic> json) {
    final checksumsRaw = json['checksums'];
    return BillingBabaBackupManifest(
      version: json['version'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      schemaVersion: json['schema_version'] as int? ?? 0,
      businessId: json['business_id'] as String? ?? '',
      appVersion: json['app_version'] as String? ?? '',
      checksums: checksumsRaw is Map
          ? checksumsRaw.map(
              (key, value) => MapEntry('$key', '$value'),
            )
          : const {},
      tablesIncluded:
          (json['tables_included'] as List<dynamic>?)
              ?.map((e) => '$e')
              .toList() ??
          kBibaTablesIncluded,
    );
  }

  final int version;
  final String createdAt;
  final int schemaVersion;
  final String businessId;
  final String appVersion;
  final Map<String, String> checksums;
  final List<String> tablesIncluded;

  Map<String, dynamic> toJson() => {
    'format': 'BillingBabaBackup',
    'version': version,
    'created_at': createdAt,
    'schema_version': schemaVersion,
    'business_id': businessId,
    'app_version': appVersion,
    'checksums': checksums,
    'tables_included': tablesIncluded,
  };

  static BillingBabaBackupManifest parse(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup manifest');
    }
    return BillingBabaBackupManifest.fromJson(decoded);
  }
}

class BackupSyncMetadata {
  const BackupSyncMetadata({
    this.pullCursor,
    this.bootstrappedAt,
    this.localSchemaVersion,
    this.lastServerSchemaVersion,
  });

  factory BackupSyncMetadata.fromJson(Map<String, dynamic> json) {
    return BackupSyncMetadata(
      pullCursor: json['pull_cursor'] as String?,
      bootstrappedAt: json['bootstrapped_at'] as String?,
      localSchemaVersion: json['local_schema_version'] as int?,
      lastServerSchemaVersion: json['last_server_schema_version'] as int?,
    );
  }

  final String? pullCursor;
  final String? bootstrappedAt;
  final int? localSchemaVersion;
  final int? lastServerSchemaVersion;

  Map<String, dynamic> toJson() => {
    if (pullCursor != null) 'pull_cursor': pullCursor,
    if (bootstrappedAt != null) 'bootstrapped_at': bootstrappedAt,
    if (localSchemaVersion != null) 'local_schema_version': localSchemaVersion,
    if (lastServerSchemaVersion != null)
      'last_server_schema_version': lastServerSchemaVersion,
  };
}
