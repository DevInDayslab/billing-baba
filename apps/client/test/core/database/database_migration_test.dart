import 'dart:io';

import 'package:billing_baba/core/database/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upgrade from v14 does not duplicate paid_amount columns', () async {
    final tempDir = await Directory.systemTemp.createTemp('db-migration-test');
    final dbFile = File('${tempDir.path}/billing_baba.sqlite');

    final seeded = AppDatabase(NativeDatabase(dbFile));
    await seeded.customStatement('PRAGMA user_version = 14');
    await seeded.close();

    final upgraded = AppDatabase(NativeDatabase(dbFile));
    final salesColumns = await upgraded
        .customSelect('PRAGMA table_info(sales_documents_local)')
        .get();
    final purchaseColumns = await upgraded
        .customSelect('PRAGMA table_info(purchase_documents_local)')
        .get();

    expect(
      salesColumns.map((row) => row.data['name']),
      containsAll(['paid_amount', 'payment_mode']),
    );
    expect(
      purchaseColumns.map((row) => row.data['name']),
      containsAll(['paid_amount', 'payment_mode']),
    );

    final version = await upgraded
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.data['user_version'], AppDatabase.currentSchemaVersion);

    await upgraded.close();
    await tempDir.delete(recursive: true);
  });

  test('fresh database opens at current schema version', () async {
    final tempDir = await Directory.systemTemp.createTemp('db-fresh-test');
    final dbFile = File('${tempDir.path}/billing_baba.sqlite');

    final db = AppDatabase(NativeDatabase(dbFile));
    final version =
        await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data['user_version'], AppDatabase.currentSchemaVersion);

    await db.close();
    await tempDir.delete(recursive: true);
  });
}
