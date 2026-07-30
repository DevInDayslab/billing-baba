import 'dart:io';

import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/database/drift_database_paths.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('resolveFromDatabase returns the live sqlite file path', () async {
    final tempDir = await Directory.systemTemp.createTemp('drift-path-test');
    final dbFile = File(p.join(tempDir.path, '$kDriftDatabaseName.sqlite'));

    final db = AppDatabase(NativeDatabase(dbFile));
    await db.customSelect('PRAGMA user_version').getSingle();
    final paths = DriftDatabasePaths(overrideDatabaseFile: dbFile);

    final resolved = await paths.resolveFromDatabase(db);
    expect(resolved.path, dbFile.path);
    expect(await resolved.exists(), isTrue);

    await db.close();
    await tempDir.delete(recursive: true);
  });

  test('resolveDefaultFile uses billing_baba.sqlite filename', () async {
    final paths = DriftDatabasePaths(
      overrideDatabaseFile: File('/tmp/test/billing_baba.sqlite'),
    );
    final file = await paths.resolveDefaultFile();
    expect(p.basename(file.path), '$kDriftDatabaseName.sqlite');
  });
}
