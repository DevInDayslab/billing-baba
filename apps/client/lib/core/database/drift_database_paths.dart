import 'dart:io';

import 'package:billing_baba/core/database/database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Drift database name — must match [AppDatabase] `driftDatabase(name: ...)`.
const kDriftDatabaseName = 'billing_baba';

/// Resolves the on-disk SQLite file using the same rules as `driftDatabase()`.
///
/// On desktop/mobile, Drift stores `$name.sqlite` under
/// `getApplicationDocumentsDirectory()` (not Application Support).
class DriftDatabasePaths {
  DriftDatabasePaths({this.overrideDatabaseFile});

  final File? overrideDatabaseFile;

  /// Default path used by `driftDatabase(name: kDriftDatabaseName)`.
  Future<File> resolveDefaultFile() async {
    if (overrideDatabaseFile != null) {
      return overrideDatabaseFile!;
    }
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, '$kDriftDatabaseName.sqlite'));
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
