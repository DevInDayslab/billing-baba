import 'dart:io';

import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Drift database name — must match [AppDatabase] `driftDatabase(name: ...)`.
const kDriftDatabaseName = 'billing_baba';

/// Resolves the on-disk SQLite file using the same rules as `driftDatabase()`.
///
/// Desktop stores under Application Support (Windows: LocalAppData\BillingBaba),
/// not Documents — Documents is often blocked by Controlled Folder Access and
/// causes SqliteException(14) CANTOPEN.
///
/// Call [ensureInitialized] once on the UI isolate before opening [AppDatabase]
/// so background Drift isolates can use a concrete path without path_provider.
class DriftDatabasePaths {
  DriftDatabasePaths({this.overrideDatabaseFile});

  final File? overrideDatabaseFile;

  static String? _cachedPath;

  /// Absolute path prepared by [ensureInitialized] (or override).
  static String? get cachedPath => _cachedPath;

  /// Resolve, create parent dirs, migrate legacy Documents DB, cache path.
  static Future<String> ensureInitialized() async {
    if (_cachedPath != null) return _cachedPath!;
    final paths = DriftDatabasePaths();
    final file = await paths.prepareDatabaseFile();
    _cachedPath = file.path;
    return _cachedPath!;
  }

  /// Directory that contains `$kDriftDatabaseName.sqlite`.
  Future<Directory> resolveDatabaseDirectory() async {
    if (overrideDatabaseFile != null) {
      return Directory(p.dirname(overrideDatabaseFile!.path));
    }

    if (!kIsWeb && AppPlatform.current.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null && localAppData.isNotEmpty) {
        return Directory(
          p.join(localAppData, AppConfig.dataDirectoryName, 'databases'),
        );
      }
    }

    final supportDir = await getApplicationSupportDirectory();
    return Directory(p.join(supportDir.path, 'databases'));
  }

  /// Default path used by `driftDatabase(name: kDriftDatabaseName)`.
  Future<File> resolveDefaultFile() async {
    if (overrideDatabaseFile != null) {
      return overrideDatabaseFile!;
    }
    if (_cachedPath != null) {
      return File(_cachedPath!);
    }
    final dir = await resolveDatabaseDirectory();
    return File(p.join(dir.path, '$kDriftDatabaseName.sqlite'));
  }

  /// Legacy Drift default: Documents/`billing_baba.sqlite`.
  Future<File> resolveLegacyDocumentsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, '$kDriftDatabaseName.sqlite'));
  }

  /// Ensures the DB directory exists and migrates a legacy Documents DB once.
  Future<File> prepareDatabaseFile() async {
    if (overrideDatabaseFile != null) {
      final parent = Directory(p.dirname(overrideDatabaseFile!.path));
      await parent.create(recursive: true);
      return overrideDatabaseFile!;
    }

    final dir = await resolveDatabaseDirectory();
    await dir.create(recursive: true);
    final target = File(p.join(dir.path, '$kDriftDatabaseName.sqlite'));

    if (!await target.exists()) {
      await _migrateLegacyIfPresent(target);
    }

    LoggingService.instance.info('SQLite database path: ${target.path}');
    return target;
  }

  Future<void> _migrateLegacyIfPresent(File target) async {
    try {
      final legacy = await resolveLegacyDocumentsFile();
      if (!await legacy.exists()) return;

      await legacy.copy(target.path);
      await deleteSidecarFiles(legacy);
      try {
        await legacy.delete();
      } on Object {
        // Non-fatal — Controlled Folder Access may block deletes.
      }
      LoggingService.instance.info(
        'Migrated SQLite DB from Documents to ${target.path}',
      );
    } on Object catch (e, st) {
      LoggingService.instance.warn(
        'Could not migrate legacy Documents SQLite DB: $e',
      );
      LoggingService.instance.debug(st.toString());
    }
  }

  /// Reads the main database file from the active [database] connection.
  Future<File> resolveFromDatabase(AppDatabase database) async {
    if (overrideDatabaseFile != null) {
      return overrideDatabaseFile!;
    }

    final rows = await database.customSelect('PRAGMA database_list').get();
    for (final row in rows) {
      final name = row.data['name'] as String?;
      final file = row.data['file'] as String?;
      if (name == 'main' && file != null && file.isNotEmpty) {
        return File(file);
      }
    }

    return resolveDefaultFile();
  }

  Future<void> deleteSidecarFiles(File dbFile) async {
    for (final suffix in const ['-wal', '-shm']) {
      final sidecar = File('${dbFile.path}$suffix');
      if (await sidecar.exists()) {
        await sidecar.delete();
      }
    }
  }
}
